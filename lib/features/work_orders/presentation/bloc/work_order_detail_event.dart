sealed class WorkOrderDetailEvent {
  const WorkOrderDetailEvent();
}

final class WorkOrderDetailRequested extends WorkOrderDetailEvent {
  const WorkOrderDetailRequested({required this.workOrderId});

  final String workOrderId;
}
