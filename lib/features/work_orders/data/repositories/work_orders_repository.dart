import 'package:dio/dio.dart';

import '../datasources/work_orders_local_data_source.dart';
import '../datasources/work_orders_remote_data_source.dart';
import '../models/work_order_model.dart';

class WorkOrdersRepository {
  WorkOrdersRepository({
    required WorkOrdersRemoteDataSource remoteDataSource,
    required WorkOrdersLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final WorkOrdersRemoteDataSource _remoteDataSource;

  final WorkOrdersLocalDataSource _localDataSource;

  Future<List<WorkOrderModel>> getWorkOrders() async {
    try {
      final workOrders = await _remoteDataSource.getWorkOrders();

      await _localDataSource.replaceAll(workOrders);

      return workOrders;
    } on DioException {
      final cached = await _localDataSource.getAll();

      if (cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  Future<WorkOrderModel> getWorkOrderById(String id) async {
    try {
      final workOrder = await _remoteDataSource.getWorkOrderById(id);

      await _localDataSource.save(workOrder);

      return workOrder;
    } on DioException {
      final cached = await _localDataSource.getById(id);

      if (cached != null) {
        return cached;
      }

      rethrow;
    }
  }
}
