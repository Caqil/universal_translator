import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/app_constants.dart';

/// Application theme configuration using shadcn/ui design system
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============ Light Theme ============

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightPrimaryForeground,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightSecondaryForeground,
        tertiary: AppColors.lightAccent,
        onTertiary: AppColors.lightAccentForeground,
        error: AppColors.lightDestructive,
        onError: AppColors.lightDestructiveForeground,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightCardForeground,
        onSurfaceVariant: AppColors.lightMutedForeground,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightInput,
        shadow: AppColors.black20,
        scrim: AppColors.black50,
        inverseSurface: AppColors.lightMuted,
        onInverseSurface: AppColors.lightMutedForeground,
        inversePrimary: AppColors.lightPrimary,
        surfaceTint: AppColors.lightPrimary,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightForeground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: AppColors.lightForeground,
          size: AppConstants.iconSizeRegular,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(Brightness.light),

      // Button Themes
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      filledButtonTheme: _buildFilledButtonTheme(Brightness.light),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),

      // Card Theme
      cardTheme: _buildCardTheme(Brightness.light),

      // Dialog Theme
      dialogTheme: _buildDialogTheme(Brightness.light),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme:
          _buildBottomNavigationBarTheme(Brightness.light),

      // Navigation Bar Theme
      navigationBarTheme: _buildNavigationBarTheme(Brightness.light),

      // Floating Action Button Theme
      floatingActionButtonTheme: _buildFABTheme(Brightness.light),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.lightForeground,
        size: AppConstants.iconSizeRegular,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: _buildListTileTheme(Brightness.light),

      // Switch Theme
      switchTheme: _buildSwitchTheme(Brightness.light),

      // Checkbox Theme
      checkboxTheme: _buildCheckboxTheme(Brightness.light),

      // Radio Theme
      radioTheme: _buildRadioTheme(Brightness.light),

      // Slider Theme
      sliderTheme: _buildSliderTheme(Brightness.light),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lightPrimary,
        linearTrackColor: AppColors.lightMuted,
        circularTrackColor: AppColors.lightMuted,
      ),

      // Tab Bar Theme
      tabBarTheme: _buildTabBarTheme(Brightness.light),

      // Chip Theme
      chipTheme: _buildChipTheme(Brightness.light),

      // Tooltip Theme
      tooltipTheme: _buildTooltipTheme(Brightness.light),

      // Snack Bar Theme
      snackBarTheme: _buildSnackBarTheme(Brightness.light),

      // Banner Theme
      bannerTheme: _buildBannerTheme(Brightness.light),
    );
  }

  // ============ Dark Theme ============

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkPrimaryForeground,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkSecondaryForeground,
        tertiary: AppColors.darkAccent,
        onTertiary: AppColors.darkAccentForeground,
        error: AppColors.darkDestructive,
        onError: AppColors.darkDestructiveForeground,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkCardForeground,
        onSurfaceVariant: AppColors.darkMutedForeground,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkInput,
        shadow: AppColors.black50,
        scrim: AppColors.black70,
        inverseSurface: AppColors.darkMuted,
        onInverseSurface: AppColors.darkMutedForeground,
        inversePrimary: AppColors.darkPrimary,
        surfaceTint: AppColors.darkPrimary,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkForeground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(
          color: AppColors.darkForeground,
          size: AppConstants.iconSizeRegular,
        ),
      ),

      // Text Theme
      textTheme: _buildTextTheme(Brightness.dark),

      // Button Themes
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      filledButtonTheme: _buildFilledButtonTheme(Brightness.dark),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),

      // Card Theme
      cardTheme: _buildCardTheme(Brightness.dark),

      // Dialog Theme
      dialogTheme: _buildDialogTheme(Brightness.dark),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(Brightness.dark),

      // Navigation Bar Theme
      navigationBarTheme: _buildNavigationBarTheme(Brightness.dark),

      // Floating Action Button Theme
      floatingActionButtonTheme: _buildFABTheme(Brightness.dark),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkForeground,
        size: AppConstants.iconSizeRegular,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: _buildListTileTheme(Brightness.dark),

      // Switch Theme
      switchTheme: _buildSwitchTheme(Brightness.dark),

      // Checkbox Theme
      checkboxTheme: _buildCheckboxTheme(Brightness.dark),

      // Radio Theme
      radioTheme: _buildRadioTheme(Brightness.dark),

      // Slider Theme
      sliderTheme: _buildSliderTheme(Brightness.dark),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkPrimary,
        linearTrackColor: AppColors.darkMuted,
        circularTrackColor: AppColors.darkMuted,
      ),

      // Tab Bar Theme
      tabBarTheme: _buildTabBarTheme(Brightness.dark),

      // Chip Theme
      chipTheme: _buildChipTheme(Brightness.dark),

      // Tooltip Theme
      tooltipTheme: _buildTooltipTheme(Brightness.dark),

      // Snack Bar Theme
      snackBarTheme: _buildSnackBarTheme(Brightness.dark),

      // Banner Theme
      bannerTheme: _buildBannerTheme(Brightness.dark),
    );
  }

  // ============ ShadCN UI Theme Extensions ============

  /// Get ShadCN UI theme data for light theme
  static ShadThemeData get lightShadTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadColorScheme.light(
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
        family: AppTextStyles._fontFamily,
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
      radius: AppConstants.defaultBorderRadius,
    );
  }

  /// Get ShadCN UI theme data for dark theme
  static ShadThemeData get darkShadTheme {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadColorScheme.dark(
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
        family: AppTextStyles._fontFamily,
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
      radius: AppConstants.defaultBorderRadius,
    );
  }

  // ============ Helper Theme Builders ============

  static TextTheme _buildTextTheme(Brightness brightness) {
    return TextTheme(
      displayLarge: AppTextStyles.withPrimaryColor(
          AppTextStyles.displayLarge, brightness),
      displayMedium: AppTextStyles.withPrimaryColor(
          AppTextStyles.displayMedium, brightness),
      displaySmall: AppTextStyles.withPrimaryColor(
          AppTextStyles.displaySmall, brightness),
      headlineLarge: AppTextStyles.withPrimaryColor(
          AppTextStyles.headlineLarge, brightness),
      headlineMedium: AppTextStyles.withPrimaryColor(
          AppTextStyles.headlineMedium, brightness),
      headlineSmall: AppTextStyles.withPrimaryColor(
          AppTextStyles.headlineSmall, brightness),
      titleLarge:
          AppTextStyles.withPrimaryColor(AppTextStyles.titleLarge, brightness),
      titleMedium:
          AppTextStyles.withPrimaryColor(AppTextStyles.titleMedium, brightness),
      titleSmall:
          AppTextStyles.withPrimaryColor(AppTextStyles.titleSmall, brightness),
      labelLarge:
          AppTextStyles.withPrimaryColor(AppTextStyles.labelLarge, brightness),
      labelMedium:
          AppTextStyles.withPrimaryColor(AppTextStyles.labelMedium, brightness),
      labelSmall:
          AppTextStyles.withPrimaryColor(AppTextStyles.labelSmall, brightness),
      bodyLarge:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodyLarge, brightness),
      bodyMedium:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodyMedium, brightness),
      bodySmall:
          AppTextStyles.withMutedColor(AppTextStyles.bodySmall, brightness),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
      Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary(brightness),
        foregroundColor: brightness == Brightness.light
            ? AppColors.lightPrimaryForeground
            : AppColors.darkPrimaryForeground,
        elevation: AppConstants.defaultElevation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary(brightness),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
      Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary(brightness),
        side: BorderSide(
          color: AppColors.border(brightness),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme(Brightness brightness) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary(brightness),
        foregroundColor: brightness == Brightness.light
            ? AppColors.lightPrimaryForeground
            : AppColors.darkPrimaryForeground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
      Brightness brightness) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: AppColors.border(brightness)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(color: AppColors.border(brightness)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.lightRing
              : AppColors.darkRing,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.lightDestructive
              : AppColors.darkDestructive,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.lightDestructive
              : AppColors.darkDestructive,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.surface(brightness),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      hintStyle:
          AppTextStyles.withMutedColor(AppTextStyles.bodyMedium, brightness),
      labelStyle:
          AppTextStyles.withMutedColor(AppTextStyles.labelMedium, brightness),
      errorStyle: AppTextStyles.withDestructiveColor(
          AppTextStyles.bodySmall, brightness),
    );
  }

  static CardTheme _buildCardTheme(Brightness brightness) {
    return CardTheme(
      color: AppColors.surface(brightness),
      shadowColor: AppColors.black20,
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        side: BorderSide(
          color: AppColors.border(brightness),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    );
  }

  static DialogTheme _buildDialogTheme(Brightness brightness) {
    return DialogTheme(
      backgroundColor: AppColors.surface(brightness),
      elevation: AppConstants.highElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      titleTextStyle: AppTextStyles.withPrimaryColor(
          AppTextStyles.headlineSmall, brightness),
      contentTextStyle:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodyMedium, brightness),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
      Brightness brightness) {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface(brightness),
      selectedItemColor: AppColors.primary(brightness),
      unselectedItemColor: AppColors.mutedForeground(brightness),
      type: BottomNavigationBarType.fixed,
      elevation: AppConstants.mediumElevation,
      selectedLabelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    );
  }

  static NavigationBarThemeData _buildNavigationBarTheme(
      Brightness brightness) {
    return NavigationBarThemeData(
      backgroundColor: AppColors.surface(brightness),
      elevation: AppConstants.defaultElevation,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.withPrimaryColor(
              AppTextStyles.labelMedium, brightness);
        }
        return AppTextStyles.withMutedColor(
            AppTextStyles.labelSmall, brightness);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: AppColors.primary(brightness),
            size: AppConstants.iconSizeRegular,
          );
        }
        return IconThemeData(
          color: AppColors.mutedForeground(brightness),
          size: AppConstants.iconSizeRegular,
        );
      }),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(Brightness brightness) {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary(brightness),
      foregroundColor: brightness == Brightness.light
          ? AppColors.lightPrimaryForeground
          : AppColors.darkPrimaryForeground,
      elevation: AppConstants.mediumElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
    );
  }

  static ListTileThemeData _buildListTileTheme(Brightness brightness) {
    return ListTileThemeData(
      tileColor: AppColors.surface(brightness),
      selectedTileColor: brightness == Brightness.light
          ? AppColors.lightSecondary
          : AppColors.darkSecondary,
      textColor: AppColors.primary(brightness),
      iconColor: AppColors.mutedForeground(brightness),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
    );
  }

  static SwitchThemeData _buildSwitchTheme(Brightness brightness) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary(brightness);
        }
        return AppColors.mutedForeground(brightness);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary(brightness).withOpacity(0.5);
        }
        return AppColors.border(brightness);
      }),
    );
  }

  static CheckboxThemeData _buildCheckboxTheme(Brightness brightness) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary(brightness);
        }
        return AppColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(
        brightness == Brightness.light
            ? AppColors.lightPrimaryForeground
            : AppColors.darkPrimaryForeground,
      ),
      side: BorderSide(color: AppColors.border(brightness)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
    );
  }

  static RadioThemeData _buildRadioTheme(Brightness brightness) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary(brightness);
        }
        return AppColors.border(brightness);
      }),
    );
  }

  static SliderThemeData _buildSliderTheme(Brightness brightness) {
    return SliderThemeData(
      activeTrackColor: AppColors.primary(brightness),
      inactiveTrackColor: AppColors.border(brightness),
      thumbColor: AppColors.primary(brightness),
      overlayColor: AppColors.primary(brightness).withOpacity(0.2),
      trackHeight: 4,
    );
  }

  static TabBarTheme _buildTabBarTheme(Brightness brightness) {
    return TabBarTheme(
      labelColor: AppColors.primary(brightness),
      unselectedLabelColor: AppColors.mutedForeground(brightness),
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: AppColors.primary(brightness),
          width: 2,
        ),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(Brightness brightness) {
    return ChipThemeData(
      backgroundColor: AppColors.surface(brightness),
      selectedColor: AppColors.primary(brightness),
      labelStyle: AppTextStyles.labelMedium,
      side: BorderSide(color: AppColors.border(brightness)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.circleBorderRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
    );
  }

  static TooltipThemeData _buildTooltipTheme(Brightness brightness) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: brightness == Brightness.light
            ? AppColors.lightMuted
            : AppColors.darkMuted,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodySmall, brightness),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(Brightness brightness) {
    return SnackBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? AppColors.lightMuted
          : AppColors.darkMuted,
      contentTextStyle:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodyMedium, brightness),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: AppConstants.mediumElevation,
    );
  }

  static MaterialBannerThemeData _buildBannerTheme(Brightness brightness) {
    return MaterialBannerThemeData(
      backgroundColor: brightness == Brightness.light
          ? AppColors.lightSecondary
          : AppColors.darkSecondary,
      contentTextStyle:
          AppTextStyles.withPrimaryColor(AppTextStyles.bodyMedium, brightness),
      elevation: AppConstants.defaultElevation,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
    );
  }
}
