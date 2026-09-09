import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/work_order_model.dart';

class WorkOrdersLocalDataSource {
  WorkOrdersLocalDataSource({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  Future<void> replaceAll(List<WorkOrderModel> workOrders) async {
    await _database.transaction(() async {
      await _database.delete(_database.cachedWorkOrders).go();

      for (final workOrder in workOrders) {
        await save(workOrder);
      }
    });
  }

  Future<void> save(WorkOrderModel workOrder) async {
    await _database
        .into(_database.cachedWorkOrders)
        .insertOnConflictUpdate(
          CachedWorkOrdersCompanion(
            id: Value(workOrder.id),
            code: Value(workOrder.code),
            title: Value(workOrder.title),
            description: Value(workOrder.description),
            address: Value(workOrder.address),
            priority: Value(workOrder.priority),
            status: Value(workOrder.status),
            latitude: Value(workOrder.latitude),
            longitude: Value(workOrder.longitude),
            scheduledAt: Value(workOrder.scheduledAt),
            updatedAt: Value(workOrder.updatedAt),
            notes: Value(workOrder.notes),
          ),
        );
  }

  Future<List<WorkOrderModel>> getAll() async {
    final items = await (_database.select(
      _database.cachedWorkOrders,
    )..orderBy([(table) => OrderingTerm.asc(table.scheduledAt)])).get();

    return items.map(_toModel).toList();
  }

  Future<WorkOrderModel?> getById(String id) async {
    final item = await (_database.select(
      _database.cachedWorkOrders,
    )..where((table) => table.id.equals(id))).getSingleOrNull();

    if (item == null) {
      return null;
    }

    return _toModel(item);
  }

  WorkOrderModel _toModel(LocalWorkOrder item) {
    return WorkOrderModel(
      id: item.id,
      code: item.code,
      title: item.title,
      description: item.description,
      address: item.address,
      priority: item.priority,
      status: item.status,
      latitude: item.latitude,
      longitude: item.longitude,
      scheduledAt: item.scheduledAt,
      updatedAt: item.updatedAt,
      notes: item.notes,
    );
  }
}
