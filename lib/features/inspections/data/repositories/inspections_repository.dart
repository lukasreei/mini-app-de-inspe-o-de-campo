import '../../../../core/database/app_database.dart';
import '../datasources/inspections_local_data_source.dart';
import '../models/inspection_sync_status.dart';
import '../models/inspection_draft_model.dart';

import 'package:dio/dio.dart';

import '../datasources/inspections_remote_data_source.dart';
import '../models/inspection_sync_result.dart';

class InspectionsRepository {
  InspectionsRepository({
    required InspectionsLocalDataSource localDataSource,
    required InspectionsRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final InspectionsLocalDataSource _localDataSource;

  final InspectionsRemoteDataSource _remoteDataSource;

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

  Future<InspectionSyncResult> syncInspection(String clientId) async {
    final inspection = await _localDataSource.getByClientId(clientId);

    if (inspection == null) {
      return InspectionSyncResult.failed;
    }

    await _localDataSource.registerSyncAttempt(clientId);

    try {
      final response = await _remoteDataSource.uploadInspection(inspection);

      await _localDataSource.markSynced(
        clientId: clientId,
        serverId: response.serverId,
      );

      return InspectionSyncResult.synced;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      final message = _dioErrorMessage(error);

      if (statusCode == null ||
          statusCode >= 500 ||
          statusCode == 401 ||
          statusCode == 408 ||
          statusCode == 429) {
        await _localDataSource.markPending(
          clientId: clientId,
          errorMessage: message,
        );

        return InspectionSyncResult.pending;
      }

      await _localDataSource.markFailed(
        clientId: clientId,
        errorMessage: message,
      );

      return InspectionSyncResult.failed;
    } catch (error) {
      await _localDataSource.markFailed(
        clientId: clientId,
        errorMessage: error.toString(),
      );

      return InspectionSyncResult.failed;
    }
  }

  Future<void> syncPending() async {
    final inspections = await _localDataSource.getPending();

    for (final inspection in inspections) {
      await syncInspection(inspection.clientId);
    }
  }

  String _dioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (error.response == null) {
      return 'Sem conexão com o servidor.';
    }

    return 'Erro ao sincronizar inspeção.';
  }
}
