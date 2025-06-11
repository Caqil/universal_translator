// lib/features/settings/presentation/widgets/theme_selector.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/app_settings_model.dart';

/// Theme selector widget for switching between light/dark/system themes
class ThemeSelector extends StatefulWidget {
  /// Currently selected theme
  final AppTheme selectedTheme;

  /// Callback when theme is selected
  final ValueChanged<AppTheme> onThemeSelected;

  /// Whether to show as compact design
  final bool isCompact;

  /// Whether to show theme preview
  final bool showPreview;

  const ThemeSelector({
    super.key,
    required this.selectedTheme,
    required this.onThemeSelected,
    this.isCompact = false,
    this.showPreview = true,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.fastAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.isCompact
              ? _buildCompactSelector(brightness)
              : _buildFullSelector(brightness),
        );
      },
    );
  }

  Widget _buildFullSelector(Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.border(brightness),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(
                  Iconsax.brush_2,
                  size: AppConstants.iconSizeRegular,
                  color: AppColors.primary(brightness),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'theme'.tr(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (widget.showPreview) _buildThemePreview(brightness),
          _buildThemeOptions(brightness),
        ],
      ),
    );
  }

  Widget _buildCompactSelector(Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: brightness == Brightness.light
            ? AppColors.lightSecondary
            : AppColors.darkSecondary,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: AppColors.border(brightness),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppTheme.values.map((theme) {
          final isSelected = theme == widget.selectedTheme;
          return _buildCompactThemeOption(theme, isSelected, brightness);
        }).toList(),
      ),
    );
  }

  Widget _buildThemePreview(Brightness brightness) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: brightness == Brightness.light
            ? AppColors.lightSecondary
            : AppColors.darkSecondary,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Row(
        children: [
          // Light theme preview
          _buildPreviewCard(
            brightness: Brightness.light,
            isSelected: widget.selectedTheme == AppTheme.light,
            isSystem: widget.selectedTheme == AppTheme.system,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          // Dark theme preview
          _buildPreviewCard(
            brightness: Brightness.dark,
            isSelected: widget.selectedTheme == AppTheme.dark,
            isSystem: widget.selectedTheme == AppTheme.system,
          ),
          if (widget.selectedTheme == AppTheme.system) ...[
            const SizedBox(width: AppConstants.smallPadding),
            Icon(
              Iconsax.setting_2,
              size: AppConstants.iconSizeSmall,
              color: AppColors.primary(brightness),
            ),
            const SizedBox(width: AppConstants.smallPadding / 2),
            Text(
              'auto'.tr(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewCard({
    required Brightness brightness,
    required bool isSelected,
    required bool isSystem,
  }) {
    return Container(
      width: 32,
      height: 20,
      decoration: BoxDecoration(
        color: brightness == Brightness.light
            ? AppColors.lightBackground
            : AppColors.darkBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSelected || isSystem
              ? AppColors.primary(context.brightness)
              : AppColors.border(context.brightness),
          width: isSelected || isSystem ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: brightness == Brightness.light
                  ? AppColors.lightCard
                  : AppColors.darkCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: brightness == Brightness.light
                    ? AppColors.lightSecondary
                    : AppColors.darkSecondary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptions(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: AppTheme.values.map((theme) {
          return _buildThemeOption(theme, brightness);
        }).toList(),
      ),
    );
  }

  Widget _buildThemeOption(AppTheme theme, Brightness brightness) {
    final isSelected = theme == widget.selectedTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: InkWell(
        onTap: () => _selectTheme(theme),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? (brightness == Brightness.light
                        ? AppColors.lightAccent
                        : AppColors.darkAccent)
                    .withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            border: isSelected
                ? Border.all(
                    color: brightness == Brightness.light
                        ? AppColors.lightAccent
                        : AppColors.darkAccent,
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                _getThemeIcon(theme),
                size: AppConstants.iconSizeRegular,
                color: isSelected
                    ? AppColors.surface(brightness)
                    : AppColors.mutedForeground(brightness),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getThemeDescription(theme),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Iconsax.tick_circle5,
                  size: AppConstants.iconSizeRegular,
                  color: brightness == Brightness.light
                      ? AppColors.lightAccent
                      : AppColors.darkAccent,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactThemeOption(
      AppTheme theme, bool isSelected, Brightness brightness) {
    return InkWell(
      onTap: () => _selectTheme(theme),
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary(brightness) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getThemeIcon(theme),
              size: AppConstants.iconSizeSmall,
              color: isSelected
                  ? brightness == Brightness.light
                      ? AppColors.lightPrimaryForeground
                      : AppColors.darkPrimaryForeground
                  : AppColors.mutedForeground(brightness),
            ),
            const SizedBox(width: AppConstants.smallPadding / 2),
            Text(
              theme.displayName,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(AppTheme theme) {
    if (theme != widget.selectedTheme) {
      _animationController.reset();
      _animationController.forward();
      widget.onThemeSelected(theme);
    }
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Iconsax.sun_1;
      case AppTheme.dark:
        return Iconsax.moon;
      case AppTheme.system:
        return Iconsax.setting_2;
    }
  }

  String _getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'settings.light_theme_description'.tr();
      case AppTheme.dark:
        return 'settings.dark_theme_description'.tr();
      case AppTheme.system:
        return 'settings.system_theme_description'.tr();
    }
  }
}
