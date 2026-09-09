class InspectionSyncSummary {
  const InspectionSyncSummary({
    required this.attempted,
    required this.synced,
    required this.pending,
    required this.failed,
  });

  final int attempted;
  final int synced;
  final int pending;
  final int failed;
}
