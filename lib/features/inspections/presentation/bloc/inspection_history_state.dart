import '../../../../core/database/app_database.dart';

enum InspectionHistoryFilter { all, draft, pending, synced, failed }

class InspectionHistoryState {
  const InspectionHistoryState({
    this.inspections = const [],
    this.filter = InspectionHistoryFilter.all,
    this.retryingClientId,
    this.message,
  });

  final List<LocalInspection> inspections;
  final InspectionHistoryFilter filter;
  final String? retryingClientId;
  final String? message;

  List<LocalInspection> get filteredInspections {
    if (filter == InspectionHistoryFilter.all) {
      return inspections;
    }

    return inspections
        .where((inspection) => inspection.syncStatus == filter.name)
        .toList();
  }

  InspectionHistoryState copyWith({
    List<LocalInspection>? inspections,
    InspectionHistoryFilter? filter,
    String? retryingClientId,
    bool clearRetryingClientId = false,
    String? message,
    bool clearMessage = false,
  }) {
    return InspectionHistoryState(
      inspections: inspections ?? this.inspections,
      filter: filter ?? this.filter,
      retryingClientId: clearRetryingClientId
          ? null
          : retryingClientId ?? this.retryingClientId,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
