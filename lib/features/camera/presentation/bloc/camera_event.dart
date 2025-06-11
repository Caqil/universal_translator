
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

/// Base class for all camera events
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the camera
class InitializeCameraEvent extends CameraEvent {
  final CameraDescription? preferredCamera;

  const InitializeCameraEvent({this.preferredCamera});

  @override
  List<Object?> get props => [preferredCamera];
}

/// Event to switch between front and back camera
class SwitchCameraEvent extends CameraEvent {
  const SwitchCameraEvent();
}

/// Event to toggle flash mode
class ToggleFlashEvent extends CameraEvent {
  const ToggleFlashEvent();
}

/// Event to capture an image
class CaptureImageEvent extends CameraEvent {
  const CaptureImageEvent();
}

/// Event to start OCR processing on captured image
class ProcessOcrEvent extends CameraEvent {
  final String imagePath;

  const ProcessOcrEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// Event to toggle OCR overlay display
class ToggleOcrOverlayEvent extends CameraEvent {
  const ToggleOcrOverlayEvent();
}

/// Event to dispose/cleanup camera resources
class DisposeCameraEvent extends CameraEvent {
  const DisposeCameraEvent();
}

/// Event to resume camera after pause
class ResumeCameraEvent extends CameraEvent {
  const ResumeCameraEvent();
}

/// Event to pause camera
class PauseCameraEvent extends CameraEvent {
  const PauseCameraEvent();
}

/// Event to zoom camera
class ZoomCameraEvent extends CameraEvent {
  final double zoomLevel;

  const ZoomCameraEvent(this.zoomLevel);

  @override
  List<Object> get props => [zoomLevel];
}

/// Event to toggle focus mode
class ToggleFocusModeEvent extends CameraEvent {
  const ToggleFocusModeEvent();
}

/// Event to set focus point
class SetFocusPointEvent extends CameraEvent {
  final Offset point;

  const SetFocusPointEvent(this.point);

  @override
  List<Object> get props => [point.dx, point.dy];
}

/// Event to handle camera permission request
class RequestCameraPermissionEvent extends CameraEvent {
  const RequestCameraPermissionEvent();
}

/// Event to retry camera initialization after error
class RetryCameraInitializationEvent extends CameraEvent {
  const RetryCameraInitializationEvent();
}

/// Event to clear OCR results
class ClearOcrResultsEvent extends CameraEvent {
  const ClearOcrResultsEvent();
}

/// Event to save captured image
class SaveImageEvent extends CameraEvent {
  final String imagePath;

  const SaveImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

/// Simple Offset class for focus points
class Offset extends Equatable {
  final double dx;
  final double dy;

  const Offset(this.dx, this.dy);

  @override
  List<Object> get props => [dx, dy];
}
