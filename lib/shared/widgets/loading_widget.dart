import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';

/// Loading widget variants
enum LoadingVariant {
  page,
  overlay,
  inline,
  button,
  circular,
  linear,
}

/// Loading animation types
enum LoadingAnimation {
  circular,
  dots,
  pulse,
  wave,
  translation,
  custom,
}

/// Custom loading widget with consistent styling
class CustomLoadingWidget extends StatefulWidget {
  /// Loading message
  final String? message;

  /// Loading variant
  final LoadingVariant variant;

  /// Loading animation type
  final LoadingAnimation animation;

  /// Custom color
  final Color? color;

  /// Custom background color
  final Color? backgroundColor;

  /// Size of the loading indicator
  final double? size;

  /// Whether to show message
  final bool showMessage;

  /// Custom loading widget
  final Widget? customWidget;

  /// Whether loading can be cancelled
  final bool cancellable;

  /// Cancel callback
  final VoidCallback? onCancel;

  /// Progress value (0.0 to 1.0) for determinate loading
  final double? progress;

  /// Whether to blur background for overlay variant
  final bool blurBackground;

  const CustomLoadingWidget({
    super.key,
    this.message,
    this.variant = LoadingVariant.page,
    this.animation = LoadingAnimation.circular,
    this.color,
    this.backgroundColor,
    this.size,
    this.showMessage = true,
    this.customWidget,
    this.cancellable = false,
    this.onCancel,
    this.progress,
    this.blurBackground = true,
  });

  /// Create a page loading widget
  factory CustomLoadingWidget.page({
    String? message,
    LoadingAnimation animation = LoadingAnimation.translation,
    bool cancellable = false,
    VoidCallback? onCancel,
  }) {
    return CustomLoadingWidget(
      message: message ?? 'loading_default'.tr(),
      variant: LoadingVariant.page,
      animation: animation,
      cancellable: cancellable,
      onCancel: onCancel,
    );
  }

  /// Create an overlay loading widget
  factory CustomLoadingWidget.overlay({
    String? message,
    LoadingAnimation animation = LoadingAnimation.circular,
    bool blurBackground = true,
    bool cancellable = false,
    VoidCallback? onCancel,
  }) {
    return CustomLoadingWidget(
      message: message ?? 'loading_default'.tr(),
      variant: LoadingVariant.overlay,
      animation: animation,
      blurBackground: blurBackground,
      cancellable: cancellable,
      onCancel: onCancel,
    );
  }

  /// Create an inline loading widget
  factory CustomLoadingWidget.inline({
    String? message,
    LoadingAnimation animation = LoadingAnimation.dots,
    double? size,
  }) {
    return CustomLoadingWidget(
      message: message,
      variant: LoadingVariant.inline,
      animation: animation,
      size: size,
      showMessage: message != null,
    );
  }

  /// Create a button loading widget
  factory CustomLoadingWidget.button({
    Color? color,
    double? size,
  }) {
    return CustomLoadingWidget(
      variant: LoadingVariant.button,
      animation: LoadingAnimation.circular,
      color: color,
      size: size ?? AppConstants.iconSizeRegular,
      showMessage: false,
    );
  }

