sealed class WorkOrdersEvent {
  const WorkOrdersEvent();
}

final class WorkOrdersRequested extends WorkOrdersEvent {
  const WorkOrdersRequested();
}

final class WorkOrdersRefreshed extends WorkOrdersEvent {
  const WorkOrdersRefreshed();
}
