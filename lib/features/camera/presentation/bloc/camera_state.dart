
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final bool isFlashOn;
  final bool isProcessing;

  const CameraReady({
    required this.controller,
    this.isFlashOn = false,
    this.isProcessing = false,
  });

  @override
  List<Object?> get props => [controller, isFlashOn, isProcessing];

  CameraReady copyWith({
    CameraController? controller,
    bool? isFlashOn,
    bool? isProcessing,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class CameraError extends CameraState {
  final String message;
  final String? code;

  const CameraError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class ImageCaptured extends CameraState {
  final String imagePath;
  final List<String> recognizedTexts;
  final List<String> translatedTexts;
  final bool isProcessing;

  const ImageCaptured({
    required this.imagePath,
    this.recognizedTexts = const [],
    this.translatedTexts = const [],
    this.isProcessing = false,
  });

  @override
  List<Object?> get props =>
      [imagePath, recognizedTexts, translatedTexts, isProcessing];

  ImageCaptured copyWith({
    String? imagePath,
    List<String>? recognizedTexts,
    List<String>? translatedTexts,
    bool? isProcessing,
  }) {
    return ImageCaptured(
      imagePath: imagePath ?? this.imagePath,
      recognizedTexts: recognizedTexts ?? this.recognizedTexts,
      translatedTexts: translatedTexts ?? this.translatedTexts,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
