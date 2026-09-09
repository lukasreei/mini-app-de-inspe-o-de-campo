enum InspectionFormSaveStatus {
  idle,
  saving,
  draftSaved,
  pendingSaved,
  failure,
}

class InspectionFormState {
  const InspectionFormState({
    required this.clientId,
    required this.workOrderId,
    this.observation = '',
    this.condition,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.isCapturingPhoto = false,
    this.isGettingLocation = false,
    this.errorMessage,
    this.saveStatus = InspectionFormSaveStatus.idle,
    this.saveMessage,
  });

  final String clientId;
  final String workOrderId;

  final String observation;
  final String? condition;

  final String? photoPath;

  final double? latitude;
  final double? longitude;

  final bool isCapturingPhoto;
  final bool isGettingLocation;

  final InspectionFormSaveStatus saveStatus;
  final String? saveMessage;

  bool get isSaving => saveStatus == InspectionFormSaveStatus.saving;

  final String? errorMessage;

  bool get hasLocation => latitude != null && longitude != null;

  bool get canComplete =>
      observation.trim().length >= 10 &&
      condition != null &&
      photoPath != null &&
      hasLocation;

  InspectionFormState copyWith({
    String? observation,
    String? condition,
    String? photoPath,
    double? latitude,
    double? longitude,
    bool? isCapturingPhoto,
    bool? isGettingLocation,
    String? errorMessage,
    bool clearError = false,
    InspectionFormSaveStatus? saveStatus,
    String? saveMessage,
    bool clearSaveMessage = false,
  }) {
    return InspectionFormState(
      clientId: clientId,
      workOrderId: workOrderId,
      observation: observation ?? this.observation,
      condition: condition ?? this.condition,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCapturingPhoto: isCapturingPhoto ?? this.isCapturingPhoto,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      saveStatus: saveStatus ?? this.saveStatus,
      saveMessage: clearSaveMessage ? null : saveMessage ?? this.saveMessage,
    );
  }
}
