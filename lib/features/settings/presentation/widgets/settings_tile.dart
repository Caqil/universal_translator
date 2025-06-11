// lib/features/settings/presentation/widgets/settings_tile.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Types of settings tiles
enum SettingsTileType {
  toggle,
  navigation,
  selection,
  action,
  info,
  slider,
}

/// Settings tile widget for displaying various setting options
class SettingsTile extends StatefulWidget {
  /// Title of the setting
  final String title;

  /// Description/subtitle of the setting
  final String? description;

  /// Leading icon
  final IconData? leadingIcon;

  /// Type of the settings tile
  final SettingsTileType type;

  /// Current value for toggle/selection types
  final dynamic value;

  /// Callback when the setting is changed
  final ValueChanged<dynamic>? onChanged;

  /// Callback when tile is tapped (for navigation/action types)
  final VoidCallback? onTap;

  /// List of options for selection type
  final List<SettingsOption>? options;

  /// Whether the setting is enabled
  final bool enabled;

  /// Custom trailing widget
  final Widget? customTrailing;

  /// Minimum value for slider type
  final double? minValue;

  /// Maximum value for slider type
  final double? maxValue;

  /// Number of divisions for slider type
  final int? divisions;

  /// Label for slider type
  final String Function(double)? sliderLabel;

  /// Whether to show border
  final bool showBorder;

  /// Custom background color
  final Color? backgroundColor;

  /// Badge text (for info/updates)
  final String? badge;

  /// Badge color
  final Color? badgeColor;

