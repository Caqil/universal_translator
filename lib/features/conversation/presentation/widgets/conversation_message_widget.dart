// lib/features/conversation/presentation/widgets/conversation_message_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/conversation_message.dart';

class ConversationMessageWidget extends StatefulWidget {
  final ConversationMessage message;
  final bool isPlaying;
  final VoidCallback onPlayAudio;
  final VoidCallback onRetryTranslation;

  const ConversationMessageWidget({
    super.key,
    required this.message,
    required this.isPlaying,
    required this.onPlayAudio,
    required this.onRetryTranslation,
  });

  @override
  State<ConversationMessageWidget> createState() =>
      _ConversationMessageWidgetState();
}

class _ConversationMessageWidgetState extends State<ConversationMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ConversationMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final isUser1 = widget.message.isUser1;
    final primaryColor = isUser1
        ? const Color(0xFF3B82F6) // Blue for user 1
        : const Color(0xFF10B981); // Green for user 2

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser1) const Spacer(),
          Flexible(
            flex: 3,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isPlaying ? _pulseAnimation.value : 1.0,
                  child: _buildMessageCard(context, brightness, primaryColor),
                );
              },
            ),
          ),
          if (isUser1) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMessageCard(
      BuildContext context, Brightness brightness, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: widget.message.isUser1
            ? primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(widget.message.isUser1 ? 20 : 4),
          bottomRight: Radius.circular(widget.message.isUser1 ? 4 : 20),
        ),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageHeader(context, primaryColor),
          _buildMessageContent(context, brightness),
          if (_showDetails) _buildMessageDetails(context, brightness),
          _buildMessageActions(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildMessageHeader(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.message.isUser1
                ? 'conversation.speaker_1'.tr()
                : 'conversation.speaker_2'.tr(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          if (widget.message.confidence < 0.7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Low Confidence',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            _formatTime(widget.message.timestamp),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.microphone,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getLanguageName(widget.message.sourceLanguage),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message.originalText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Translated text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary(brightness).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.translate,
                      size: 14,
                      color: AppColors.primary(brightness),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getLanguageName(widget.message.targetLanguage),
                      style: TextStyle(
                        color: AppColors.primary(brightness),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message.translatedText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(brightness),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageDetails(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // Confidence score
          Row(
            children: [
              Icon(
                Iconsax.chart,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'translation.confidence'.tr(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(widget.message.confidence * 100).round()}%',
                  style: TextStyle(
                    color: _getConfidenceColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Alternatives if available
          if (widget.message.alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'translation.alternative_translations'.tr(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            ...widget.message.alternatives.take(2).map((alt) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    '• $alt',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                )),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMessageActions(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Play audio button
          IconButton(
            onPressed: widget.onPlayAudio,
            icon: Icon(
              widget.isPlaying ? Iconsax.pause : Iconsax.volume_high,
              size: 18,
            ),
            color: primaryColor,
            tooltip: widget.isPlaying ? 'stop_audio'.tr() : 'play_audio'.tr(),
          ),

          // Copy translation button
          IconButton(
            onPressed: () => _copyToClipboard(widget.message.translatedText),
            icon: const Icon(Iconsax.copy, size: 18),
            color: Colors.grey[600],
            tooltip: 'translation.copy_translation'.tr(),
          ),

          // Retry translation button
          IconButton(
            onPressed: widget.onRetryTranslation,
            icon: const Icon(Iconsax.refresh, size: 18),
            color: Colors.grey[600],
            tooltip: 'Retry Translation',
          ),

          const Spacer(),

          // Details toggle button
          IconButton(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            icon: Icon(
              _showDetails ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
              size: 18,
            ),
            color: Colors.grey[600],
            tooltip: _showDetails ? 'Hide Details' : 'Show Details',
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (widget.message.confidence >= 0.8) return Colors.green;
    if (widget.message.confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _getLanguageName(String languageCode) {
    // Simple language name mapping - you can expand this
    const languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
    };
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('translation.translation_copied'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
