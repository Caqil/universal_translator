import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/capture_image_usecase.dart';
import '../../domain/usecases/initialize_camera_usecase.dart';
import '../../domain/usecases/process_image_for_translation_usecase.dart';
import '../../domain/usecases/select_image_from_gallery_usecase.dart';
import 'camera_event.dart';
import 'camera_state.dart';

@injectable
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCameraUseCase _initializeCameraUseCase;
  final CaptureImageUseCase _captureImageUseCase;
  final SelectImageFromGalleryUseCase _selectImageFromGalleryUseCase;
  final ProcessImageForTranslationUseCase _processImageForTranslationUseCase;

  CameraController? _controller;

  CameraBloc(
    this._initializeCameraUseCase,
    this._captureImageUseCase,
    this._selectImageFromGalleryUseCase,
    this._processImageForTranslationUseCase,
  ) : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<CaptureImage>(_onCaptureImage);
    on<SelectImageFromGallery>(_onSelectImageFromGallery);
    on<ToggleFlash>(_onToggleFlash);
    on<ProcessImageForTranslation>(_onProcessImageForTranslation);
    on<RetakePhoto>(_onRetakePhoto);
    on<DisposeCamera>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraLoading());

    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.status;
      if (cameraPermission.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied) {
          emit(const CameraError(
            message: 'Camera permission is required',
            code: 'CAMERA_PERMISSION_DENIED',
          ));
          return;
        }
      }

      final result = await _initializeCameraUseCase(NoParams());
      result.fold(
        (failure) => emit(CameraError(
          message: failure.message,
          code: failure.code,
        )),
        (controller) {
          _controller = controller;
          emit(CameraReady(controller: controller));
        },
      );
    } catch (e) {
      emit(CameraError(message: e.toString()));
    }
  }

  Future<void> _onCaptureImage(
    CaptureImage event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady) return;

    final currentState = state as CameraReady;
    emit(currentState.copyWith(isProcessing: true));

    final result = await _captureImageUseCase(_controller!);
    result.fold(
      (failure) => emit(CameraError(
        message: failure.message,
        code: failure.code,
      )),
      (imagePath) => emit(ImageCaptured(imagePath: imagePath)),
    );
  }

  Future<void> _onSelectImageFromGallery(
    SelectImageFromGallery event,
    Emitter<CameraState> emit,
  ) async {
    final result = await _selectImageFromGalleryUseCase(NoParams());
    result.fold(
      (failure) => emit(CameraError(
        message: failure.message,
        code: failure.code,
      )),
      (imagePath) {
        if (imagePath != null) {
          emit(ImageCaptured(imagePath: imagePath));
        }
      },
    );
  }

  Future<void> _onToggleFlash(
    ToggleFlash event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReady || _controller == null) return;

    final currentState = state as CameraReady;
    final newFlashMode =
        currentState.isFlashOn ? FlashMode.off : FlashMode.torch;

    try {
      await _controller!.setFlashMode(newFlashMode);
      emit(currentState.copyWith(isFlashOn: !currentState.isFlashOn));
    } catch (e) {
      emit(CameraError(message: 'Failed to toggle flash: $e'));
    }
  }

  Future<void> _onProcessImageForTranslation(
    ProcessImageForTranslation event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! ImageCaptured) return;

    final currentState = state as ImageCaptured;
    emit(currentState.copyWith(isProcessing: true));

    final result = await _processImageForTranslationUseCase(
      ProcessImageForTranslationParams(
        imagePath: event.imagePath,
        sourceLanguage: event.sourceLanguage,
        targetLanguage: event.targetLanguage,
      ),
    );

    result.fold(
      (failure) => emit(CameraError(
        message: failure.message,
        code: failure.code,
      )),
      (translationResult) => emit(currentState.copyWith(
        recognizedTexts: translationResult.recognizedTexts,
        translatedTexts: translationResult.translatedTexts,
        isProcessing: false,
      )),
    );
  }

  Future<void> _onRetakePhoto(
    RetakePhoto event,
    Emitter<CameraState> emit,
  ) async {
    if (_controller != null) {
      emit(CameraReady(controller: _controller!));
    }
  }

  Future<void> _onDisposeCamera(
    DisposeCamera event,
    Emitter<CameraState> emit,
  ) async {
    await _controller?.dispose();
    _controller = null;
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
