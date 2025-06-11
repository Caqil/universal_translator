
import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import '../../../../core/error/failures.dart';
import '../entities/ocr_result.dart';

/// Abstract repository for camera operations
abstract class CameraRepository {
  /// Get list of available cameras on the device
  Future<Either<CameraFailure, List<CameraDescription>>> getAvailableCameras();

  /// Initialize camera with given description
  Future<Either<CameraFailure, CameraController>> initializeCamera(
    CameraDescription camera,
  );

  /// Capture image and return the file path
  Future<Either<CameraFailure, String>> captureImage(
    CameraController controller,
  );

  /// Process image for OCR text recognition
  Future<Either<OcrFailure, OcrResult>> processImageForOcr(String imagePath);

  /// Get camera permissions status
  Future<Either<CameraFailure, bool>> checkCameraPermission();

  /// Request camera permissions
  Future<Either<CameraFailure, bool>> requestCameraPermission();

  /// Save captured image to gallery/storage
  Future<Either<CameraFailure, String>> saveImageToGallery(String imagePath);

  /// Get camera capabilities (zoom, flash, etc.)
  Future<Either<CameraFailure, CameraCapabilities>> getCameraCapabilities(
    CameraController controller,
  );

  /// Set camera zoom level
  Future<Either<CameraFailure, void>> setZoomLevel(
    CameraController controller,
    double zoomLevel,
  );

  /// Set camera flash mode
  Future<Either<CameraFailure, void>> setFlashMode(
    CameraController controller,
    FlashMode flashMode,
  );

  /// Set camera focus mode
  Future<Either<CameraFailure, void>> setFocusMode(
    CameraController controller,
    FocusMode focusMode,
  );

  /// Set focus point on camera
  Future<Either<CameraFailure, void>> setFocusPoint(
    CameraController controller,
    Offset point,
  );

  /// Dispose camera controller
  Future<Either<CameraFailure, void>> disposeCamera(
      CameraController controller);
}

/// Camera capabilities data class
class CameraCapabilities {
  final double minZoomLevel;
  final double maxZoomLevel;
  final List<FlashMode> supportedFlashModes;
  final List<FocusMode> supportedFocusModes;
  final bool hasFlash;
  final bool canZoom;
  final bool canFocus;

  const CameraCapabilities({
    required this.minZoomLevel,
    required this.maxZoomLevel,
    required this.supportedFlashModes,
    required this.supportedFocusModes,
    required this.hasFlash,
    required this.canZoom,
    required this.canFocus,
  });

  factory CameraCapabilities.defaults() {
    return const CameraCapabilities(
      minZoomLevel: 1.0,
      maxZoomLevel: 8.0,
      supportedFlashModes: [FlashMode.off, FlashMode.auto, FlashMode.always],
      supportedFocusModes: [FocusMode.auto, FocusMode.locked],
      hasFlash: true,
      canZoom: true,
      canFocus: true,
    );
  }
}

/// Simple Offset class for focus points
class Offset {
  final double dx;
  final double dy;

  const Offset(this.dx, this.dy);
}
