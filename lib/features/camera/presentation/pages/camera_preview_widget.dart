
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final bool isProcessing;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(controller),

        // Overlay for focus area
        _buildFocusOverlay(context),

        // Processing indicator
        if (isProcessing) _buildProcessingOverlay(),

        // Camera guidelines
        _buildCameraGuidelines(),
      ],
    );
  }

  Widget _buildFocusOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTapUp: (details) {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.globalToLocal(details.globalPosition);
          final point = Offset(
            offset.dx / box.size.width,
            offset.dy / box.size.height,
          );
          controller.setExposurePoint(point);
          controller.setFocusPoint(point);
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Processing image...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraGuidelines() {
    return CustomPaint(
      painter: CameraGuidelinesPainter(),
    );
  }
}

class CameraGuidelinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw rule of thirds lines
    final width = size.width;
    final height = size.height;

    // Vertical lines
    canvas.drawLine(
      Offset(width / 3, 0),
      Offset(width / 3, height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * width / 3, 0),
      Offset(2 * width / 3, height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, height / 3),
      Offset(width, height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * height / 3),
      Offset(width, 2 * height / 3),
      paint,
    );

    // Center focus area
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = width / 2;
    final centerY = height / 2;
    final focusSize = 100.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: focusSize,
          height: focusSize,
        ),
        const Radius.circular(8),
      ),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
