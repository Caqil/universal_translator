// lib/features/camera/data/repositories/camera_repository_impl.dart
import 'dart:ui' as flutter;

import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/entities/ocr_result.dart';
import '../datasources/ocr_datasource.dart';
import '../datasources/ocr_datasource_impl.dart';

/// Implementation of camera repository
class CameraRepositoryImpl implements CameraRepository {
  final OcrDataSource ocrDataSource;

  const CameraRepositoryImpl({
    required this.ocrDataSource,
  });

  @override
  Future<Either<CameraFailure, List<CameraDescription>>>
      getAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      return Right(cameras);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to get available cameras: $e',
        code: 'CAMERA_LIST_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, CameraController>> initializeCamera(
    CameraDescription camera,
  ) async {
    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      return Right(controller);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to initialize camera: $e',
        code: 'CAMERA_INIT_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, String>> captureImage(
    CameraController controller,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      // Get temporary directory for saving images
      final tempDir = await getTemporaryDirectory();
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(tempDir.path, fileName);

      // Capture the image
      final XFile imageFile = await controller.takePicture();

      // Copy to our desired location
      await File(imageFile.path).copy(filePath);

      return Right(filePath);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to capture image: $e',
        code: 'CAMERA_CAPTURE_ERROR',
      ));
    }
  }

  @override
  Future<Either<OcrFailure, OcrResult>> processImageForOcr(
      String imagePath) async {
    try {
      final ocrResultModel =
          await ocrDataSource.extractTextFromImage(imagePath);
      return Right(ocrResultModel.toEntity());
    } on OcrException catch (e) {
      return Left(OcrFailure.fromException(e));
    } catch (e) {
      return Left(OcrFailure(
        message: 'Failed to process image for OCR: $e',
        code: 'OCR_PROCESSING_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, bool>> checkCameraPermission() async {
    try {
      final permission = await Permission.camera.status;
      return Right(permission.isGranted);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to check camera permission: $e',
        code: 'PERMISSION_CHECK_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, bool>> requestCameraPermission() async {
    try {
      final permission = await Permission.camera.request();
      return Right(permission.isGranted);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to request camera permission: $e',
        code: 'PERMISSION_REQUEST_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, String>> saveImageToGallery(
      String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return Left(CameraFailure(
          message: 'Image file does not exist',
          code: 'FILE_NOT_FOUND',
        ));
      }

      // Get documents directory for permanent storage
      final documentsDir = await getApplicationDocumentsDirectory();
      final savedImagesDir =
          Directory(path.join(documentsDir.path, 'saved_images'));

      // Create directory if it doesn't exist
      if (!await savedImagesDir.exists()) {
        await savedImagesDir.create(recursive: true);
      }

      final fileName = 'saved_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(savedImagesDir.path, fileName);

      // Copy image to permanent location
      await file.copy(savedPath);

      return Right(savedPath);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to save image: $e',
        code: 'IMAGE_SAVE_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, CameraCapabilities>> getCameraCapabilities(
    CameraController controller,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      // Get zoom capabilities
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      // For now, assume standard capabilities
      // In a real implementation, you'd query the actual camera capabilities
      final capabilities = CameraCapabilities(
        minZoomLevel: minZoom,
        maxZoomLevel: maxZoom,
        supportedFlashModes: const [
          FlashMode.off,
          FlashMode.auto,
          FlashMode.always,
          FlashMode.torch,
        ],
        supportedFocusModes: const [
          FocusMode.auto,
          FocusMode.locked,
        ],
        hasFlash: true, // Assume most cameras have flash
        canZoom: maxZoom > minZoom,
        canFocus: true,
      );

      return Right(capabilities);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to get camera capabilities: $e',
        code: 'CAMERA_CAPABILITIES_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, void>> setZoomLevel(
    CameraController controller,
    double zoomLevel,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      await controller.setZoomLevel(zoomLevel);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to set zoom level: $e',
        code: 'ZOOM_SET_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, void>> setFlashMode(
    CameraController controller,
    FlashMode flashMode,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      await controller.setFlashMode(flashMode);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to set flash mode: $e',
        code: 'FLASH_SET_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, void>> setFocusMode(
    CameraController controller,
    FocusMode focusMode,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      await controller.setFocusMode(focusMode);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to set focus mode: $e',
        code: 'FOCUS_SET_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, void>> setFocusPoint(
    CameraController controller,
    Offset point,
  ) async {
    try {
      if (!controller.value.isInitialized) {
        return Left(CameraFailure(
          message: 'Camera is not initialized',
          code: 'CAMERA_NOT_INITIALIZED',
        ));
      }

      // Convert our Offset to Flutter's Offset
      final flutterOffset = flutter.Offset(point.dx, point.dy);
      await controller.setFocusPoint(flutterOffset);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to set focus point: $e',
        code: 'FOCUS_POINT_SET_ERROR',
      ));
    }
  }

  @override
  Future<Either<CameraFailure, void>> disposeCamera(
      CameraController controller) async {
    try {
      if (controller.value.isInitialized) {
        await controller.dispose();
      }
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure(
        message: 'Failed to dispose camera: $e',
        code: 'CAMERA_DISPOSE_ERROR',
      ));
    }
  }
}
