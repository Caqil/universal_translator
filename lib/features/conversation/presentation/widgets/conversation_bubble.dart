// lib/features/conversation/presentation/widgets/conversation_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/message.dart';

/// Widget for displaying conversation message bubbles
class ConversationBubble extends StatefulWidget {
  /// The message to display
  final Message message;

  /// Callback when translate button is pressed
  final Function(String targetLanguage)? onTranslate;

  /// Callback when favorite button is pressed
  final VoidCallback? onFavorite;

  /// Callback when delete button is pressed
  final VoidCallback? onDelete;

  /// Callback when voice message is played
  final VoidCallback? onPlayVoice;

  /// Whether to show translation controls
  final bool showTranslationControls;

  /// Whether to show timestamp
  final bool showTimestamp;

  /// Available target languages for translation
  final List<String> availableLanguages;

  const ConversationBubble({
    super.key,
    required this.message,
    this.onTranslate,
    this.onFavorite,
    this.onDelete,
    this.onPlayVoice,
    this.showTranslationControls = true,
    this.showTimestamp = true,
    this.availableLanguages = const ['en', 'es', 'fr', 'de', 'it', 'pt'],
  });

  @override
  State<ConversationBubble> createState() => _ConversationBubbleState();
}

class _ConversationBubbleState extends State<ConversationBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _showActions = false;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: AppConstants.fastAnimationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start entrance animation
    Future.microtask(() {
      _slideAnimationController.forward();
      _scaleAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;
    final isFromUser = widget.message.isFromUser;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onLongPress: _toggleActions,
          onTap: () {
            if (_showActions) _toggleActions();
          },
          child: Container(
            margin: EdgeInsets.only(
              left: isFromUser ? 48 : 0,
              right: isFromUser ? 0 : 48,
              bottom: AppConstants.smallPadding,
            ),
            child: Column(
              crossAxisAlignment: isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context, brightness, isFromUser),
                if (_showActions) _buildActionButtons(context, brightness),
                if (widget.showTimestamp)
                  _buildTimestamp(context, brightness, isFromUser),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      decoration: BoxDecoration(
        color: _getBubbleColor(brightness, isFromUser),
        borderRadius: _getBorderRadius(isFromUser),
        boxShadow: [
          BoxShadow(
            color: AppColors.surface(brightness),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(context, brightness, isFromUser),
          if (widget.message.hasTranslation && _showTranslation)
            _buildTranslationContent(context, brightness, isFromUser),
          if (widget.message.isTranslating)
            _buildTranslatingIndicator(context, brightness),
          if (widget.message.hasTranslationError)
            _buildErrorIndicator(context, brightness),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.type == MessageType.voice)
            _buildVoiceMessage(context, brightness, isFromUser)
          else
            _buildTextMessage(context, brightness, isFromUser),
          if (widget.message.hasTranslation && !_showTranslation)
            _buildTranslationToggle(context, brightness),
        ],
      ),
    );
  }

  Widget _buildTextMessage(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return SelectableText(
      widget.message.originalText,
      style: AppTextStyles.bodyMedium.copyWith(
        color: _getTextColor(brightness, isFromUser),
        height: 1.4,
      ),
    );
  }

  Widget _buildVoiceMessage(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.onPlayVoice,
          icon: Icon(
            Iconsax.play,
            color: _getTextColor(brightness, isFromUser),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: _getTextColor(brightness, isFromUser).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Container(
                      width:
                          100, // This would be calculated based on playback progress
                      decoration: BoxDecoration(
                        color: _getTextColor(brightness, isFromUser),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.message.voiceDuration ?? 0}s',
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getTextColor(brightness, isFromUser).withOpacity(0.7),
                ),
              ),
              if (widget.message.originalText.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  widget.message.originalText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getTextColor(brightness, isFromUser),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationContent(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: _getTextColor(brightness, isFromUser).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.translate,
                size: 16,
                color: _getTextColor(brightness, isFromUser).withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'translation'.tr(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: _getTextColor(brightness, isFromUser).withOpacity(0.7),
                ),
              ),
              const Spacer(),
              if (widget.message.confidence != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(widget.message.confidence!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(widget.message.confidence! * 100).round()}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          SelectableText(
            widget.message.translatedText!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getTextColor(brightness, isFromUser),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationToggle(BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.smallPadding),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showTranslation = !_showTranslation;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.translate,
              size: 14,
              color: AppColors.primary(brightness),
            ),
            const SizedBox(width: 4),
            Text(
              _showTranslation
                  ? 'hide_translation'.tr()
                  : 'show_translation'.tr(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatingIndicator(
      BuildContext context, Brightness brightness) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.mutedForeground(brightness).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomLoadingWidget.inline(
            size: 16,
            animation: LoadingAnimation.dots,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'translating'.tr(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context, Brightness brightness) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.destructive(brightness).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 16,
            color: AppColors.destructive(brightness),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              widget.message.translationError ?? 'translation_failed'.tr(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.destructive(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Brightness brightness) {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.smallPadding),
      child: Wrap(
        spacing: AppConstants.smallPadding,
        children: [
          // Copy button
          _buildActionButton(
            context,
            brightness,
            icon: Iconsax.copy,
            label: 'copy'.tr(),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: _showTranslation && widget.message.hasTranslation
                    ? widget.message.translatedText!
                    : widget.message.originalText,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('copied_to_clipboard'.tr())),
              );
              _toggleActions();
            },
          ),

          // Translate button
          if (widget.showTranslationControls && !widget.message.hasTranslation)
            _buildActionButton(
              context,
              brightness,
              icon: Iconsax.translate,
              label: 'translate'.tr(),
              onPressed: () {
                _showTranslationOptions(context);
                _toggleActions();
              },
            ),

          // Favorite button
          _buildActionButton(
            context,
            brightness,
            icon: widget.message.isFavorite ? Iconsax.heart5 : Iconsax.heart,
            label:
                widget.message.isFavorite ? 'unfavorite'.tr() : 'favorite'.tr(),
            onPressed: () {
              widget.onFavorite?.call();
              _toggleActions();
            },
          ),

          // Delete button (only for user messages)
          if (widget.message.isFromUser)
            _buildActionButton(
              context,
              brightness,
              icon: Iconsax.trash,
              label: 'delete'.tr(),
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Brightness brightness, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return CustomButton(
      onPressed: onPressed,
      icon: icon,
      text: label,
      size: ButtonSize.small,
      variant: ButtonVariant.outline,
    );
  }

  Widget _buildTimestamp(
    BuildContext context,
    Brightness brightness,
    bool isFromUser,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isFromUser ? 0 : AppConstants.defaultPadding,
        right: isFromUser ? AppConstants.defaultPadding : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat.Hm().format(widget.message.timestamp),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
          if (widget.message.isFromUser) ...[
            const SizedBox(width: 4),
            Icon(
              widget.message.isRead ? Iconsax.tick_circle : Iconsax.clock,
              size: 12,
              color: widget.message.isRead
                  ? AppColors.primary(brightness)
                  : AppColors.mutedForeground(brightness),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(Brightness brightness, bool isFromUser) {
    if (isFromUser) {
      return AppColors.primary(brightness);
    }
    return AppColors.surface(brightness);
  }

  Color _getTextColor(Brightness brightness, bool isFromUser) {
    if (isFromUser) {
      return AppColors.primary(brightness);
    }
    return AppColors.mutedForeground(brightness);
  }

  BorderRadius _getBorderRadius(bool isFromUser) {
    const radius = AppConstants.defaultBorderRadius;
    return BorderRadius.only(
      topLeft: const Radius.circular(radius),
      topRight: const Radius.circular(radius),
      bottomLeft: Radius.circular(isFromUser ? radius : 4),
      bottomRight: Radius.circular(isFromUser ? 4 : radius),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });
  }

  void _showTranslationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'translate_to'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: widget.availableLanguages.map((lang) {
                return CustomButton(
                  text: lang.toUpperCase(),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onTranslate?.call(lang);
                  },
                  size: ButtonSize.small,
                  variant: ButtonVariant.outline,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_message'.tr()),
        content: Text('delete_message_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
              _toggleActions();
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
