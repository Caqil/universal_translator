import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/app_constants.dart';

/// Application theme configuration using shadcn/ui design system
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============ Light Theme ============

  static ShadThemeData get lightShadTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadColorScheme(
        selection: AppColors.lightBorder,
        primary: AppColors.lightPrimary,
        primaryForeground: AppColors.lightPrimaryForeground,
        secondary: AppColors.lightSecondary,
        secondaryForeground: AppColors.lightSecondaryForeground,
        destructive: AppColors.lightDestructive,
        destructiveForeground: AppColors.lightDestructiveForeground,
        muted: AppColors.lightMuted,
        mutedForeground: AppColors.lightMutedForeground,
        accent: AppColors.lightAccent,
        accentForeground: AppColors.lightAccentForeground,
        popover: AppColors.lightPopover,
        popoverForeground: AppColors.lightPopoverForeground,
        card: AppColors.lightCard,
        cardForeground: AppColors.lightCardForeground,
        border: AppColors.lightBorder,
        input: AppColors.lightInput,
        ring: AppColors.lightRing,
        background: AppColors.lightBackground,
        foreground: AppColors.lightForeground,
      ),
      textTheme: ShadTextTheme(
        family: AppTextStyles.fontFamily,
        h1Large: AppTextStyles.displayLarge,
        h1: AppTextStyles.displayMedium,
        h2: AppTextStyles.displaySmall,
        h3: AppTextStyles.headlineLarge,
        h4: AppTextStyles.headlineMedium,
        p: AppTextStyles.bodyLarge,
        blockquote: AppTextStyles.bodyMedium,
        table: AppTextStyles.bodySmall,
        list: AppTextStyles.bodyMedium,
        lead: AppTextStyles.titleLarge,
        large: AppTextStyles.titleMedium,
        small: AppTextStyles.labelMedium,
        muted: AppTextStyles.caption,
      ),
      radius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    );
  }

  /// Get ShadCN UI theme data for dark theme
  static ShadThemeData get darkShadTheme {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadColorScheme(
        selection: AppColors.darkBorder,
        primary: AppColors.darkPrimary,
        primaryForeground: AppColors.darkPrimaryForeground,
        secondary: AppColors.darkSecondary,
        secondaryForeground: AppColors.darkSecondaryForeground,
        destructive: AppColors.darkDestructive,
        destructiveForeground: AppColors.darkDestructiveForeground,
        muted: AppColors.darkMuted,
        mutedForeground: AppColors.darkMutedForeground,
        accent: AppColors.darkAccent,
        accentForeground: AppColors.darkAccentForeground,
        popover: AppColors.darkPopover,
        popoverForeground: AppColors.darkPopoverForeground,
        card: AppColors.darkCard,
        cardForeground: AppColors.darkCardForeground,
        border: AppColors.darkBorder,
        input: AppColors.darkInput,
        ring: AppColors.darkRing,
        background: AppColors.darkBackground,
        foreground: AppColors.darkForeground,
      ),
      textTheme: ShadTextTheme(
        family: AppTextStyles.fontFamily,
        h1Large: AppTextStyles.displayLarge,
        h1: AppTextStyles.displayMedium,
        h2: AppTextStyles.displaySmall,
        h3: AppTextStyles.headlineLarge,
        h4: AppTextStyles.headlineMedium,
        p: AppTextStyles.bodyLarge,
        blockquote: AppTextStyles.bodyMedium,
        table: AppTextStyles.bodySmall,
        list: AppTextStyles.bodyMedium,
        lead: AppTextStyles.titleLarge,
        large: AppTextStyles.titleMedium,
        small: AppTextStyles.labelMedium,
        muted: AppTextStyles.caption,
      ),
      radius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    );
  }
}
