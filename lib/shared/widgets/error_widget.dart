import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/utils/extensions.dart';
import 'custom_button.dart';

/// Error widget variants
enum ErrorVariant {
  page,
  inline,
  card,
}

/// Custom error widget with consistent styling
class CustomErrorWidget extends StatelessWidget {
  /// Error message
  final String? message;

  /// Error title
  final String? title;

  /// Error description
  final String? description;

  /// Error icon
  final IconData? icon;

  /// Error variant
  final ErrorVariant variant;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Custom action button text
  final String? actionText;

  /// Custom action callback
  final VoidCallback? onAction;

  /// Whether to show stack trace in debug mode
  final bool showStackTrace;

  /// Stack trace for debugging
  final StackTrace? stackTrace;

  /// Whether error is dismissible
  final bool isDismissible;

  /// Dismiss callback
  final VoidCallback? onDismiss;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  /// Whether to center content
  final bool centerContent;

  const CustomErrorWidget({
    super.key,
    this.message,
    this.title,
    this.description,
    this.icon,
    this.variant = ErrorVariant.page,
    this.onRetry,
    this.actionText,
    this.onAction,
    this.showStackTrace = false,
    this.stackTrace,
    this.isDismissible = false,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.centerContent = true,
  });

  /// Create a network error widget
  factory CustomErrorWidget.network({
    String? message,
    VoidCallback? onRetry,
    ErrorVariant variant = ErrorVariant.page,
  }) {
    return CustomErrorWidget(
      title: 'error_network_title'.tr(),
      message: message ?? 'error_network_message'.tr(),
      description: 'error_network_description'.tr(),
      icon: Iconsax.wifi_square,
      variant: variant,
      onRetry: onRetry,
      actionText: 'button_retry'.tr(),
      onAction: onRetry,
    );
  }

  /// Create a server error widget
  factory CustomErrorWidget.server({
    String? message,
    VoidCallback? onRetry,
    ErrorVariant variant = ErrorVariant.page,
  }) {
    return CustomErrorWidget(
      title: 'error_server_title'.tr(),
      message: message ?? 'error_server_message'.tr(),
      description: 'error_server_description'.tr(),
      icon: Iconsax.warning_2,
      variant: variant,
      onRetry: onRetry,
      actionText: 'button_retry'.tr(),
      onAction: onRetry,
    );
  }

  /// Create a not found error widget
  factory CustomErrorWidget.notFound({
    String? message,
    VoidCallback? onAction,
    String? actionText,
    ErrorVariant variant = ErrorVariant.page,
  }) {
    return CustomErrorWidget(
      title: 'error_not_found_title'.tr(),
      message: message ?? 'error_not_found_message'.tr(),
      description: 'error_not_found_description'.tr(),
      icon: Iconsax.search_status,
      variant: variant,
      actionText: actionText ?? 'button_go_home'.tr(),
      onAction: onAction,
    );
  }

  /// Create a permission error widget
  factory CustomErrorWidget.permission({
    String? message,
    VoidCallback? onAction,
    String? actionText,
    ErrorVariant variant = ErrorVariant.page,
  }) {
    return CustomErrorWidget(
      title: 'error_permission_title'.tr(),
      message: message ?? 'error_permission_message'.tr(),
      description: 'error_permission_description'.tr(),
      icon: Iconsax.lock,
      variant: variant,
      actionText: actionText ?? 'button_settings'.tr(),
      onAction: onAction,
    );
  }

