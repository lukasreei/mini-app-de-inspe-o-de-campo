import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/inspection_device_service.dart';
import 'inspection_form_event.dart';
import 'inspection_form_state.dart';
import '../../data/repositories/inspections_repository.dart';

import '../../data/models/inspection_draft_model.dart';
import '../../data/models/inspection_sync_result.dart';

class InspectionFormBloc
    extends Bloc<InspectionFormEvent, InspectionFormState> {
  InspectionFormBloc({
    InspectionDraftModel? initialDraft,
    required String workOrderId,
    required InspectionDeviceService deviceService,
    required InspectionsRepository inspectionsRepository,
    Uuid? uuid,
  }) : _deviceService = deviceService,
       _inspectionsRepository = inspectionsRepository,
       super(
         InspectionFormState(
           clientId: initialDraft?.clientId ?? (uuid ?? const Uuid()).v4(),
           workOrderId: workOrderId,
           observation: initialDraft?.observation ?? '',
           condition: initialDraft?.condition,
           photoPath: initialDraft?.photoPath,
           latitude: initialDraft?.latitude,
           longitude: initialDraft?.longitude,
         ),
       ) {
    on<InspectionObservationChanged>(_onObservationChanged);

    on<InspectionConditionChanged>(_onConditionChanged);

    on<InspectionPhotoRequested>(_onPhotoRequested);

    on<InspectionLocationRequested>(_onLocationRequested);

    on<InspectionGalleryPhotoRequested>(_onGalleryPhotoRequested);

    on<InspectionDraftSaveRequested>(_onDraftSaveRequested);

    on<InspectionCompleteRequested>(_onCompleteRequested);
  }

  final InspectionsRepository _inspectionsRepository;

  final InspectionDeviceService _deviceService;

  void _onObservationChanged(
    InspectionObservationChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(observation: event.observation, clearError: true));
  }

  void _onConditionChanged(
    InspectionConditionChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(condition: event.condition, clearError: true));
  }

  Future<void> _onPhotoRequested(
    InspectionPhotoRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isCapturingPhoto: true, clearError: true));

    try {
      final photoPath = await _deviceService.capturePhoto(
        clientId: state.clientId,
      );

      emit(state.copyWith(photoPath: photoPath, isCapturingPhoto: false));
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isCapturingPhoto: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCapturingPhoto: false,
          errorMessage: 'Não foi possível capturar a foto.',
        ),
      );
    }
  }

  Future<void> _onLocationRequested(
    InspectionLocationRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isGettingLocation: true, clearError: true));

    try {
      final location = await _deviceService.getCurrentLocation();

      emit(
        state.copyWith(
          latitude: location.latitude,
          longitude: location.longitude,
          isGettingLocation: false,
        ),
      );
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isGettingLocation: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isGettingLocation: false,
          errorMessage: 'Não foi possível obter sua localização.',
        ),
      );
    }
  }

  Future<void> _onGalleryPhotoRequested(
    InspectionGalleryPhotoRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isCapturingPhoto: true, clearError: true));

    try {
      final photoPath = await _deviceService.pickPhotoFromGallery(
        clientId: state.clientId,
      );

      emit(state.copyWith(photoPath: photoPath, isCapturingPhoto: false));
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isCapturingPhoto: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCapturingPhoto: false,
          errorMessage: 'Não foi possível selecionar a foto.',
        ),
      );
    }
  }

  Future<void> _onDraftSaveRequested(
    InspectionDraftSaveRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(
      state.copyWith(
        saveStatus: InspectionFormSaveStatus.saving,
        clearSaveMessage: true,
      ),
    );

    try {
      await _inspectionsRepository.saveDraft(
        clientId: state.clientId,
        workOrderId: state.workOrderId,
        observation: state.observation,
        condition: state.condition,
        photoPath: state.photoPath,
        latitude: state.latitude,
        longitude: state.longitude,
      );

      emit(
        state.copyWith(
          saveStatus: InspectionFormSaveStatus.draftSaved,
          saveMessage: 'Rascunho salvo com sucesso.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: InspectionFormSaveStatus.failure,
          saveMessage: 'Não foi possível salvar o rascunho.',
        ),
      );
    }
  }

  Future<void> _onCompleteRequested(
    InspectionCompleteRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    if (!state.canComplete) {
      emit(
        state.copyWith(
          saveStatus: InspectionFormSaveStatus.failure,
          saveMessage: 'Preencha observação, condição, foto e localização.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        saveStatus: InspectionFormSaveStatus.saving,
        clearSaveMessage: true,
      ),
    );

    try {
      await _inspectionsRepository.savePending(
        clientId: state.clientId,
        workOrderId: state.workOrderId,
        observation: state.observation,
        condition: state.condition,
        photoPath: state.photoPath,
        latitude: state.latitude,
        longitude: state.longitude,
        capturedAt: DateTime.now().toUtc(),
      );

      final syncResult = await _inspectionsRepository.syncInspection(
        state.clientId,
      );

      switch (syncResult) {
        case InspectionSyncResult.synced:
          emit(
            state.copyWith(
              saveStatus: InspectionFormSaveStatus.synced,
              saveMessage: 'Inspeção sincronizada com sucesso.',
            ),
          );

        case InspectionSyncResult.pending:
          emit(
            state.copyWith(
              saveStatus: InspectionFormSaveStatus.pendingSaved,
              saveMessage:
                  'Inspeção salva localmente e aguardando sincronização.',
            ),
          );

        case InspectionSyncResult.failed:
          emit(
            state.copyWith(
              saveStatus: InspectionFormSaveStatus.syncFailed,
              saveMessage: 'Inspeção salva, mas a sincronização falhou.',
            ),
          );
      }
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: InspectionFormSaveStatus.failure,
          saveMessage: 'Não foi possível concluir a inspeção.',
        ),
      );
    }
  }
}
