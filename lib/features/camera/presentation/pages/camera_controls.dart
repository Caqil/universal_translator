// lib/features/camera/presentation/widgets/camera_controls.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapturePressed;
  final VoidCallback onGalleryPressed;
  final bool isProcessing;

  const CameraControls({
    Key? key,
    required this.onCapturePressed,
    required this.onGalleryPressed,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            _buildControlButton(
              icon: Iconsax.gallery,
              label: 'camera.use_gallery'.tr(),
              onPressed: isProcessing ? null : onGalleryPressed,
            ),

            // Capture button
            _buildCaptureButton(),

            // Info button
            _buildControlButton(
              icon: Iconsax.info_circle,
              label: 'app.help'.tr(),
              onPressed: () => _showCameraHelp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: onPressed != null ? Colors.white : Colors.grey,
            size: 28,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isProcessing ? null : onCapturePressed,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: isProcessing ? Colors.grey : Colors.white.withOpacity(0.1),
            ),
            child: isProcessing
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Iconsax.camera,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'camera.take_photo'.tr(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showCameraHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('camera.camera_translation'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('camera.focus_tap'.tr()),
            const SizedBox(height: 8),
            Text('• Position text clearly in the frame'),
            Text('• Ensure good lighting'),
            Text('• Hold the camera steady'),
            Text('• Use flash in low light'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('app.ok'.tr()),
          ),
        ],
      ),
    );
  }
}
