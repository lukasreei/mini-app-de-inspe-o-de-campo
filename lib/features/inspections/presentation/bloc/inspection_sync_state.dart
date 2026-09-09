enum InspectionSyncUiStatus { idle, syncing, success, partialFailure, failure }

class InspectionSyncState {
  const InspectionSyncState({
    this.status = InspectionSyncUiStatus.idle,
    this.message,
  });

  final InspectionSyncUiStatus status;
  final String? message;

  bool get isSyncing => status == InspectionSyncUiStatus.syncing;
}
