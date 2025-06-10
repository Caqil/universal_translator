import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

/// Application text styles following shadcn/ui design system
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ============ Base Font Configuration ============

  static const String _fontFamily = 'Inter';
  static const FontWeight _regular = FontWeight.w400;
  static const FontWeight _medium = FontWeight.w500;
  static const FontWeight _semiBold = FontWeight.w600;
  static const FontWeight _bold = FontWeight.w700;

  // ============ Display Styles ============

  /// Display Large - 57sp
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57.0,
    fontWeight: _bold,
    height: 1.12,
    letterSpacing: -0.25,
  );

  /// Display Medium - 45sp
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45.0,
    fontWeight: _bold,
    height: 1.16,
    letterSpacing: 0.0,
  );

  /// Display Small - 36sp
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36.0,
    fontWeight: _bold,
    height: 1.22,
    letterSpacing: 0.0,
  );

  // ============ Headline Styles ============

  /// Headline Large - 32sp
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32.0,
    fontWeight: _bold,
    height: 1.25,
    letterSpacing: 0.0,
  );

  /// Headline Medium - 28sp
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeHeading,
    fontWeight: _semiBold,
    height: 1.29,
    letterSpacing: 0.0,
  );

  /// Headline Small - 24sp
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeTitle,
    fontWeight: _semiBold,
    height: 1.33,
    letterSpacing: 0.0,
  );

  // ============ Title Styles ============

  /// Title Large - 22sp
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22.0,
    fontWeight: _semiBold,
    height: 1.27,
    letterSpacing: 0.0,
  );

  /// Title Medium - 16sp
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: _medium,
    height: 1.5,
    letterSpacing: 0.15,
  );

  /// Title Small - 14sp
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // ============ Label Styles ============

  /// Label Large - 14sp
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Label Medium - 12sp
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: _medium,
    height: 1.33,
    letterSpacing: 0.5,
  );

  /// Label Small - 11sp
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.0,
    fontWeight: _medium,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ============ Body Styles ============

  /// Body Large - 16sp
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: _regular,
    height: 1.5,
    letterSpacing: 0.5,
  );

  /// Body Medium - 14sp
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  /// Body Small - 12sp
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: _regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============ Feature-Specific Styles ============

  /// Translation Input Text
  static const TextStyle translationInput = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: _regular,
    height: 1.44,
    letterSpacing: 0.0,
  );

  /// Translation Output Text
  static const TextStyle translationOutput = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: _medium,
    height: 1.44,
    letterSpacing: 0.0,
  );

  /// Language Name Text
  static const TextStyle languageName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: _medium,
    height: 1.5,
    letterSpacing: 0.0,
  );

  /// Language Native Name Text
  static const TextStyle languageNativeName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _regular,
    height: 1.43,
    letterSpacing: 0.0,
  );

  /// Button Text
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _medium,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Caption Text
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: _regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Overline Text
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.0,
    fontWeight: _medium,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // ============ Specialized Styles ============

  /// Code/Monospace Text
  static const TextStyle code = TextStyle(
    fontFamily: 'Consolas',
    fontSize: AppConstants.fontSizeRegular,
    fontWeight: _regular,
    height: 1.43,
    letterSpacing: 0.0,
  );

  /// Error Text
  static const TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: _regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Helper Text
  static const TextStyle helper = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: _regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============ Helper Methods ============

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply adaptive color based on brightness
  static TextStyle withAdaptiveColor({
    required TextStyle style,
    required Color lightColor,
    required Color darkColor,
    required Brightness brightness,
  }) {
    final color = brightness == Brightness.light ? lightColor : darkColor;
    return style.copyWith(color: color);
  }

  /// Get text style with primary color
  static TextStyle withPrimaryColor(TextStyle style, Brightness brightness) {
    return withAdaptiveColor(
      style: style,
      lightColor: AppColors.lightPrimary,
      darkColor: AppColors.darkPrimary,
      brightness: brightness,
    );
  }

  /// Get text style with muted color
  static TextStyle withMutedColor(TextStyle style, Brightness brightness) {
    return withAdaptiveColor(
      style: style,
      lightColor: AppColors.lightMutedForeground,
      darkColor: AppColors.darkMutedForeground,
      brightness: brightness,
    );
  }

  /// Get text style with destructive color
  static TextStyle withDestructiveColor(
      TextStyle style, Brightness brightness) {
    return withAdaptiveColor(
      style: style,
      lightColor: AppColors.lightDestructive,
      darkColor: AppColors.darkDestructive,
      brightness: brightness,
    );
  }

  /// Get text style with success color
  static TextStyle withSuccessColor(TextStyle style, Brightness brightness) {
    return withAdaptiveColor(
      style: style,
      lightColor: AppColors.lightSuccess,
      darkColor: AppColors.darkSuccess,
      brightness: brightness,
    );
  }

  /// Get text style with warning color
  static TextStyle withWarningColor(TextStyle style, Brightness brightness) {
    return withAdaptiveColor(
      style: style,
      lightColor: AppColors.lightWarning,
      darkColor: AppColors.darkWarning,
      brightness: brightness,
    );
  }

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(double baseFontSize, double screenWidth) {
    if (screenWidth <= 360) {
      return baseFontSize * 0.9; // Small screens
    } else if (screenWidth <= 768) {
      return baseFontSize; // Medium screens
    } else {
      return baseFontSize * 1.1; // Large screens
    }
  }

  /// Get text style with responsive font size
  static TextStyle withResponsiveFontSize(TextStyle style, double screenWidth) {
    final responsiveFontSize = getResponsiveFontSize(
      style.fontSize ?? AppConstants.fontSizeRegular,
      screenWidth,
    );
    return style.copyWith(fontSize: responsiveFontSize);
  }
}
