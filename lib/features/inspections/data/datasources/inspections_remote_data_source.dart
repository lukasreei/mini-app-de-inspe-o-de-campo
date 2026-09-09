import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';

class InspectionUploadResponse {
  const InspectionUploadResponse({required this.serverId});

  final String serverId;
}

class InspectionsRemoteDataSource {
  InspectionsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<InspectionUploadResponse> uploadInspection(
    LocalInspection inspection,
  ) async {
    final photoPath = inspection.photoPath;
    final capturedAt = inspection.capturedAt;

    if (photoPath == null || photoPath.isEmpty) {
      throw StateError('A inspeção não possui foto.');
    }

    if (capturedAt == null) {
      throw StateError('A inspeção não possui data de captura.');
    }

    final photoFile = File(photoPath);

    if (!await photoFile.exists()) {
      throw StateError('A foto da inspeção não foi encontrada.');
    }

    final formData = FormData.fromMap({
      'clientId': inspection.clientId,
      'workOrderId': inspection.workOrderId,
      'observation': inspection.observation,
      'condition': inspection.condition,
      'latitude': inspection.latitude,
      'longitude': inspection.longitude,
      'capturedAt': capturedAt.toUtc().toIso8601String(),
      'photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _apiClient.dio.post('/inspections', data: formData);

    final data = response.data;

    if (data is! Map || data['id'] == null) {
      throw StateError('Resposta inválida da API.');
    }

    return InspectionUploadResponse(serverId: data['id'].toString());
  }
}
