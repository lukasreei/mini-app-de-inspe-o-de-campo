import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/services/inspection_device_service.dart';
import 'inspection_form_event.dart';
import 'inspection_form_state.dart';

class InspectionFormBloc
    extends Bloc<InspectionFormEvent, InspectionFormState> {
  InspectionFormBloc({
    required String workOrderId,
    required InspectionDeviceService deviceService,
    Uuid? uuid,
  }) : _deviceService = deviceService,
       super(
         InspectionFormState(
           clientId: (uuid ?? const Uuid()).v4(),
           workOrderId: workOrderId,
         ),
       ) {
    on<InspectionObservationChanged>(_onObservationChanged);

    on<InspectionConditionChanged>(_onConditionChanged);

    on<InspectionPhotoRequested>(_onPhotoRequested);

    on<InspectionLocationRequested>(_onLocationRequested);

    on<InspectionGalleryPhotoRequested>(_onGalleryPhotoRequested);
  }

  final InspectionDeviceService _deviceService;

  void _onObservationChanged(
    InspectionObservationChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(observation: event.observation, clearError: true));
  }

  void _onConditionChanged(
    InspectionConditionChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(condition: event.condition, clearError: true));
  }

  Future<void> _onPhotoRequested(
    InspectionPhotoRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isCapturingPhoto: true, clearError: true));

    try {
      final photoPath = await _deviceService.capturePhoto(
        clientId: state.clientId,
      );

      emit(state.copyWith(photoPath: photoPath, isCapturingPhoto: false));
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isCapturingPhoto: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCapturingPhoto: false,
          errorMessage: 'Não foi possível capturar a foto.',
        ),
      );
    }
  }

  Future<void> _onLocationRequested(
    InspectionLocationRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isGettingLocation: true, clearError: true));

    try {
      final location = await _deviceService.getCurrentLocation();

      emit(
        state.copyWith(
          latitude: location.latitude,
          longitude: location.longitude,
          isGettingLocation: false,
        ),
      );
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isGettingLocation: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isGettingLocation: false,
          errorMessage: 'Não foi possível obter sua localização.',
        ),
      );
    }
  }

  Future<void> _onGalleryPhotoRequested(
    InspectionGalleryPhotoRequested event,
    Emitter<InspectionFormState> emit,
  ) async {
    emit(state.copyWith(isCapturingPhoto: true, clearError: true));

    try {
      final photoPath = await _deviceService.pickPhotoFromGallery(
        clientId: state.clientId,
      );

      emit(state.copyWith(photoPath: photoPath, isCapturingPhoto: false));
    } on InspectionDeviceException catch (error) {
      emit(
        state.copyWith(isCapturingPhoto: false, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCapturingPhoto: false,
          errorMessage: 'Não foi possível selecionar a foto.',
        ),
      );
    }
  }
}