  /// Create a translation loading widget
  factory CustomLoadingWidget.translation({
    String? message,
    double? progress,
  }) {
    return CustomLoadingWidget(
      message: message ?? 'loading_translating'.tr(),
      variant: LoadingVariant.page,
      animation: LoadingAnimation.translation,
      progress: progress,
    );
  }

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    switch (widget.variant) {
      case LoadingVariant.page:
        return _buildPageLoading(context, brightness);
      case LoadingVariant.overlay:
        return _buildOverlayLoading(context, brightness);
      case LoadingVariant.inline:
        return _buildInlineLoading(context, brightness);
      case LoadingVariant.button:
        return _buildButtonLoading(context, brightness);
      case LoadingVariant.circular:
        return _buildCircularLoading(context, brightness);
      case LoadingVariant.linear:
        return _buildLinearLoading(context, brightness);
    }
  }

  Widget _buildPageLoading(BuildContext context, Brightness brightness) {
    return Scaffold(
      backgroundColor:
          widget.backgroundColor ?? AppColors.background(brightness),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: _buildLoadingContent(context, brightness),
              ),
            ),
            if (widget.cancellable) ...[
              Positioned(
                top: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                child: IconButton(
                  onPressed: widget.onCancel ?? () => context.pop(),
                  icon: const Icon(Iconsax.close_circle),
                  iconSize: AppConstants.iconSizeLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayLoading(BuildContext context, Brightness brightness) {
    return Container(
      color: widget.blurBackground
          ? AppColors.black50
          : (widget.backgroundColor ?? Colors.transparent),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.black20,
                blurRadius: AppConstants.highElevation,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildLoadingContent(context, brightness, isCompact: true),
        ),
      ),
    );
  }

  Widget _buildInlineLoading(BuildContext context, Brightness brightness) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(context, brightness),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(width: AppConstants.defaultPadding),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.color ?? AppColors.primary(brightness),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButtonLoading(BuildContext context, Brightness brightness) {
    return SizedBox(
      width: widget.size ?? AppConstants.iconSizeRegular,
      height: widget.size ?? AppConstants.iconSizeRegular,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? AppColors.primary(brightness),
        ),
      ),
    );
  }

  Widget _buildCircularLoading(BuildContext context, Brightness brightness) {
    return CircularProgressIndicator(
      value: widget.progress,
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.color ?? AppColors.primary(brightness),
      ),
    );
  }

  Widget _buildLinearLoading(BuildContext context, Brightness brightness) {
    return LinearProgressIndicator(
      value: widget.progress,
      backgroundColor: AppColors.mutedForeground(brightness).withOpacity(0.2),
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.color ?? AppColors.primary(brightness),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context, Brightness brightness,
      {bool isCompact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildLoadingIndicator(context, brightness),
        if (widget.showMessage && widget.message != null) ...[
          SizedBox(
              height: isCompact
                  ? AppConstants.defaultPadding
                  : AppConstants.largePadding),
          Text(
            widget.message!,
            style: (isCompact
                    ? AppTextStyles.bodyMedium
                    : AppTextStyles.titleMedium)
                .copyWith(
              color: widget.color ?? AppColors.primary(brightness),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.progress != null) ...[
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mutedForeground(brightness).withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color ?? AppColors.primary(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${(widget.progress! * 100).round()}%',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, Brightness brightness) {
    if (widget.customWidget != null) {
      return widget.customWidget!;
    }

    final effectiveColor = widget.color ?? AppColors.primary(brightness);
    final effectiveSize = widget.size ?? AppConstants.iconSizeExtraLarge;

    switch (widget.animation) {
      case LoadingAnimation.circular:
        return SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );

      case LoadingAnimation.dots:
        return _buildDotsAnimation(effectiveColor, effectiveSize);

      case LoadingAnimation.pulse:
        return _buildPulseAnimation(effectiveColor, effectiveSize);

      case LoadingAnimation.wave:
        return _buildWaveAnimation(effectiveColor, effectiveSize);

      case LoadingAnimation.translation:
        return _buildTranslationAnimation(effectiveColor, effectiveSize);

      case LoadingAnimation.custom:
        return _buildCustomAnimation(effectiveColor, effectiveSize);
    }
  }

  Widget _buildDotsAnimation(Color color, double size) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue =
                (_animationController.value - delay).clamp(0.0, 1.0);
            final opacity = (animationValue < 0.5)
                ? animationValue * 2
                : (1 - animationValue) * 2;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.05),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseAnimation(Color color, double size) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveAnimation(Color color, double size) {
    return SizedBox(
      width: size,
      height: size * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = (_animationController.value - delay) % 1.0;
              final height =
                  (sin(animationValue * 2 * pi) * 0.5 + 0.5) * size * 0.3;

              return Container(
                width: size * 0.08,
                height: height + size * 0.1,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildTranslationAnimation(Color color, double size) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Transform.rotate(
              angle: _animationController.value * 2 * pi,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 2,
                      left: size / 2 - 2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center icon
            Icon(
              Iconsax.translate,
              size: size * 0.4,
              color: color,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomAnimation(Color color, double size) {
    // Check if Lottie file exists, otherwise fallback to circular
    try {
      return Lottie.asset(
        'assets/animations/loading.json',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return _buildDotsAnimation(color, size);
    }
  }
}
