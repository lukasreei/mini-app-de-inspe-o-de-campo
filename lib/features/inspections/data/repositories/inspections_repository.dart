import '../../../../core/database/app_database.dart';
import '../datasources/inspections_local_data_source.dart';
import '../models/inspection_sync_status.dart';

class InspectionsRepository {
  InspectionsRepository({required InspectionsLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final InspectionsLocalDataSource _localDataSource;

  Future<void> saveDraft({
    required String clientId,
    required String workOrderId,
    required String observation,
    required String? condition,
    required String? photoPath,
    required double? latitude,
    required double? longitude,
  }) {
    return _localDataSource.save(
      clientId: clientId,
      workOrderId: workOrderId,
      observation: observation,
      condition: condition,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
      syncStatus: InspectionSyncStatus.draft,
    );
  }

  Future<void> savePending({
    required String clientId,
    required String workOrderId,
    required String observation,
    required String? condition,
    required String? photoPath,
    required double? latitude,
    required double? longitude,
    required DateTime capturedAt,
  }) {
    return _localDataSource.save(
      clientId: clientId,
      workOrderId: workOrderId,
      observation: observation,
      condition: condition,
      photoPath: photoPath,
      latitude: latitude,
      longitude: longitude,
      capturedAt: capturedAt,
      syncStatus: InspectionSyncStatus.pending,
    );
  }

  Future<List<LocalInspection>> getAll() {
    return _localDataSource.getAll();
  }

  Stream<List<LocalInspection>> watchAll() {
    return _localDataSource.watchAll();
  }
}
