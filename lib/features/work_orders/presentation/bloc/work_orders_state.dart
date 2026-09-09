import '../../data/models/work_order_model.dart';

sealed class WorkOrdersState {
  const WorkOrdersState();
}

final class WorkOrdersInitial extends WorkOrdersState {
  const WorkOrdersInitial();
}

final class WorkOrdersLoading extends WorkOrdersState {
  const WorkOrdersLoading();
}

final class WorkOrdersLoaded extends WorkOrdersState {
  const WorkOrdersLoaded({required this.workOrders});

  final List<WorkOrderModel> workOrders;
}

final class WorkOrdersEmpty extends WorkOrdersState {
  const WorkOrdersEmpty();
}

final class WorkOrdersFailure extends WorkOrdersState {
  const WorkOrdersFailure({required this.message});

  final String message;
}
