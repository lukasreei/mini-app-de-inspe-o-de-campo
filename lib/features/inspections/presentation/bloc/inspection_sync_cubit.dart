import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/inspections_repository.dart';
import 'inspection_sync_state.dart';

class InspectionSyncCubit extends Cubit<InspectionSyncState> {
  InspectionSyncCubit({
    required InspectionsRepository inspectionsRepository,
    Connectivity? connectivity,
  }) : _inspectionsRepository = inspectionsRepository,
       _connectivity = connectivity ?? Connectivity(),
       super(const InspectionSyncState());

  final InspectionsRepository _inspectionsRepository;

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.hasConnectivity) {
        unawaited(syncNow(automatic: true));
      }
    });

    final initial = await _connectivity.checkConnectivity();

    if (initial.hasConnectivity) {
      await syncNow(automatic: true);
    }
  }

  Future<void> syncNow({bool automatic = false}) async {
    if (state.isSyncing) {
      return;
    }

    emit(const InspectionSyncState(status: InspectionSyncUiStatus.syncing));

    try {
      final summary = await _inspectionsRepository.syncPending();

      if (summary.attempted == 0) {
        emit(
          InspectionSyncState(
            status: InspectionSyncUiStatus.idle,
            message: automatic ? null : 'Nenhuma inspeção pendente.',
          ),
        );

        return;
      }

      if (summary.failed > 0) {
        emit(
          InspectionSyncState(
            status: InspectionSyncUiStatus.partialFailure,
            message:
                '${summary.synced} sincronizada(s) e '
                '${summary.failed} com falha.',
          ),
        );

        return;
      }

      if (summary.pending > 0) {
        emit(
          InspectionSyncState(
            status: InspectionSyncUiStatus.partialFailure,
            message: automatic
                ? null
                : '${summary.pending} inspeção(ões) '
                      'continuam pendentes.',
          ),
        );

        return;
      }

      emit(
        InspectionSyncState(
          status: InspectionSyncUiStatus.success,
          message:
              '${summary.synced} inspeção(ões) '
              'sincronizada(s) com sucesso.',
        ),
      );
    } catch (_) {
      emit(
        InspectionSyncState(
          status: InspectionSyncUiStatus.failure,
          message: automatic
              ? null
              : 'Não foi possível sincronizar '
                    'as inspeções.',
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
