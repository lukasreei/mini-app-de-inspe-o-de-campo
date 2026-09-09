import '../../../../core/database/app_database.dart';
import '../datasources/inspections_local_data_source.dart';
import '../models/inspection_sync_status.dart';
import '../models/inspection_draft_model.dart';

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

  Future<InspectionDraftModel?> getDraftForWorkOrder(String workOrderId) async {
    final inspection = await _localDataSource.getLatestDraftByWorkOrderId(
      workOrderId,
    );

    if (inspection == null) {
      return null;
    }

    return InspectionDraftModel(
      clientId: inspection.clientId,
      workOrderId: inspection.workOrderId,
      observation: inspection.observation ?? '',
      condition: inspection.condition,
      photoPath: inspection.photoPath,
      latitude: inspection.latitude,
      longitude: inspection.longitude,
    );
  }
}
