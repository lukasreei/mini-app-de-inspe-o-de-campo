import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/inspection_sync_result.dart';
import '../../data/repositories/inspections_repository.dart';
import 'inspection_history_state.dart';

class InspectionHistoryCubit extends Cubit<InspectionHistoryState> {
  InspectionHistoryCubit({required InspectionsRepository inspectionsRepository})
    : _inspectionsRepository = inspectionsRepository,
      super(const InspectionHistoryState());

  final InspectionsRepository _inspectionsRepository;

  StreamSubscription? _subscription;

  void start() {
    _subscription = _inspectionsRepository.watchAll().listen(
      (inspections) {
        emit(state.copyWith(inspections: inspections));
      },
      onError: (_) {
        emit(state.copyWith(message: 'Não foi possível carregar o histórico.'));
      },
    );
  }

  void setFilter(InspectionHistoryFilter filter) {
    emit(state.copyWith(filter: filter, clearMessage: true));
  }

  Future<void> retry(String clientId) async {
    if (state.retryingClientId != null) {
      return;
    }

    emit(state.copyWith(retryingClientId: clientId, clearMessage: true));

    try {
      final result = await _inspectionsRepository.syncInspection(clientId);

      switch (result) {
        case InspectionSyncResult.synced:
          emit(
            state.copyWith(
              clearRetryingClientId: true,
              message: 'Inspeção sincronizada com sucesso.',
            ),
          );
          break;

        case InspectionSyncResult.pending:
          emit(
            state.copyWith(
              clearRetryingClientId: true,
              message: 'Servidor indisponível. A inspeção continua pendente.',
            ),
          );
          break;

        case InspectionSyncResult.failed:
          emit(
            state.copyWith(
              clearRetryingClientId: true,
              message: 'A sincronização falhou novamente.',
            ),
          );
          break;
      }
    } catch (_) {
      emit(
        state.copyWith(
          clearRetryingClientId: true,
          message: 'Não foi possível tentar novamente.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
