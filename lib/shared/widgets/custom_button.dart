import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';

/// Button variants
enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  success,
  warning,
}

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom button widget with consistent styling
class CustomButton extends StatefulWidget {
  /// Button text
  final String? text;

  /// Custom child widget
  final Widget? child;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant
  final ButtonVariant variant;

  /// Button size
  final ButtonSize size;

  /// Whether button is loading
  final bool isLoading;

  /// Whether button is disabled
  final bool isDisabled;

  /// Leading icon
  final IconData? icon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  /// Custom border color
  final Color? borderColor;

  /// Whether button should expand to full width
  final bool fullWidth;

  /// Custom border radius
  final double? borderRadius;

  /// Custom elevation
  final double? elevation;

  /// Loading widget
  final Widget? loadingWidget;

  /// Haptic feedback on press
  final bool enableHapticFeedback;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.fullWidth = false,
    this.borderRadius,
    this.elevation,
    this.loadingWidget,
    this.enableHapticFeedback = true,
  }) : assert(text != null || child != null,
            'Either text or child must be provided');

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
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
      begin: 1.0,
      end: 0.95,
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
    final buttonStyle = _getButtonStyle(context, brightness);
    final isEffectivelyDisabled =
        widget.isDisabled || widget.isLoading || widget.onPressed == null;

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildButton(context, buttonStyle, isEffectivelyDisabled),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButton(
      BuildContext context, _ButtonStyle style, bool isEffectivelyDisabled) {
    return GestureDetector(
      onTapDown:
          isEffectivelyDisabled ? null : (_) => _animationController.forward(),
      onTapUp:
          isEffectivelyDisabled ? null : (_) => _animationController.reverse(),
      onTapCancel:
          isEffectivelyDisabled ? null : () => _animationController.reverse(),
      child: Material(
        color: style.backgroundColor,
        elevation: style.elevation,
        borderRadius: BorderRadius.circular(style.borderRadius),
        child: InkWell(
          onTap: isEffectivelyDisabled ? null : _handleTap,
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: Container(
            padding: style.padding,
            decoration: BoxDecoration(
              border: style.border,
              borderRadius: BorderRadius.circular(style.borderRadius),
            ),
            child: _buildButtonContent(style, isEffectivelyDisabled),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(_ButtonStyle style, bool isEffectivelyDisabled) {
    if (widget.isLoading) {
      return _buildLoadingContent(style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: style.iconSize,
            color: isEffectivelyDisabled
                ? style.disabledForegroundColor
                : style.foregroundColor,
          ),
          SizedBox(width: style.spacing),
        ],
        Flexible(
          child: widget.child ??
              Text(
                widget.text!,
                style: style.textStyle.copyWith(
                  color: isEffectivelyDisabled
                      ? style.disabledForegroundColor
                      : style.foregroundColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: style.spacing),
          Icon(
            widget.trailingIcon,
            size: style.iconSize,
            color: isEffectivelyDisabled
                ? style.disabledForegroundColor
                : style.foregroundColor,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingContent(_ButtonStyle style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.loadingWidget ??
            SizedBox(
              width: style.iconSize,
              height: style.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(style.foregroundColor),
              ),
            ),
        if (widget.text != null || widget.child != null) ...[
          SizedBox(width: style.spacing),
          Flexible(
            child: widget.child ??
                Text(
                  widget.text!,
                  style: style.textStyle.copyWith(color: style.foregroundColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ],
    );
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      switch (widget.variant) {
        case ButtonVariant.destructive:
          HapticFeedback.heavyImpact();
          break;
        default:
          HapticFeedback.lightImpact();
          break;
      }
    }
    widget.onPressed?.call();
  }

  _ButtonStyle _getButtonStyle(BuildContext context, Brightness brightness) {
    final colors = _getButtonColors(brightness);
    final dimensions = _getButtonDimensions();

    return _ButtonStyle(
      backgroundColor: widget.backgroundColor ?? colors.backgroundColor,
      foregroundColor: widget.foregroundColor ?? colors.foregroundColor,
      disabledForegroundColor: colors.disabledForegroundColor,
      border: colors.border,
      elevation: widget.elevation ?? colors.elevation,
      borderRadius: widget.borderRadius ?? AppConstants.defaultBorderRadius,
      padding: dimensions.padding,
      textStyle: dimensions.textStyle,
      iconSize: dimensions.iconSize,
      spacing: dimensions.spacing,
    );
  }

  _ButtonColors _getButtonColors(Brightness brightness) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: AppColors.primary(brightness),
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightPrimaryForeground
              : AppColors.darkPrimaryForeground,
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: AppConstants.defaultElevation,
        );

      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: brightness == Brightness.light
              ? AppColors.lightSecondary
              : AppColors.darkSecondary,
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightSecondaryForeground
              : AppColors.darkSecondaryForeground,
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: 0,
        );

      case ButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary(brightness),
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          border: Border.all(
            color: widget.borderColor ?? AppColors.border(brightness),
            width: 1,
          ),
          elevation: 0,
        );

      case ButtonVariant.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary(brightness),
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: 0,
        );

      case ButtonVariant.destructive:
        return _ButtonColors(
          backgroundColor: brightness == Brightness.light
              ? AppColors.lightDestructive
              : AppColors.darkDestructive,
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightDestructiveForeground
              : AppColors.darkDestructiveForeground,
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: AppConstants.defaultElevation,
        );

      case ButtonVariant.success:
        return _ButtonColors(
          backgroundColor: brightness == Brightness.light
              ? AppColors.lightSuccess
              : AppColors.darkSuccess,
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightSuccessForeground
              : AppColors.darkSuccessForeground,
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: AppConstants.defaultElevation,
        );

      case ButtonVariant.warning:
        return _ButtonColors(
          backgroundColor: brightness == Brightness.light
              ? AppColors.lightWarning
              : AppColors.darkWarning,
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightWarningForeground
              : AppColors.darkWarningForeground,
          disabledForegroundColor: AppColors.mutedForeground(brightness),
          elevation: AppConstants.defaultElevation,
        );
    }
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case ButtonSize.small:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          textStyle: AppTextStyles.labelMedium,
          iconSize: AppConstants.iconSizeSmall,
          spacing: AppConstants.smallPadding / 2,
        );

      case ButtonSize.medium:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: AppTextStyles.button,
          iconSize: AppConstants.iconSizeRegular,
          spacing: AppConstants.smallPadding,
        );

      case ButtonSize.large:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.extraLargePadding,
            vertical: AppConstants.largePadding,
          ),
          textStyle: AppTextStyles.titleMedium,
          iconSize: AppConstants.iconSizeMedium,
          spacing: AppConstants.defaultPadding,
        );
    }
  }
}

class _ButtonStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledForegroundColor;
  final Border? border;
  final double elevation;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double spacing;

  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledForegroundColor,
    this.border,
    required this.elevation,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.spacing,
  });
}

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledForegroundColor;
  final Border? border;
  final double elevation;

  const _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledForegroundColor,
    this.border,
    required this.elevation,
  });
}

class _ButtonDimensions {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double spacing;

  const _ButtonDimensions({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.spacing,
  });
}
