import 'package:flutter/material.dart';

/// Application color scheme following shadcn/ui design system
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============ Light Theme Colors ============

  /// Primary colors - Light theme
  static const Color lightPrimary = Color(0xFF0F172A);
  static const Color lightPrimaryForeground = Color(0xFFFAFAFA);

  /// Secondary colors - Light theme
  static const Color lightSecondary = Color(0xFFF1F5F9);
  static const Color lightSecondaryForeground = Color(0xFF0F172A);

  /// Accent colors - Light theme
  static const Color lightAccent = Color(0xFFF1F5F9);
  static const Color lightAccentForeground = Color(0xFF0F172A);

  /// Muted colors - Light theme
  static const Color lightMuted = Color(0xFFF1F5F9);
  static const Color lightMutedForeground = Color(0xFF64748B);

  /// Destructive colors - Light theme
  static const Color lightDestructive = Color(0xFFEF4444);
  static const Color lightDestructiveForeground = Color(0xFFFAFAFA);

  /// Border and input colors - Light theme
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightInput = Color(0xFFE2E8F0);
  static const Color lightRing = Color(0xFF3B82F6);

  /// Background colors - Light theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF0F172A);

  /// Card colors - Light theme
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardForeground = Color(0xFF0F172A);

  /// Popover colors - Light theme
  static const Color lightPopover = Color(0xFFFFFFFF);
  static const Color lightPopoverForeground = Color(0xFF0F172A);

  // ============ Dark Theme Colors ============

  /// Primary colors - Dark theme
  static const Color darkPrimary = Color(0xFFFAFAFA);
  static const Color darkPrimaryForeground = Color(0xFF18181B);

  /// Secondary colors - Dark theme
  static const Color darkSecondary = Color(0xFF27272A);
  static const Color darkSecondaryForeground = Color(0xFFFAFAFA);

  /// Accent colors - Dark theme
  static const Color darkAccent = Color(0xFF27272A);
  static const Color darkAccentForeground = Color(0xFFFAFAFA);

  /// Muted colors - Dark theme
  static const Color darkMuted = Color(0xFF27272A);
  static const Color darkMutedForeground = Color(0xFFA1A1AA);

  /// Destructive colors - Dark theme
  static const Color darkDestructive = Color(0xFF7F1D1D);
  static const Color darkDestructiveForeground = Color(0xFFFAFAFA);

  /// Border and input colors - Dark theme
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkInput = Color(0xFF27272A);
  static const Color darkRing = Color(0xFF3B82F6);

  /// Background colors - Dark theme
  static const Color darkBackground = Color(0xFF09090B);
  static const Color darkForeground = Color(0xFFFAFAFA);

  /// Card colors - Dark theme
  static const Color darkCard = Color(0xFF09090B);
  static const Color darkCardForeground = Color(0xFFFAFAFA);

  /// Popover colors - Dark theme
  static const Color darkPopover = Color(0xFF09090B);
  static const Color darkPopoverForeground = Color(0xFFFAFAFA);

  // ============ Semantic Colors ============

  /// Success colors
  static const Color lightSuccess = Color(0xFF22C55E);
  static const Color lightSuccessForeground = Color(0xFFFFFFFF);
  static const Color darkSuccess = Color(0xFF16A34A);
  static const Color darkSuccessForeground = Color(0xFFFFFFFF);

  /// Warning colors
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightWarningForeground = Color(0xFFFFFFFF);
  static const Color darkWarning = Color(0xFFEAB308);
  static const Color darkWarningForeground = Color(0xFF000000);

  /// Info colors
  static const Color lightInfo = Color(0xFF3B82F6);
  static const Color lightInfoForeground = Color(0xFFFFFFFF);
  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoForeground = Color(0xFF000000);

  // ============ Feature-Specific Colors ============

  /// Translation feature colors
  static const Color translationSource = Color(0xFF3B82F6);
  static const Color translationTarget = Color(0xFF10B981);
  static const Color translationNeutral = Color(0xFF6B7280);

  /// Voice/Speech colors
  static const Color voiceActive = Color(0xFFEF4444);
  static const Color voiceInactive = Color(0xFF6B7280);
  static const Color voiceListening = Color(0xFFF59E0B);

  /// Camera/OCR colors
  static const Color cameraActive = Color(0xFF8B5CF6);
  static const Color cameraOverlay = Color(0x80000000);
  static const Color ocrHighlight = Color(0x4D3B82F6);

  /// Language detection confidence colors
  static const Color highConfidence = Color(0xFF22C55E);
  static const Color mediumConfidence = Color(0xFFF59E0B);
  static const Color lowConfidence = Color(0xFFEF4444);

  // ============ Utility Colors ============

  /// Transparent
  static const Color transparent = Colors.transparent;

  /// White with opacity
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white90 = Color(0xE6FFFFFF);

  /// Black with opacity
  static const Color black10 = Color(0x1A000000);
  static const Color black20 = Color(0x33000000);
  static const Color black30 = Color(0x4D000000);
  static const Color black50 = Color(0x80000000);
  static const Color black70 = Color(0xB3000000);
  static const Color black90 = Color(0xE6000000);

  // ============ Helper Methods ============

  /// Get color based on theme brightness
  static Color adaptive({
    required Color light,
    required Color dark,
    required Brightness brightness,
  }) {
    return brightness == Brightness.light ? light : dark;
  }

  /// Get primary color for theme
  static Color primary(Brightness brightness) {
    return adaptive(
      light: lightPrimary,
      dark: darkPrimary,
      brightness: brightness,
    );
  }

  /// Get background color for theme
  static Color background(Brightness brightness) {
    return adaptive(
      light: lightBackground,
      dark: darkBackground,
      brightness: brightness,
    );
  }

  /// Get surface color for theme
  static Color surface(Brightness brightness) {
    return adaptive(
      light: lightCard,
      dark: darkCard,
      brightness: brightness,
    );
  }

  /// Get border color for theme
  static Color border(Brightness brightness) {
    return adaptive(
      light: lightBorder,
      dark: darkBorder,
      brightness: brightness,
    );
  }

  /// Get muted foreground color for theme
  static Color mutedForeground(Brightness brightness) {
    return adaptive(
      light: lightMutedForeground,
      dark: darkMutedForeground,
      brightness: brightness,
    );
  }
}
