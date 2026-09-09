sealed class InspectionFormEvent {
  const InspectionFormEvent();
}

final class InspectionObservationChanged extends InspectionFormEvent {
  const InspectionObservationChanged(this.observation);

  final String observation;
}

final class InspectionConditionChanged extends InspectionFormEvent {
  const InspectionConditionChanged(this.condition);

  final String condition;
}

final class InspectionPhotoRequested extends InspectionFormEvent {
  const InspectionPhotoRequested();
}

final class InspectionLocationRequested extends InspectionFormEvent {
  const InspectionLocationRequested();
}

final class InspectionGalleryPhotoRequested extends InspectionFormEvent {
  const InspectionGalleryPhotoRequested();
}

final class InspectionDraftSaveRequested extends InspectionFormEvent {
  const InspectionDraftSaveRequested();
}

final class InspectionCompleteRequested extends InspectionFormEvent {
  const InspectionCompleteRequested();
}
