import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/history_item.dart';

class HistoryItemWidget extends StatefulWidget {
  final HistoryItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const HistoryItemWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
    this.onCopy,
    this.onShare,
  });

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapUp,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.border(brightness).withOpacity(
                  _isPressed ? 0.2 : 0.1,
                ),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 3 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(brightness),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildContent(brightness),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildFooter(brightness),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Brightness brightness) {
    return Row(
      children: [
        // Selection checkbox (only visible in selection mode)
        if (widget.isSelectionMode) ...[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary(brightness)
                  : Colors.transparent,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary(brightness)
                    : AppColors.border(brightness),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: widget.isSelected
                ? Icon(
                    Iconsax.tick_circle,
                    size: 14,
                    color: AppColors.adaptive(
                      light: AppColors.lightPrimaryForeground,
                      dark: AppColors.darkPrimaryForeground,
                      brightness: brightness,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppConstants.defaultPadding),
        ],

        // Language indicators
        _buildLanguageIndicator(brightness),
        const Spacer(),

        // Confidence score (if available)
        if (widget.item.confidence != null) ...[
          _buildConfidenceIndicator(brightness),
          const SizedBox(width: AppConstants.smallPadding),
        ],

        // Timestamp
        _buildTimestamp(brightness),

        // Actions
        if (!widget.isSelectionMode) ...[
          const SizedBox(width: AppConstants.smallPadding),
          _buildActions(brightness),
        ],
      ],
    );
  }

  Widget _buildLanguageIndicator(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary(brightness),
            AppColors.primary(brightness).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(brightness).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.item.sourceLanguage.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.adaptive(
                light: AppColors.lightPrimaryForeground,
                dark: AppColors.darkPrimaryForeground,
                brightness: brightness,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Iconsax.arrow_right_3,
              size: 12,
              color: AppColors.adaptive(
                light: AppColors.lightPrimaryForeground,
                dark: AppColors.darkPrimaryForeground,
                brightness: brightness,
              ),
            ),
          ),
          Text(
            widget.item.targetLanguage.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.adaptive(
                light: AppColors.lightPrimaryForeground,
                dark: AppColors.darkPrimaryForeground,
                brightness: brightness,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(Brightness brightness) {
    final confidence = widget.item.confidence!;
    final color = confidence >= 0.8
        ? AppColors.success(brightness)
        : confidence >= 0.6
            ? AppColors.warning(brightness)
            : AppColors.destructive(brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidence >= 0.8
                ? Iconsax.verify5
                : confidence >= 0.6
                    ? Iconsax.info_circle
                    : Iconsax.warning_2,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${(confidence * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(Brightness brightness) {
    final now = DateTime.now();
    final difference = now.difference(widget.item.timestamp);

    String timeText;
    if (difference.inMinutes < 1) {
      timeText = 'app.just_now'.tr();
    } else if (difference.inHours < 1) {
      timeText = 'app.minutes_ago'.tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inDays < 1) {
      timeText = 'app.hours_ago'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      timeText = 'app.days_ago'.tr(args: [difference.inDays.toString()]);
    } else {
      timeText = DateFormat.MMMd().format(widget.item.timestamp);
    }

    return Text(
      timeText,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.mutedForeground(brightness),
      ),
    );
  }

  Widget _buildActions(Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite button
        _buildActionButton(
          icon: widget.item.isFavorite ? Iconsax.heart5 : Iconsax.heart,
          color: widget.item.isFavorite
              ? AppColors.destructive(brightness)
              : AppColors.mutedForeground(brightness),
          onPressed: widget.onFavoriteToggle,
          tooltip: widget.item.isFavorite
              ? 'favorites.remove_from_favorites'.tr()
              : 'favorites.add_to_favorites'.tr(),
        ),

        // More options
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          icon: Icon(
            Iconsax.more,
            size: AppConstants.iconSizeSmall,
            color: AppColors.mutedForeground(brightness),
          ),
          constraints: const BoxConstraints(minWidth: 180),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          itemBuilder: (context) => [
            _buildMenuItem(
              value: 'copy',
              icon: Iconsax.copy,
              title: 'app.copy'.tr(),
              brightness: brightness,
            ),
            _buildMenuItem(
              value: 'share',
              icon: Iconsax.share,
              title: 'app.share'.tr(),
              brightness: brightness,
            ),
            _buildMenuItem(
              value: 'edit',
              icon: Iconsax.edit,
              title: 'app.edit'.tr(),
              brightness: brightness,
            ),
            const PopupMenuDivider(),
            _buildMenuItem(
              value: 'delete',
              icon: Iconsax.trash,
              title: 'app.delete'.tr(),
              brightness: brightness,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: AppConstants.iconSizeSmall,
            color: color,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required Brightness brightness,
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeSmall,
            color: isDestructive
                ? AppColors.destructive(brightness)
                : AppColors.adaptive(
                    light: AppColors.lightForeground,
                    dark: AppColors.darkForeground,
                    brightness: brightness,
                  ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDestructive
                  ? AppColors.destructive(brightness)
                  : AppColors.adaptive(
                      light: AppColors.lightForeground,
                      dark: AppColors.darkForeground,
                      brightness: brightness,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source text container
        _buildTextContainer(
          text: widget.item.sourceText,
          label: 'translation.source'.tr(),
          brightness: brightness,
          isSource: true,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Translation arrow
        Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.adaptive(
                light: AppColors.lightMuted,
                dark: AppColors.darkMuted,
                brightness: brightness,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: AppColors.mutedForeground(brightness),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Translated text container
        _buildTextContainer(
          text: widget.item.translatedText,
          label: 'translation.translation'.tr(),
          brightness: brightness,
          isSource: false,
        ),
      ],
    );
  }

  Widget _buildTextContainer({
    required String text,
    required String label,
    required Brightness brightness,
    required bool isSource,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isSource
            ? AppColors.adaptive(
                light: AppColors.lightMuted,
                dark: AppColors.darkMuted,
                brightness: brightness,
              ).withOpacity(0.5)
            : AppColors.primary(brightness).withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: isSource
              ? AppColors.border(brightness)
              : AppColors.primary(brightness).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.mutedForeground(brightness),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding / 2),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.adaptive(
                light: AppColors.lightForeground,
                dark: AppColors.darkForeground,
                brightness: brightness,
              ),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Brightness brightness) {
    return Row(
      children: [
        // Quick action buttons
        _buildQuickActionButton(
          icon: Iconsax.copy,
          label: 'app.copy'.tr(),
          onPressed: widget.onCopy,
          brightness: brightness,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        _buildQuickActionButton(
          icon: Iconsax.share,
          label: 'app.share'.tr(),
          onPressed: widget.onShare,
          brightness: brightness,
        ),
        const SizedBox(width: AppConstants.smallPadding),
        _buildQuickActionButton(
          icon: Iconsax.sound,
          label: 'app.listen'.tr(),
          onPressed: () {
            // TODO: Implement text-to-speech
          },
          brightness: brightness,
        ),
        const Spacer(),

        // Word count indicator
        _buildWordCountIndicator(brightness),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Brightness brightness,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.adaptive(
            light: AppColors.lightMuted,
            dark: AppColors.darkMuted,
            brightness: brightness,
          ),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(
            color: AppColors.border(brightness),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppConstants.iconSizeSmall,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCountIndicator(Brightness brightness) {
    final sourceWords = widget.item.sourceText.split(' ').length;
    final translatedWords = widget.item.translatedText.split(' ').length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.adaptive(
          light: AppColors.lightMuted,
          dark: AppColors.darkMuted,
          brightness: brightness,
        ).withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Text(
        '$sourceWords → $translatedWords ${'app.words'.tr()}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.mutedForeground(brightness),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'copy':
        widget.onCopy?.call();
        break;
      case 'share':
        widget.onShare?.call();
        break;
      case 'edit':
        // TODO: Implement edit functionality
        break;
      case 'delete':
        widget.onDelete?.call();
        break;
    }
  }
}
