import '../../data/models/work_order_model.dart';

sealed class WorkOrderDetailState {
  const WorkOrderDetailState();
}

final class WorkOrderDetailInitial extends WorkOrderDetailState {
  const WorkOrderDetailInitial();
}

final class WorkOrderDetailLoading extends WorkOrderDetailState {
  const WorkOrderDetailLoading();
}

final class WorkOrderDetailLoaded extends WorkOrderDetailState {
  const WorkOrderDetailLoaded({required this.workOrder});

  final WorkOrderModel workOrder;
}

final class WorkOrderDetailFailure extends WorkOrderDetailState {
  const WorkOrderDetailFailure({required this.message});

  final String message;
}