  /// Create a translation error widget
  factory CustomErrorWidget.translation({
    String? message,
    VoidCallback? onRetry,
    ErrorVariant variant = ErrorVariant.inline,
  }) {
    return CustomErrorWidget(
      title: 'error_translation_title'.tr(),
      message: message ?? 'error_translation_message'.tr(),
      description: 'error_translation_description'.tr(),
      icon: Iconsax.translate,
      variant: variant,
      onRetry: onRetry,
      actionText: 'button_retry'.tr(),
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    switch (variant) {
      case ErrorVariant.page:
        return _buildPageError(context, brightness);
      case ErrorVariant.inline:
        return _buildInlineError(context, brightness);
      case ErrorVariant.card:
        return _buildCardError(context, brightness);
    }
  }

  Widget _buildPageError(BuildContext context, Brightness brightness) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background(brightness),
      appBar: isDismissible
          ? AppBar(
              leading: IconButton(
                onPressed: onDismiss ?? () => context.pop(),
                icon: const Icon(Iconsax.arrow_left_2),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: _buildErrorContent(context, brightness),
        ),
      ),
    );
  }

  Widget _buildInlineError(BuildContext context, Brightness brightness) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: brightness == Brightness.light
              ? AppColors.lightDestructive.withOpacity(0.3)
              : AppColors.darkDestructive.withOpacity(0.3),
        ),
      ),
      child: _buildErrorContent(context, brightness, isCompact: true),
    );
  }

  Widget _buildCardError(BuildContext context, Brightness brightness) {
    return Card(
      color: backgroundColor ?? AppColors.surface(brightness),
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        side: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.lightDestructive.withOpacity(0.3)
              : AppColors.darkDestructive.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: _buildErrorContent(context, brightness),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Brightness brightness,
      {bool isCompact = false}) {
    final effectiveTextColor = textColor ?? AppColors.primary(brightness);
    final errorColor = brightness == Brightness.light
        ? AppColors.lightDestructive
        : AppColors.darkDestructive;

    return Column(
      mainAxisAlignment:
          centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Dismiss button for card/inline variants
        if (isDismissible && variant != ErrorVariant.page) ...[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Iconsax.close_circle,
                color: AppColors.mutedForeground(brightness),
                size: AppConstants.iconSizeRegular,
              ),
              splashRadius: AppConstants.iconSizeRegular,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],

        // Error icon
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isCompact
                  ? AppConstants.iconSizeLarge
                  : AppConstants.iconSizeExtraLarge,
              color: errorColor,
            ),
          ),
          SizedBox(
              height: isCompact
                  ? AppConstants.defaultPadding
                  : AppConstants.largePadding),
        ],

        // Error title
        if (title != null) ...[
          Text(
            title!,
            style: (isCompact
                    ? AppTextStyles.titleMedium
                    : AppTextStyles.headlineSmall)
                .copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],

        // Error message
        if (message != null) ...[
          Text(
            message!,
            style:
                (isCompact ? AppTextStyles.bodySmall : AppTextStyles.bodyMedium)
                    .copyWith(
              color: effectiveTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null)
            const SizedBox(height: AppConstants.smallPadding),
        ],

        // Error description
        if (description != null) ...[
          Text(
            description!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: isCompact
                  ? AppConstants.defaultPadding
                  : AppConstants.largePadding),
        ],

        // Action buttons
        if (onRetry != null || onAction != null) ...[
          SizedBox(
              height: isCompact
                  ? AppConstants.defaultPadding
                  : AppConstants.largePadding),
          _buildActionButtons(context, isCompact),
        ],

        // Stack trace in debug mode
        if (showStackTrace && stackTrace != null) ...[
          const SizedBox(height: AppConstants.largePadding),
          _buildStackTrace(context, brightness),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final buttons = <Widget>[];

    if (onRetry != null) {
      buttons.add(
        CustomButton(
          text: 'button_retry'.tr(),
          onPressed: onRetry,
          icon: Iconsax.refresh_2,
          variant: ButtonVariant.primary,
          size: isCompact ? ButtonSize.small : ButtonSize.medium,
        ),
      );
    }

    if (onAction != null) {
      buttons.add(
        CustomButton(
          text: actionText ?? 'button_action'.tr(),
          onPressed: onAction,
          variant:
              onRetry != null ? ButtonVariant.outline : ButtonVariant.primary,
          size: isCompact ? ButtonSize.small : ButtonSize.medium,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    if (buttons.length == 1) {
      return buttons.first;
    }

    return isCompact
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttons
                .expand((button) =>
                    [button, const SizedBox(width: AppConstants.smallPadding)])
                .take(buttons.length * 2 - 1)
                .toList(),
          )
        : Column(
            children: buttons
                .expand((button) => [
                      button,
                      const SizedBox(height: AppConstants.defaultPadding)
                    ])
                .take(buttons.length * 2 - 1)
                .toList(),
          );
  }

  Widget _buildStackTrace(BuildContext context, Brightness brightness) {
    return ExpansionTile(
      title: Text(
        'Debug Information',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.mutedForeground(brightness),
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.mutedForeground(brightness).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Text(
            stackTrace.toString(),
            style: AppTextStyles.code.copyWith(
              color: AppColors.mutedForeground(brightness),
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ),
      ],
    );
  }
}
