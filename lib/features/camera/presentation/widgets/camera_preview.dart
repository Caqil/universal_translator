// lib/features/camera/presentation/widgets/camera_preview.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

/// Widget that displays the camera preview
class CameraPreviewWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final Function(double)? onZoomChanged;

  const CameraPreviewWidget({
    Key? key,
    this.onTap,
    this.onZoomChanged,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraReadyState) {
          return _buildCameraPreview(state);
        } else if (state is CameraInitializingState) {
          return _buildLoadingPreview();
        } else if (state is CameraErrorState) {
          return _buildErrorPreview(state);
        } else if (state is CameraPermissionDeniedState) {
          return _buildPermissionDeniedPreview(state);
        } else if (state is CameraPausedState) {
          return _buildPausedPreview();
        }

        return _buildInitialPreview();
      },
    );
  }

  /// Build the main camera preview
  Widget _buildCameraPreview(CameraReadyState state) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (details) => _handleTapToFocus(context, state, details),
      onScaleStart: (details) => _handleScaleStart(state),
      onScaleUpdate: (details) => _handleScaleUpdate(context, state, details),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(state.controller),

          // Zoom indicator
          if (_isZooming(state)) _buildZoomIndicator(state),

          // Focus indicator (if needed)
          _buildFocusIndicator(),
        ],
      ),
    );
  }

  /// Build loading preview
  Widget _buildLoadingPreview() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error preview
  Widget _buildErrorPreview(CameraErrorState state) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<CameraBloc>()
                      .add(const RetryCameraInitializationEvent());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build permission denied preview
  Widget _buildPermissionDeniedPreview(CameraPermissionDeniedState state) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<CameraBloc>()
                      .add(const RequestCameraPermissionEvent());
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build paused preview
  Widget _buildPausedPreview() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Camera Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build initial preview
  Widget _buildInitialPreview() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// Build zoom indicator
  Widget _buildZoomIndicator(CameraReadyState state) {
    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${state.zoomLevel.toStringAsFixed(1)}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build focus indicator (placeholder for now)
  Widget _buildFocusIndicator() {
    return const SizedBox.shrink();
  }

  /// Handle tap to focus
  void _handleTapToFocus(
      BuildContext context, CameraReadyState state, TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPoint = renderBox.globalToLocal(details.globalPosition);
    final previewSize = renderBox.size;

    // Convert to normalized coordinates (0.0 to 1.0)
    final normalizedX = localPoint.dx / previewSize.width;
    final normalizedY = localPoint.dy / previewSize.height;

    // Send focus event
    context.read<CameraBloc>().add(
          SetFocusPointEvent(Offset(normalizedX, normalizedY)),
        );
  }

  /// Handle scale start (for zoom)
  void _handleScaleStart(CameraReadyState state) {
    _baseZoom = state.zoomLevel;
  }

  /// Handle scale update (for zoom)
  void _handleScaleUpdate(BuildContext context, CameraReadyState state,
      ScaleUpdateDetails details) {
    final newZoom =
        (_baseZoom * details.scale).clamp(state.minZoom, state.maxZoom);

    if (newZoom != _currentZoom) {
      _currentZoom = newZoom;

      // Send zoom event
      context.read<CameraBloc>().add(ZoomCameraEvent(newZoom));

      // Notify parent about zoom change
      widget.onZoomChanged?.call(newZoom);
    }
  }

  /// Check if currently zooming
  bool _isZooming(CameraReadyState state) {
    return state.zoomLevel > state.minZoom;
  }
}
