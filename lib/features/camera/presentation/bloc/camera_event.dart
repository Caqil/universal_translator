// lib/features/camera/presentation/bloc/camera_event.dart
import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class CaptureImage extends CameraEvent {}

class SelectImageFromGallery extends CameraEvent {}

class ToggleFlash extends CameraEvent {}

class ProcessImageForTranslation extends CameraEvent {
  final String imagePath;
  final String sourceLanguage;
  final String targetLanguage;

  const ProcessImageForTranslation({
    required this.imagePath,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [imagePath, sourceLanguage, targetLanguage];
}

class RetakePhoto extends CameraEvent {}

class DisposeCamera extends CameraEvent {}
