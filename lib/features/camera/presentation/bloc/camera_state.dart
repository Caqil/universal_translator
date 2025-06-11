
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import '../../domain/entities/ocr_result.dart';

/// Base class for all camera states
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

/// Initial state before camera initialization
class CameraInitialState extends CameraState {
  const CameraInitialState();
}

/// State while camera is being initialized
class CameraInitializingState extends CameraState {
  const CameraInitializingState();
}

/// State when camera is successfully initialized and ready
class CameraReadyState extends CameraState {
  final CameraController controller;
  final List<CameraDescription> availableCameras;
  final CameraDescription currentCamera;
  final FlashMode flashMode;
  final FocusMode focusMode;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final bool isOcrOverlayVisible;
  final OcrResult? lastOcrResult;

  const CameraReadyState({
    required this.controller,
    required this.availableCameras,
    required this.currentCamera,
    this.flashMode = FlashMode.off,
    this.focusMode = FocusMode.auto,
    this.zoomLevel = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 8.0,
    this.isOcrOverlayVisible = false,
    this.lastOcrResult,
  });

  CameraReadyState copyWith({
    CameraController? controller,
    List<CameraDescription>? availableCameras,
    CameraDescription? currentCamera,
    FlashMode? flashMode,
    FocusMode? focusMode,
    double? zoomLevel,
    double? minZoom,
    double? maxZoom,
    bool? isOcrOverlayVisible,
    OcrResult? lastOcrResult,
  }) {
    return CameraReadyState(
      controller: controller ?? this.controller,
      availableCameras: availableCameras ?? this.availableCameras,
      currentCamera: currentCamera ?? this.currentCamera,
      flashMode: flashMode ?? this.flashMode,
      focusMode: focusMode ?? this.focusMode,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      isOcrOverlayVisible: isOcrOverlayVisible ?? this.isOcrOverlayVisible,
      lastOcrResult: lastOcrResult ?? this.lastOcrResult,
    );
  }

  @override
  List<Object?> get props => [
        controller,
        availableCameras,
        currentCamera,
        flashMode,
        focusMode,
        zoomLevel,
        minZoom,
        maxZoom,
        isOcrOverlayVisible,
        lastOcrResult,
      ];
}

/// State when camera fails to initialize
class CameraErrorState extends CameraState {
  final String message;
  final String? errorCode;

  const CameraErrorState({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// State when capturing image
class CameraCapturingState extends CameraState {
  const CameraCapturingState();
}

/// State when image is successfully captured
class CameraImageCapturedState extends CameraState {
  final String imagePath;
  final DateTime captureTime;

  const CameraImageCapturedState({
    required this.imagePath,
    required this.captureTime,
  });

  @override
  List<Object> get props => [imagePath, captureTime];
}

/// State when image capture fails
class CameraCaptureErrorState extends CameraState {
  final String message;
  final String? errorCode;

  const CameraCaptureErrorState({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// State when processing OCR
class CameraProcessingOcrState extends CameraState {
  final String imagePath;

  const CameraProcessingOcrState(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// State when OCR processing is complete
class CameraOcrCompletedState extends CameraState {
  final OcrResult ocrResult;
  final String imagePath;

  const CameraOcrCompletedState({
    required this.ocrResult,
    required this.imagePath,
  });

  @override
  List<Object> get props => [ocrResult, imagePath];
}

/// State when OCR processing fails
class CameraOcrErrorState extends CameraState {
  final String message;
  final String? errorCode;
  final String imagePath;

  const CameraOcrErrorState({
    required this.message,
    this.errorCode,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [message, errorCode, imagePath];
}

/// State when camera permission is denied
class CameraPermissionDeniedState extends CameraState {
  final String message;

  const CameraPermissionDeniedState({
    this.message = 'Camera permission is required to use this feature',
  });

  @override
  List<Object> get props => [message];
}

/// State when camera is paused
class CameraPausedState extends CameraState {
  const CameraPausedState();
}

/// State when switching cameras
class CameraSwitchingState extends CameraState {
  const CameraSwitchingState();
}

/// State when saving image
class CameraSavingImageState extends CameraState {
  final String imagePath;

  const CameraSavingImageState(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// State when image is successfully saved
class CameraImageSavedState extends CameraState {
  final String savedPath;
  final String originalPath;

  const CameraImageSavedState({
    required this.savedPath,
    required this.originalPath,
  });

  @override
  List<Object> get props => [savedPath, originalPath];
}
