import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class InspectionLocation {
  const InspectionLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class InspectionDeviceException implements Exception {
  const InspectionDeviceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InspectionDeviceService {
  InspectionDeviceService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> capturePhoto({required String clientId}) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    return _persistImage(image: image, clientId: clientId);
  }

  Future<String?> pickPhotoFromGallery({required String clientId}) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    return _persistImage(image: image, clientId: clientId);
  }

  Future<String?> _persistImage({
    required XFile? image,
    required String clientId,
  }) async {
    if (image == null) {
      return null;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();

    final inspectionsDirectory = Directory(
      '${documentsDirectory.path}/inspections',
    );

    if (!await inspectionsDirectory.exists()) {
      await inspectionsDirectory.create(recursive: true);
    }

    final extension = image.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';

    final destination = File(
      '${inspectionsDirectory.path}/$clientId.$extension',
    );

    await File(image.path).copy(destination.path);

    return destination.path;
  }

  Future<InspectionLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const InspectionDeviceException(
        'Ative a localização do dispositivo.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const InspectionDeviceException('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const InspectionDeviceException(
        'A permissão de localização foi negada permanentemente. '
        'Libere o acesso nas configurações do aplicativo.',
      );
    }

    final position = await Geolocator.getCurrentPosition();

    return InspectionLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
