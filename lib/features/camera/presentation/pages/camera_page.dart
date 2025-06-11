// lib/features/camera/presentation/pages/camera_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';

import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';
import '../widgets/camera_preview.dart';
import '../widgets/ocr_overlay.dart';
import '../../domain/entities/ocr_result.dart';

/// Main camera page for capturing images and performing OCR
class CameraPage extends StatefulWidget {
  final Function(String)? onTextExtracted;
  final VoidCallback? onBackPressed;

  const CameraPage({
    Key? key,
    this.onTextExtracted,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _captureAnimationController;
  late AnimationController _flashAnimationController;

  bool _isFlashAnimating = false;
  String? _lastCapturedImagePath;
  OcrResult? _currentOcrResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controllers
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize camera
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureAnimationController.dispose();
    _flashAnimationController.dispose();

    // Dispose camera
    context.read<CameraBloc>().add(const DisposeCameraEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraBloc = context.read<CameraBloc>();

    switch (state) {
      case AppLifecycleState.resumed:
        cameraBloc.add(const ResumeCameraEvent());
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        cameraBloc.add(const PauseCameraEvent());
        break;
      case AppLifecycleState.detached:
        cameraBloc.add(const DisposeCameraEvent());
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<CameraBloc, CameraState>(
        listener: _handleStateChanges,
        child: Stack(
          children: [
            // Camera preview
            _buildCameraPreview(),

            // OCR overlay
            _buildOcrOverlay(),

            // UI controls
            _buildUIControls(),

            // Flash animation overlay
            _buildFlashOverlay(),
          ],
        ),
      ),
    );
  }

  /// Initialize camera
  void _initializeCamera() {
    context.read<CameraBloc>().add(const InitializeCameraEvent());
  }

  /// Handle state changes
  void _handleStateChanges(BuildContext context, CameraState state) {
    if (state is CameraImageCapturedState) {
      _lastCapturedImagePath = state.imagePath;
      _playFlashAnimation();
      _startOcrProcessing(state.imagePath);
    } else if (state is CameraOcrCompletedState) {
      _currentOcrResult = state.ocrResult;
      if (state.ocrResult.hasText) {
        context.read<CameraBloc>().add(const ToggleOcrOverlayEvent());
        widget.onTextExtracted?.call(state.ocrResult.text);
      } else {
        _showNoTextFoundMessage();
      }
    } else if (state is CameraOcrErrorState) {
      _showOcrErrorMessage(state.message);
    } else if (state is CameraCaptureErrorState) {
      _showCaptureErrorMessage(state.message);
    }
  }

  /// Build camera preview
  Widget _buildCameraPreview() {
    return CameraPreviewWidget(
      onZoomChanged: (zoom) {
        // Handle zoom changes if needed
      },
    );
  }

  /// Build OCR overlay
  Widget _buildOcrOverlay() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraReadyState) {
          return OcrOverlay(
            ocrResult: _currentOcrResult,
            previewSize: MediaQuery.of(context).size,
            onClearResults: () {
              setState(() {
                _currentOcrResult = null;
              });
            },
            onTextSelected: (text) {
              widget.onTextExtracted?.call(text);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Build UI controls
  Widget _buildUIControls() {
    return SafeArea(
      child: Column(
        children: [
          // Top controls
          _buildTopControls(),

          const Spacer(),

          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  /// Build top controls
  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          _buildControlButton(
            icon: Icons.arrow_back,
            onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
          ),

          const Spacer(),

          // Camera info
          BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              if (state is CameraReadyState) {
                return _buildCameraInfo(state);
              }
              return const SizedBox.shrink();
            },
          ),

          const Spacer(),

          // Settings button
          _buildControlButton(
            icon: Icons.settings,
            onTap: _showCameraSettings,
          ),
        ],
      ),
    );
  }

  /// Build camera info widget
  Widget _buildCameraInfo(CameraReadyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            '${state.zoomLevel.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom controls
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery/Recent images button
              _buildControlButton(
                icon: Icons.photo_library,
                onTap: _openGallery,
                size: 48,
              ),

              // Capture button
              _buildCaptureButton(state),

              // Switch camera button
              if (state is CameraReadyState &&
                  state.availableCameras.length > 1)
                _buildControlButton(
                  icon: Icons.flip_camera_android,
                  onTap: () =>
                      context.read<CameraBloc>().add(const SwitchCameraEvent()),
                  size: 48,
                ),

              if (state is! CameraReadyState ||
                  state.availableCameras.length <= 1)
                const SizedBox(width: 48),
            ],
          );
        },
      ),
    );
  }

  /// Build capture button
  Widget _buildCaptureButton(CameraState state) {
    final isCapturing =
        state is CameraCapturingState || state is CameraProcessingOcrState;

    return GestureDetector(
      onTap: isCapturing ? null : _captureImage,
      child: AnimatedBuilder(
        animation: _captureAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_captureAnimationController.value * 0.1),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isCapturing ? Colors.grey : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Colors.black,
                    ),
            ),
          );
        },
      ),
    ).animate().scale(duration: 300.ms);
  }

  /// Build control button
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  /// Build flash overlay for capture animation
  Widget _buildFlashOverlay() {
    return AnimatedBuilder(
      animation: _flashAnimationController,
      builder: (context, child) {
        return _isFlashAnimating
            ? Container(
                color:
                    Colors.white.withOpacity(_flashAnimationController.value),
              )
            : const SizedBox.shrink();
      },
    );
  }

  /// Capture image
  void _captureImage() {
    _captureAnimationController.forward().then((_) {
      _captureAnimationController.reverse();
    });

    context.read<CameraBloc>().add(const CaptureImageEvent());

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Start OCR processing
  void _startOcrProcessing(String imagePath) {
    context.read<CameraBloc>().add(ProcessOcrEvent(imagePath));
  }

  /// Play flash animation
  void _playFlashAnimation() {
    setState(() {
      _isFlashAnimating = true;
    });

    _flashAnimationController.forward().then((_) {
      _flashAnimationController.reverse().then((_) {
        setState(() {
          _isFlashAnimating = false;
        });
      });
    });
  }

  /// Show camera settings
  void _showCameraSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsBottomSheet(),
    );
  }

  /// Build settings bottom sheet
  Widget _buildSettingsBottomSheet() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is! CameraReadyState) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Camera Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Flash mode setting
                _buildSettingRow(
                  title: 'Flash',
                  subtitle: _getFlashModeText(state.flashMode),
                  icon: _getFlashModeIcon(state.flashMode),
                  onTap: () =>
                      context.read<CameraBloc>().add(const ToggleFlashEvent()),
                ),

                // Focus mode setting
                _buildSettingRow(
                  title: 'Focus',
                  subtitle: _getFocusModeText(state.focusMode),
                  icon: Icons.center_focus_strong,
                  onTap: () => context
                      .read<CameraBloc>()
                      .add(const ToggleFocusModeEvent()),
                ),

                // OCR overlay setting
                _buildSettingRow(
                  title: 'OCR Overlay',
                  subtitle: state.isOcrOverlayVisible ? 'Enabled' : 'Disabled',
                  icon: state.isOcrOverlayVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onTap: () => context
                      .read<CameraBloc>()
                      .add(const ToggleOcrOverlayEvent()),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build setting row
  Widget _buildSettingRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Open gallery
  void _openGallery() {
    // Implementation for opening gallery or recent images
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show no text found message
  void _showNoTextFoundMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No text found in the image'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Show OCR error message
  void _showOcrErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OCR Error: $message'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show capture error message
  void _showCaptureErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Capture Error: $message'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Get flash mode text
  String _getFlashModeText(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return 'Off';
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.always:
        return 'On';
      case FlashMode.torch:
        return 'Torch';
    }
  }

  /// Get flash mode icon
  IconData _getFlashModeIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  /// Get focus mode text
  String _getFocusModeText(FocusMode mode) {
    switch (mode) {
      case FocusMode.auto:
        return 'Auto';
      case FocusMode.locked:
        return 'Locked';
    }
  }
}
