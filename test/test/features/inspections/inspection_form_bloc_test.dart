import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mini_app_de_inspecao_de_campo/features/inspections/data/models/inspection_draft_model.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/data/models/inspection_sync_result.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/data/repositories/inspections_repository.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/data/services/inspection_device_service.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/presentation/bloc/inspection_form_bloc.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/presentation/bloc/inspection_form_event.dart';
import 'package:mini_app_de_inspecao_de_campo/features/inspections/presentation/bloc/inspection_form_state.dart';

class MockInspectionsRepository extends Mock implements InspectionsRepository {}

class MockInspectionDeviceService extends Mock
    implements InspectionDeviceService {}

void main() {
  late MockInspectionsRepository repository;
  late MockInspectionDeviceService deviceService;

  const clientId = 'client-123';
  const workOrderId = 'wo-001';

  const validDraft = InspectionDraftModel(
    clientId: clientId,
    workOrderId: workOrderId,
    observation: 'Observação válida para concluir.',
    condition: 'bom',
    photoPath: '/tmp/foto.jpg',
    latitude: -7.115,
    longitude: -34.861,
  );

  setUp(() {
    repository = MockInspectionsRepository();
    deviceService = MockInspectionDeviceService();
  });

  test('restaura o mesmo clientId de um rascunho salvo', () {
    final bloc = InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
      initialDraft: validDraft,
    );

    expect(bloc.state.clientId, clientId);
    expect(bloc.state.workOrderId, workOrderId);
    expect(bloc.state.observation, validDraft.observation);
    expect(bloc.state.condition, validDraft.condition);
    expect(bloc.state.photoPath, validDraft.photoPath);
    expect(bloc.state.latitude, validDraft.latitude);
    expect(bloc.state.longitude, validDraft.longitude);
    expect(bloc.state.canComplete, isTrue);

    bloc.close();
  });

  blocTest<InspectionFormBloc, InspectionFormState>(
    'não conclui inspeção quando os campos obrigatórios estão incompletos',
    build: () => InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
    ),
    act: (bloc) {
      bloc.add(const InspectionCompleteRequested());
    },
    expect: () => [
      isA<InspectionFormState>()
          .having(
            (state) => state.saveStatus,
            'saveStatus',
            InspectionFormSaveStatus.failure,
          )
          .having(
            (state) => state.saveMessage,
            'saveMessage',
            'Preencha observação, condição, foto e localização.',
          ),
    ],
    verify: (_) {
      verifyNever(
        () => repository.savePending(
          clientId: any(named: 'clientId'),
          workOrderId: any(named: 'workOrderId'),
          observation: any(named: 'observation'),
          condition: any(named: 'condition'),
          photoPath: any(named: 'photoPath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          capturedAt: any(named: 'capturedAt'),
        ),
      );

      verifyNever(() => repository.syncInspection(any()));
    },
  );

  blocTest<InspectionFormBloc, InspectionFormState>(
    'salva localmente com o mesmo clientId e marca como sincronizada',
    setUp: () {
      when(
        () => repository.savePending(
          clientId: any(named: 'clientId'),
          workOrderId: any(named: 'workOrderId'),
          observation: any(named: 'observation'),
          condition: any(named: 'condition'),
          photoPath: any(named: 'photoPath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          capturedAt: any(named: 'capturedAt'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => repository.syncInspection(clientId),
      ).thenAnswer((_) async => InspectionSyncResult.synced);
    },
    build: () => InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
      initialDraft: validDraft,
    ),
    act: (bloc) {
      bloc.add(const InspectionCompleteRequested());
    },
    expect: () => [
      isA<InspectionFormState>().having(
        (state) => state.saveStatus,
        'saveStatus',
        InspectionFormSaveStatus.saving,
      ),
      isA<InspectionFormState>()
          .having(
            (state) => state.saveStatus,
            'saveStatus',
            InspectionFormSaveStatus.synced,
          )
          .having(
            (state) => state.saveMessage,
            'saveMessage',
            'Inspeção sincronizada com sucesso.',
          ),
    ],
    verify: (_) {
      verify(
        () => repository.savePending(
          clientId: clientId,
          workOrderId: workOrderId,
          observation: validDraft.observation,
          condition: validDraft.condition,
          photoPath: validDraft.photoPath,
          latitude: validDraft.latitude,
          longitude: validDraft.longitude,
          capturedAt: any(named: 'capturedAt'),
        ),
      ).called(1);

      verify(() => repository.syncInspection(clientId)).called(1);
    },
  );

  blocTest<InspectionFormBloc, InspectionFormState>(
    'mantém inspeção pendente quando a sincronização não pode ser concluída',
    setUp: () {
      when(
        () => repository.savePending(
          clientId: any(named: 'clientId'),
          workOrderId: any(named: 'workOrderId'),
          observation: any(named: 'observation'),
          condition: any(named: 'condition'),
          photoPath: any(named: 'photoPath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          capturedAt: any(named: 'capturedAt'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => repository.syncInspection(clientId),
      ).thenAnswer((_) async => InspectionSyncResult.pending);
    },
    build: () => InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
      initialDraft: validDraft,
    ),
    act: (bloc) {
      bloc.add(const InspectionCompleteRequested());
    },
    expect: () => [
      isA<InspectionFormState>().having(
        (state) => state.saveStatus,
        'saveStatus',
        InspectionFormSaveStatus.saving,
      ),
      isA<InspectionFormState>()
          .having(
            (state) => state.saveStatus,
            'saveStatus',
            InspectionFormSaveStatus.pendingSaved,
          )
          .having(
            (state) => state.saveMessage,
            'saveMessage',
            'Inspeção salva localmente e aguardando sincronização.',
          ),
    ],
    verify: (_) {
      verify(() => repository.syncInspection(clientId)).called(1);
    },
  );
  blocTest<InspectionFormBloc, InspectionFormState>(
    'salva rascunho localmente sem tentar sincronizar',
    setUp: () {
      when(
        () => repository.saveDraft(
          clientId: any(named: 'clientId'),
          workOrderId: any(named: 'workOrderId'),
          observation: any(named: 'observation'),
          condition: any(named: 'condition'),
          photoPath: any(named: 'photoPath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async {});
    },
    build: () => InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
      initialDraft: validDraft,
    ),
    act: (bloc) {
      bloc.add(const InspectionDraftSaveRequested());
    },
    expect: () => [
      isA<InspectionFormState>().having(
        (state) => state.saveStatus,
        'saveStatus',
        InspectionFormSaveStatus.saving,
      ),
      isA<InspectionFormState>()
          .having(
            (state) => state.saveStatus,
            'saveStatus',
            InspectionFormSaveStatus.draftSaved,
          )
          .having(
            (state) => state.saveMessage,
            'saveMessage',
            'Rascunho salvo com sucesso.',
          ),
    ],
    verify: (_) {
      verify(
        () => repository.saveDraft(
          clientId: clientId,
          workOrderId: workOrderId,
          observation: validDraft.observation,
          condition: validDraft.condition,
          photoPath: validDraft.photoPath,
          latitude: validDraft.latitude,
          longitude: validDraft.longitude,
        ),
      ).called(1);

      verifyNever(() => repository.syncInspection(any()));
    },
  );

  blocTest<InspectionFormBloc, InspectionFormState>(
    'marca falha quando a sincronização retorna erro definitivo',
    setUp: () {
      when(
        () => repository.savePending(
          clientId: any(named: 'clientId'),
          workOrderId: any(named: 'workOrderId'),
          observation: any(named: 'observation'),
          condition: any(named: 'condition'),
          photoPath: any(named: 'photoPath'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          capturedAt: any(named: 'capturedAt'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => repository.syncInspection(clientId),
      ).thenAnswer((_) async => InspectionSyncResult.failed);
    },
    build: () => InspectionFormBloc(
      workOrderId: workOrderId,
      deviceService: deviceService,
      inspectionsRepository: repository,
      initialDraft: validDraft,
    ),
    act: (bloc) {
      bloc.add(const InspectionCompleteRequested());
    },
    expect: () => [
      isA<InspectionFormState>().having(
        (state) => state.saveStatus,
        'saveStatus',
        InspectionFormSaveStatus.saving,
      ),
      isA<InspectionFormState>()
          .having(
            (state) => state.saveStatus,
            'saveStatus',
            InspectionFormSaveStatus.syncFailed,
          )
          .having(
            (state) => state.saveMessage,
            'saveMessage',
            'Inspeção salva, mas a sincronização falhou.',
          ),
    ],
    verify: (_) {
      verify(
        () => repository.savePending(
          clientId: clientId,
          workOrderId: workOrderId,
          observation: validDraft.observation,
          condition: validDraft.condition,
          photoPath: validDraft.photoPath,
          latitude: validDraft.latitude,
          longitude: validDraft.longitude,
          capturedAt: any(named: 'capturedAt'),
        ),
      ).called(1);

      verify(() => repository.syncInspection(clientId)).called(1);
    },
  );
}
