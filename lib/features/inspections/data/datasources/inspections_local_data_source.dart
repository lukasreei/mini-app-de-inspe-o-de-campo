import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/inspection_sync_status.dart';

class InspectionsLocalDataSource {
  InspectionsLocalDataSource({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  Future<LocalInspection?> getByClientId(String clientId) {
    return (_database.select(
      _database.inspections,
    )..where((table) => table.clientId.equals(clientId))).getSingleOrNull();
  }

  Future<void> save({
    required String clientId,
    required String workOrderId,
    required String observation,
    required String? condition,
    required String? photoPath,
    required double? latitude,
    required double? longitude,
    required InspectionSyncStatus syncStatus,
    DateTime? capturedAt,
  }) async {
    final existing = await getByClientId(clientId);

    final now = DateTime.now();

    final inspection = InspectionsCompanion(
      clientId: Value(clientId),
      workOrderId: Value(workOrderId),
      observation: Value(
        observation.trim().isEmpty ? null : observation.trim(),
      ),
      condition: Value(condition),
      photoPath: Value(photoPath),
      latitude: Value(latitude),
      longitude: Value(longitude),
      capturedAt: Value(capturedAt),
      syncStatus: Value(syncStatus.name),
      serverId: Value(existing?.serverId),
      errorMessage: const Value(null),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
      syncedAt: Value(existing?.syncedAt),
      syncAttempts: Value(existing?.syncAttempts ?? 0),
      lastSyncAttemptAt: Value(existing?.lastSyncAttemptAt),
    );

    await _database
        .into(_database.inspections)
        .insertOnConflictUpdate(inspection);
  }

  Future<List<LocalInspection>> getAll() {
    return (_database.select(
      _database.inspections,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).get();
  }

  Stream<List<LocalInspection>> watchAll() {
    return (_database.select(
      _database.inspections,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])).watch();
  }

  Future<LocalInspection?> getLatestDraftByWorkOrderId(String workOrderId) {
    return (_database.select(_database.inspections)
          ..where(
            (table) =>
                table.workOrderId.equals(workOrderId) &
                table.syncStatus.equals(InspectionSyncStatus.draft.name),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<LocalInspection>> getPending() {
    return (_database.select(_database.inspections)..where(
          (table) => table.syncStatus.equals(InspectionSyncStatus.pending.name),
        ))
        .get();
  }

  Future<void> registerSyncAttempt(String clientId) async {
    final inspection = await getByClientId(clientId);

    if (inspection == null) {
      return;
    }

    final now = DateTime.now();

    await (_database.update(
      _database.inspections,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionsCompanion(
        syncAttempts: Value(inspection.syncAttempts + 1),
        lastSyncAttemptAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markSynced({
    required String clientId,
    required String serverId,
  }) async {
    final now = DateTime.now();

    await (_database.update(
      _database.inspections,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionsCompanion(
        syncStatus: Value(InspectionSyncStatus.synced.name),
        serverId: Value(serverId),
        errorMessage: const Value(null),
        syncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markPending({
    required String clientId,
    String? errorMessage,
  }) async {
    await (_database.update(
      _database.inspections,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionsCompanion(
        syncStatus: Value(InspectionSyncStatus.pending.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markFailed({
    required String clientId,
    required String errorMessage,
  }) async {
    await (_database.update(
      _database.inspections,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionsCompanion(
        syncStatus: Value(InspectionSyncStatus.failed.name),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