  const SettingsTile({
    super.key,
    required this.title,
    this.description,
    this.leadingIcon,
    required this.type,
    this.value,
    this.onChanged,
    this.onTap,
    this.options,
    this.enabled = true,
    this.customTrailing,
    this.minValue,
    this.maxValue,
    this.divisions,
    this.sliderLabel,
    this.showBorder = true,
    this.backgroundColor,
    this.badge,
    this.badgeColor,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.fastAnimationDuration,
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

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildTile(brightness),
        );
      },
    );
  }

  Widget _buildTile(Brightness brightness) {
    final isInteractive = widget.type == SettingsTileType.navigation ||
        widget.type == SettingsTileType.action ||
        widget.type == SettingsTileType.selection;

    return GestureDetector(
      onTapDown: isInteractive ? (_) => _onTapDown() : null,
      onTapUp: isInteractive ? (_) => _onTapUp() : null,
      onTapCancel: isInteractive ? _onTapUp : null,
      onTap: widget.enabled ? _onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: widget.showBorder
              ? Border.all(
                  color: AppColors.border(brightness),
                  width: 1,
                )
              : null,
        ),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.6,
          child: _buildTileContent(brightness),
        ),
      ),
    );
  }

  Widget _buildTileContent(Brightness brightness) {
    switch (widget.type) {
      case SettingsTileType.slider:
        return _buildSliderTile(brightness);
      default:
        return _buildStandardTile(brightness);
    }
  }

  Widget _buildStandardTile(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          if (widget.leadingIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: brightness == Brightness.light
                    ? AppColors.lightSecondary
                    : AppColors.darkSecondary,
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
              child: Icon(
                widget.leadingIcon,
                size: AppConstants.iconSizeRegular,
                color: AppColors.primary(brightness),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary(brightness),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.badge != null) ...[
                      const SizedBox(width: AppConstants.smallPadding),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.smallPadding,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.badgeColor ??
                              (brightness == Brightness.light
                                  ? AppColors.lightAccent
                                  : AppColors.darkAccent),
                          borderRadius: BorderRadius.circular(
                              AppConstants.circleBorderRadius),
                        ),
                        child: Text(
                          widget.badge!,
                          style: AppTextStyles.caption.copyWith(
                            color: brightness == Brightness.light
                                ? AppColors.lightPrimaryForeground
                                : AppColors.darkPrimaryForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.description!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          _buildTrailing(brightness),
        ],
      ),
    );
  }

  Widget _buildSliderTile(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.leadingIcon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: brightness == Brightness.light
                        ? AppColors.lightSecondary
                        : AppColors.darkSecondary,
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallBorderRadius),
                  ),
                  child: Icon(
                    widget.leadingIcon,
                    size: AppConstants.iconSizeRegular,
                    color: AppColors.primary(brightness),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary(brightness),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (widget.sliderLabel != null) ...[
                          Text(
                            widget.sliderLabel!(widget.value ?? 0.0),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: brightness == Brightness.light
                                  ? AppColors.lightAccent
                                  : AppColors.darkAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedForeground(brightness),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: brightness == Brightness.light
                  ? AppColors.lightAccent
                  : AppColors.darkAccent,
              inactiveTrackColor: brightness == Brightness.light
                  ? AppColors.lightSecondary
                  : AppColors.darkSecondary,
              thumbColor: brightness == Brightness.light
                  ? AppColors.lightAccent
                  : AppColors.darkAccent,
              overlayColor: (brightness == Brightness.light
                      ? AppColors.lightAccent
                      : AppColors.darkAccent)
                  .withOpacity(0.2),
              valueIndicatorColor: brightness == Brightness.light
                  ? AppColors.lightAccent
                  : AppColors.darkAccent,
              valueIndicatorTextStyle: AppTextStyles.caption.copyWith(
                color: brightness == Brightness.light
                    ? AppColors.lightPrimaryForeground
                    : AppColors.darkPrimaryForeground,
              ),
            ),
            child: Slider(
              value: (widget.value ?? 0.0).toDouble(),
              min: widget.minValue ?? 0.0,
              max: widget.maxValue ?? 1.0,
              divisions: widget.divisions,
              onChanged: widget.enabled
                  ? (value) => widget.onChanged?.call(value)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(Brightness brightness) {
    if (widget.customTrailing != null) {
      return widget.customTrailing!;
    }

    switch (widget.type) {
      case SettingsTileType.toggle:
        return Switch(
          value: widget.value ?? false,
          onChanged:
              widget.enabled ? (value) => widget.onChanged?.call(value) : null,
          activeColor: brightness == Brightness.light
              ? AppColors.lightAccent
              : AppColors.darkAccent,
          inactiveThumbColor: AppColors.mutedForeground(brightness),
          inactiveTrackColor: brightness == Brightness.light
              ? AppColors.lightSecondary
              : AppColors.darkSecondary,
        );

      case SettingsTileType.navigation:
        return Icon(
          Iconsax.arrow_right_3,
          size: AppConstants.iconSizeRegular,
          color: AppColors.mutedForeground(brightness),
        );

      case SettingsTileType.selection:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.value != null) ...[
              Text(
                _getSelectionDisplayValue(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedForeground(brightness),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
            ],
            Icon(
              Iconsax.arrow_down_1,
              size: AppConstants.iconSizeSmall,
              color: AppColors.mutedForeground(brightness),
            ),
          ],
        );

      case SettingsTileType.action:
        return Icon(
          Iconsax.flash_1,
          size: AppConstants.iconSizeRegular,
          color: brightness == Brightness.light
              ? AppColors.lightAccent
              : AppColors.darkAccent,
        );

      case SettingsTileType.info:
        return Icon(
          Iconsax.info_circle,
          size: AppConstants.iconSizeRegular,
          color: AppColors.mutedForeground(brightness),
        );

      case SettingsTileType.slider:
        return const SizedBox.shrink();
    }
  }

  String _getSelectionDisplayValue() {
    if (widget.options != null && widget.value != null) {
      final option = widget.options!.firstWhere(
        (opt) => opt.value == widget.value,
        orElse: () => SettingsOption(
          label: widget.value.toString(),
          value: widget.value,
        ),
      );
      return option.label;
    }
    return widget.value?.toString() ?? '';
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTap() {
    switch (widget.type) {
      case SettingsTileType.toggle:
        widget.onChanged?.call(!(widget.value ?? false));
        break;

      case SettingsTileType.navigation:
      case SettingsTileType.action:
        widget.onTap?.call();
        break;

      case SettingsTileType.selection:
        _showSelectionDialog();
        break;

      case SettingsTileType.info:
        widget.onTap?.call();
        break;

      case SettingsTileType.slider:
        // Slider handles its own interaction
        break;
    }
  }

  void _showSelectionDialog() {
    if (widget.options == null || widget.options!.isEmpty) return;

    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionBottomSheet(
        title: widget.title,
        options: widget.options!,
        selectedValue: widget.value,
        onSelected: (value) {
          widget.onChanged?.call(value);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Settings option for selection type tiles
class SettingsOption {
  final String label;
  final dynamic value;
  final String? description;
  final IconData? icon;

  const SettingsOption({
    required this.label,
    required this.value,
    this.description,
    this.icon,
  });
}

/// Bottom sheet for selection options
class _SelectionBottomSheet extends StatelessWidget {
  final String title;
  final List<SettingsOption> options;
  final dynamic selectedValue;
  final ValueChanged<dynamic> onSelected;

  const _SelectionBottomSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(brightness),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.mutedForeground(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding),
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Options
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option.value == selectedValue;

              return InkWell(
                onTap: () => onSelected(option.value),
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (brightness == Brightness.light
                                ? AppColors.lightAccent
                                : AppColors.darkAccent)
                            .withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallBorderRadius),
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
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: AppConstants.iconSizeRegular,
                          color: isSelected
                              ? brightness == Brightness.light
                                  ? AppColors.lightAccent
                                  : AppColors.darkAccent
                              : AppColors.mutedForeground(brightness),
                        ),
                        const SizedBox(width: AppConstants.defaultPadding),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            if (option.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                option.description!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mutedForeground(brightness),
                                ),
                              ),
                            ],
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
              );
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }
}
