import '../models/inspection_draft_model.dart';

class InspectionDraftModel {
  const InspectionDraftModel({
    required this.clientId,
    required this.workOrderId,
    required this.observation,
    required this.condition,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
  });

  final String clientId;
  final String workOrderId;
  final String observation;
  final String? condition;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
}
