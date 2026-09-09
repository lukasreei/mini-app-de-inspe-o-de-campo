import '../datasources/work_orders_remote_data_source.dart';
import '../models/work_order_model.dart';

class WorkOrdersRepository {
  WorkOrdersRepository({required WorkOrdersRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final WorkOrdersRemoteDataSource _remoteDataSource;

  Future<List<WorkOrderModel>> getWorkOrders() {
    return _remoteDataSource.getWorkOrders();
  }

  Future<WorkOrderModel> getWorkOrderById(String id) {
    return _remoteDataSource.getWorkOrderById(id);
  }
}
