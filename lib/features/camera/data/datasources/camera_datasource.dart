import 'dart:io';
import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../core/error/exceptions.dart' as ex;
import '../../../../core/services/injection_container.dart';

abstract class CameraDataSource {
  Future<CameraController> initializeCamera();
  Future<String> captureImage(CameraController controller);
  Future<String?> selectImageFromGallery();
}

@LazySingleton(as: CameraDataSource)
class CameraDataSourceImpl implements CameraDataSource {
  // Use sl() to get dependencies instead of constructor injection for these
  ImagePicker get _imagePicker => sl<ImagePicker>();
  List<CameraDescription> get _cameras => sl<List<CameraDescription>>();

  @override
  Future<CameraController> initializeCamera() async {
    try {
      if (_cameras.isEmpty) {
        throw ex.CameraException.notAvailable();
      }

      final camera = _cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      return controller;
    } catch (e) {
      if (e is CameraException) {
        rethrow;
      }
      throw ex.CameraException.initializationFailed(e.toString());
    }
  }

  @override
  Future<String> captureImage(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        throw ex.CameraException.captureFailed('Camera not initialized');
      }

      final directory = await getTemporaryDirectory();
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      final image = await controller.takePicture();

      // Copy the image to our desired location
      final file = File(image.path);
      await file.copy(filePath);

      return filePath;
    } catch (e) {
      throw ex.CameraException.captureFailed(e.toString());
    }
  }

  @override
  Future<String?> selectImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      return image?.path;
    } catch (e) {
      throw ex.CameraException.captureFailed(e.toString());
    }
  }
}
