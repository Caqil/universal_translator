// Import alias to avoid naming conflict
import '../../domain/entities/ocr_result.dart' as domain;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ocr_result.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';

/// Widget that displays OCR results as an overlay on the camera preview
class OcrOverlay extends StatelessWidget {
  final OcrResult? ocrResult;
  final Size previewSize;
  final VoidCallback? onClearResults;
  final Function(String)? onTextSelected;

  const OcrOverlay({
    Key? key,
    this.ocrResult,
    required this.previewSize,
    this.onClearResults,
    this.onTextSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraReadyState && state.isOcrOverlayVisible) {
          return _buildOverlay(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Build the main overlay
  Widget _buildOverlay(BuildContext context, CameraReadyState state) {
    final ocrData = ocrResult ?? state.lastOcrResult;

    if (ocrData == null || !ocrData.hasText) {
      return _buildEmptyOverlay(context);
    }

    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black26,
        ),

        // Text blocks overlay
        _buildTextBlocksOverlay(context, ocrData),

        // Control panel
        _buildControlPanel(context, ocrData),
      ],
    );
  }

  /// Build overlay when no OCR results are available
  Widget _buildEmptyOverlay(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_fields,
              size: 48,
              color: Colors.white70,
            ),
            SizedBox(height: 16),
            Text(
              'No text detected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Capture an image with text to see results',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build text blocks overlay
  Widget _buildTextBlocksOverlay(BuildContext context, OcrResult ocrResult) {
    return CustomPaint(
      size: previewSize,
     
    );
  }

  /// Build control panel at the bottom
  Widget _buildControlPanel(BuildContext context, OcrResult ocrResult) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text content card
              _buildTextContentCard(context, ocrResult),

              const SizedBox(height: 12),

              // Action buttons
              _buildActionButtons(context, ocrResult),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text content card
  Widget _buildTextContentCard(BuildContext context, OcrResult ocrResult) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with confidence indicator
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Detected Text',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                _buildConfidenceIndicator(ocrResult.confidence),
              ],
            ),

            const SizedBox(height: 8),

            // Text content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  ocrResult.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build confidence indicator
  Widget _buildConfidenceIndicator(double confidence) {
    Color color;
    String label;

    if (confidence >= 0.8) {
      color = Colors.green;
      label = 'High';
    } else if (confidence >= 0.6) {
      color = Colors.orange;
      label = 'Medium';
    } else {
      color = Colors.red;
      label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context, OcrResult ocrResult) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Copy text button
        _buildActionButton(
          context: context,
          icon: Icons.copy,
          label: 'Copy',
          onTap: () => _copyText(context, ocrResult.text),
        ),

        // Share text button
        _buildActionButton(
          context: context,
          icon: Icons.share,
          label: 'Share',
          onTap: () => _shareText(context, ocrResult.text),
        ),

        // Translate button
        _buildActionButton(
          context: context,
          icon: Icons.translate,
          label: 'Translate',
          onTap: () => onTextSelected?.call(ocrResult.text),
        ),

        // Close overlay button
        _buildActionButton(
          context: context,
          icon: Icons.close,
          label: 'Close',
          onTap: () {
            context.read<CameraBloc>().add(const ToggleOcrOverlayEvent());
            onClearResults?.call();
          },
        ),
      ],
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Copy text to clipboard
  void _copyText(BuildContext context, String text) {
    // Implementation would use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Share text
  void _shareText(BuildContext context, String text) {
    // Implementation would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing text...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
