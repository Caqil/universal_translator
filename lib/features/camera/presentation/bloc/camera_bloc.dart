// lib/features/camera/presentation/bloc/camera_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/entities/ocr_result.dart';
import 'camera_event.dart' hide Offset;
import 'camera_state.dart';

/// BLoC for managing camera functionality and OCR operations
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraRepository cameraRepository;

  CameraController? _currentController;
  List<CameraDescription> _availableCameras = [];
  CameraDescription? _currentCamera;

  CameraBloc({
    required this.cameraRepository,
  }) : super(const CameraInitialState()) {
    // Register event handlers
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<SwitchCameraEvent>(_onSwitchCamera);
    on<ToggleFlashEvent>(_onToggleFlash);
    on<CaptureImageEvent>(_onCaptureImage);
    on<ProcessOcrEvent>(_onProcessOcr);
    on<ToggleOcrOverlayEvent>(_onToggleOcrOverlay);
    on<DisposeCameraEvent>(_onDisposeCamera);
    on<ResumeCameraEvent>(_onResumeCamera);
    on<PauseCameraEvent>(_onPauseCamera);
    on<ZoomCameraEvent>(_onZoomCamera);
    on<ToggleFocusModeEvent>(_onToggleFocusMode);
    on<SetFocusPointEvent>(_onSetFocusPoint);
    on<RequestCameraPermissionEvent>(_onRequestCameraPermission);
    on<RetryCameraInitializationEvent>(_onRetryCameraInitialization);
    on<ClearOcrResultsEvent>(_onClearOcrResults);
    on<SaveImageEvent>(_onSaveImage);
  }

  /// Initialize camera
  Future<void> _onInitializeCamera(
    InitializeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(const CameraInitializingState());

    try {
      // Check camera permission first
      final permissionResult = await cameraRepository.checkCameraPermission();

      permissionResult.fold(
        (failure) => emit(CameraErrorState(
          message: failure.message,
          errorCode: failure.code,
        )),
        (hasPermission) async {
          if (!hasPermission) {
            emit(const CameraPermissionDeniedState());
            return;
          }

          // Get available cameras
          final camerasResult = await cameraRepository.getAvailableCameras();

          camerasResult.fold(
            (failure) => emit(CameraErrorState(
              message: failure.message,
              errorCode: failure.code,
            )),
            (cameras) async {
              if (cameras.isEmpty) {
                emit(const CameraErrorState(
                  message: 'No cameras available on this device',
                  errorCode: 'NO_CAMERAS',
                ));
                return;
              }

              _availableCameras = cameras;

              // Select camera (prefer back camera, or use provided preference)
              CameraDescription selectedCamera;
              if (event.preferredCamera != null) {
                selectedCamera = event.preferredCamera!;
              } else {
                selectedCamera = cameras.firstWhere(
                  (camera) => camera.lensDirection == CameraLensDirection.back,
                  orElse: () => cameras.first,
                );
              }

              _currentCamera = selectedCamera;

              // Initialize camera controller
              final controllerResult =
                  await cameraRepository.initializeCamera(selectedCamera);

              controllerResult.fold(
                (failure) => emit(CameraErrorState(
                  message: failure.message,
                  errorCode: failure.code,
                )),
                (controller) async {
                  _currentController = controller;

                  // Get camera capabilities
                  final capabilitiesResult =
                      await cameraRepository.getCameraCapabilities(controller);

                  capabilitiesResult.fold(
                    (failure) {
                      // Use default capabilities if we can't get them
                      emit(CameraReadyState(
                        controller: controller,
                        availableCameras: cameras,
                        currentCamera: selectedCamera,
                      ));
                    },
                    (capabilities) {
                      emit(CameraReadyState(
                        controller: controller,
                        availableCameras: cameras,
                        currentCamera: selectedCamera,
                        minZoom: capabilities.minZoomLevel,
                        maxZoom: capabilities.maxZoomLevel,
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(CameraErrorState(
        message: 'Unexpected error during camera initialization: $e',
        errorCode: 'UNEXPECTED_ERROR',
      ));
    }
  }

  /// Switch between available cameras
  Future<void> _onSwitchCamera(
    SwitchCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;

    final currentState = state as CameraReadyState;

    if (_availableCameras.length < 2) {
      emit(const CameraErrorState(
        message: 'No other cameras available',
        errorCode: 'NO_OTHER_CAMERAS',
      ));
      return;
    }

    emit(const CameraSwitchingState());

    try {
      // Dispose current controller
      await _currentController?.dispose();

      // Find next camera
      final currentIndex = _availableCameras.indexOf(_currentCamera!);
      final nextIndex = (currentIndex + 1) % _availableCameras.length;
      final nextCamera = _availableCameras[nextIndex];

      _currentCamera = nextCamera;

      // Initialize new camera
      final controllerResult =
          await cameraRepository.initializeCamera(nextCamera);

      controllerResult.fold(
        (failure) => emit(CameraErrorState(
          message: failure.message,
          errorCode: failure.code,
        )),
        (controller) {
          _currentController = controller;
          emit(currentState.copyWith(
            controller: controller,
            currentCamera: nextCamera,
          ));
        },
      );
    } catch (e) {
      emit(CameraErrorState(
        message: 'Failed to switch camera: $e',
        errorCode: 'CAMERA_SWITCH_ERROR',
      ));
    }
  }

  /// Toggle flash mode
  Future<void> _onToggleFlash(
    ToggleFlashEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState || _currentController == null) return;

    final currentState = state as CameraReadyState;

    // Cycle through flash modes
    FlashMode nextFlashMode;
    switch (currentState.flashMode) {
      case FlashMode.off:
        nextFlashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextFlashMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextFlashMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextFlashMode = FlashMode.off;
        break;
    }

    final result =
        await cameraRepository.setFlashMode(_currentController!, nextFlashMode);

    result.fold(
      (failure) => emit(CameraErrorState(
        message: failure.message,
        errorCode: failure.code,
      )),
      (_) => emit(currentState.copyWith(flashMode: nextFlashMode)),
    );
  }

  /// Capture image
  Future<void> _onCaptureImage(
    CaptureImageEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState || _currentController == null) return;

    emit(const CameraCapturingState());

    try {
      final result = await cameraRepository.captureImage(_currentController!);

      result.fold(
        (failure) => emit(CameraCaptureErrorState(
          message: failure.message,
          errorCode: failure.code,
        )),
        (imagePath) => emit(CameraImageCapturedState(
          imagePath: imagePath,
          captureTime: DateTime.now(),
        )),
      );
    } catch (e) {
      emit(CameraCaptureErrorState(
        message: 'Unexpected error during image capture: $e',
        errorCode: 'CAPTURE_UNEXPECTED_ERROR',
      ));
    }
  }

  /// Process OCR on captured image
  Future<void> _onProcessOcr(
    ProcessOcrEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraProcessingOcrState(event.imagePath));

    try {
      final result = await cameraRepository.processImageForOcr(event.imagePath);

      result.fold(
        (failure) => emit(CameraOcrErrorState(
          message: failure.message,
          errorCode: failure.code,
          imagePath: event.imagePath,
        )),
        (ocrResult) => emit(CameraOcrCompletedState(
          ocrResult: ocrResult,
          imagePath: event.imagePath,
        )),
      );
    } catch (e) {
      emit(CameraOcrErrorState(
        message: 'Unexpected error during OCR processing: $e',
        errorCode: 'OCR_UNEXPECTED_ERROR',
        imagePath: event.imagePath,
      ));
    }
  }

  /// Toggle OCR overlay visibility
  Future<void> _onToggleOcrOverlay(
    ToggleOcrOverlayEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;

    final currentState = state as CameraReadyState;
    emit(currentState.copyWith(
      isOcrOverlayVisible: !currentState.isOcrOverlayVisible,
    ));
  }

  /// Dispose camera resources
  Future<void> _onDisposeCamera(
    DisposeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_currentController != null) {
        await cameraRepository.disposeCamera(_currentController!);
        _currentController = null;
      }
      emit(const CameraInitialState());
    } catch (e) {
      emit(CameraErrorState(
        message: 'Error disposing camera: $e',
        errorCode: 'DISPOSE_ERROR',
      ));
    }
  }

  /// Resume camera
  Future<void> _onResumeCamera(
    ResumeCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (_currentCamera != null) {
      add(InitializeCameraEvent(preferredCamera: _currentCamera));
    } else {
      add(const InitializeCameraEvent());
    }
  }

  /// Pause camera
  Future<void> _onPauseCamera(
    PauseCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (_currentController != null) {
        await cameraRepository.disposeCamera(_currentController!);
      }
      emit(const CameraPausedState());
    } catch (e) {
      emit(CameraErrorState(
        message: 'Error pausing camera: $e',
        errorCode: 'PAUSE_ERROR',
      ));
    }
  }

  /// Set camera zoom level
  Future<void> _onZoomCamera(
    ZoomCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState || _currentController == null) return;

    final currentState = state as CameraReadyState;

    // Clamp zoom level to supported range
    final clampedZoom =
        event.zoomLevel.clamp(currentState.minZoom, currentState.maxZoom);

    final result =
        await cameraRepository.setZoomLevel(_currentController!, clampedZoom);

    result.fold(
      (failure) => emit(CameraErrorState(
        message: failure.message,
        errorCode: failure.code,
      )),
      (_) => emit(currentState.copyWith(zoomLevel: clampedZoom)),
    );
  }

  /// Toggle focus mode
  Future<void> _onToggleFocusMode(
    ToggleFocusModeEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState || _currentController == null) return;

    final currentState = state as CameraReadyState;

    final nextFocusMode = currentState.focusMode == FocusMode.auto
        ? FocusMode.locked
        : FocusMode.auto;

    final result =
        await cameraRepository.setFocusMode(_currentController!, nextFocusMode);

    result.fold(
      (failure) => emit(CameraErrorState(
        message: failure.message,
        errorCode: failure.code,
      )),
      (_) => emit(currentState.copyWith(focusMode: nextFocusMode)),
    );
  }

  /// Set focus point
  Future<void> _onSetFocusPoint(
    SetFocusPointEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState || _currentController == null) return;

    final result = await cameraRepository.setFocusPoint(
        _currentController!, event.point as Offset);

    result.fold(
      (failure) => emit(CameraErrorState(
        message: failure.message,
        errorCode: failure.code,
      )),
      (_) {
        // Focus point set successfully - could emit updated state if needed
      },
    );
  }

  /// Request camera permission
  Future<void> _onRequestCameraPermission(
    RequestCameraPermissionEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      final result = await cameraRepository.requestCameraPermission();

      result.fold(
        (failure) => emit(CameraErrorState(
          message: failure.message,
          errorCode: failure.code,
        )),
        (granted) {
          if (granted) {
            // Permission granted, initialize camera
            add(const InitializeCameraEvent());
          } else {
            emit(const CameraPermissionDeniedState());
          }
        },
      );
    } catch (e) {
      emit(CameraErrorState(
        message: 'Error requesting camera permission: $e',
        errorCode: 'PERMISSION_REQUEST_ERROR',
      ));
    }
  }

  /// Retry camera initialization
  Future<void> _onRetryCameraInitialization(
    RetryCameraInitializationEvent event,
    Emitter<CameraState> emit,
  ) async {
    add(const InitializeCameraEvent());
  }

  /// Clear OCR results
  Future<void> _onClearOcrResults(
    ClearOcrResultsEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;

    final currentState = state as CameraReadyState;
    emit(currentState.copyWith(lastOcrResult: null));
  }

  /// Save captured image
  Future<void> _onSaveImage(
    SaveImageEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraSavingImageState(event.imagePath));

    try {
      final result = await cameraRepository.saveImageToGallery(event.imagePath);

      result.fold(
        (failure) => emit(CameraErrorState(
          message: failure.message,
          errorCode: failure.code,
        )),
        (savedPath) => emit(CameraImageSavedState(
          savedPath: savedPath,
          originalPath: event.imagePath,
        )),
      );
    } catch (e) {
      emit(CameraErrorState(
        message: 'Unexpected error saving image: $e',
        errorCode: 'SAVE_UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<void> close() async {
    // Clean up resources
    try {
      if (_currentController != null) {
        await cameraRepository.disposeCamera(_currentController!);
      }
    } catch (e) {
      print('Warning: Error disposing camera during bloc close: $e');
    }
    return super.close();
  }
}
