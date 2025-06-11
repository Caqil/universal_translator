// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/app_settings_model.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector.dart';

/// Main settings page with comprehensive app settings
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Load settings when page opens
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
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
    final sonner = ShadSonner.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'settings.settings'.tr(),
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primary(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showResetDialog,
            icon: Icon(
              Iconsax.refresh,
              color: AppColors.mutedForeground(brightness),
            ),
            tooltip: 'settings.reset_settings'.tr(),
          ),
        ],
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsOperationCompleted) {
            sonner.show(
              ShadToast.raw(
                variant: ShadToastVariant.primary,
                description: Text(state.message),
              ),
            );
          } else if (state is SettingsError) {
            sonner.show(
              ShadToast.destructive(
                description: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SettingsError) {
            return _buildErrorState(state, brightness);
          }

          final settings = state is SettingsLoaded
              ? state.settings
              : (state is SettingsOperationCompleted ? state.settings : null);

          if (settings == null) {
            return _buildEmptyState(brightness);
          }

          return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: _buildSettingsContent(settings, brightness),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(AppSettings settings, Brightness brightness) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Section
          _buildSectionHeader('appearance'.tr(), Iconsax.brush_2, brightness),
          ThemeSelector(
            selectedTheme: settings.theme,
            onThemeSelected: (theme) {
              context.read<SettingsBloc>().add(UpdateThemeEvent(theme));
            },
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Language & Translation Section
          _buildSectionHeader(
              'language_translation'.tr(), Iconsax.translate, brightness),
          SettingsTile(
            title: 'language'.tr(),
            description: 'interface_language'.tr(),
            leadingIcon: Iconsax.global,
            type: SettingsTileType.selection,
            value: settings.language,
            options: _getLanguageOptions(),
            onChanged: (value) {
              context.read<SettingsBloc>().add(UpdateLanguageEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.auto_translate'.tr(),
            description: 'settings.auto_translate_description'.tr(),
            leadingIcon: Iconsax.translate,
            type: SettingsTileType.toggle,
            value: settings.autoTranslate,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleAutoTranslateEvent(value));
            },
          ),
          if (settings.autoTranslate) ...[
            SettingsTile(
              title: 'settings.auto_translate_delay'.tr(),
              description: 'settings.auto_translate_delay_description'.tr(),
              leadingIcon: Iconsax.timer_1,
              type: SettingsTileType.slider,
              value: settings.autoTranslateDelay.toDouble(),
              minValue: 500,
              maxValue: 3000,
              divisions: 5,
              sliderLabel: (value) => '${value.round()}ms',
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                      UpdateAutoTranslateDelayEvent(value.round()),
                    );
              },
            ),
          ],
          SettingsTile(
            title: 'settings.auto_detect_language'.tr(),
            description: 'settings.auto_detect_language_description'.tr(),
            leadingIcon: Iconsax.scan,
            type: SettingsTileType.toggle,
            value: settings.autoDetectLanguage,
            onChanged: (value) {
              context
                  .read<SettingsBloc>()
                  .add(ToggleAutoDetectLanguageEvent(value));
            },
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Speech & Audio Section
          _buildSectionHeader(
              'settings.speech_audio'.tr(), Iconsax.volume_high, brightness),
          SettingsTile(
            title: 'settings.speech_feedback'.tr(),
            description: 'settings.speech_feedback_description'.tr(),
            leadingIcon: Iconsax.volume_high,
            type: SettingsTileType.toggle,
            value: settings.enableSpeechFeedback,
            onChanged: (value) {
              context
                  .read<SettingsBloc>()
                  .add(ToggleSpeechFeedbackEvent(value));
            },
          ),
          if (settings.enableSpeechFeedback) ...[
            SettingsTile(
              title: 'settings.speech_rate'.tr(),
              description: 'settings.speech_rate_description'.tr(),
              leadingIcon: Iconsax.forward,
              type: SettingsTileType.slider,
              value: settings.speechRate,
              minValue: 0.5,
              maxValue: 2.0,
              divisions: 6,
              sliderLabel: (value) => '${value.toStringAsFixed(1)}x',
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateSpeechRateEvent(value));
              },
            ),
            SettingsTile(
              title: 'settings.speech_pitch'.tr(),
              description: 'settings.speech_pitch_description'.tr(),
              leadingIcon: Iconsax.music,
              type: SettingsTileType.slider,
              value: settings.speechPitch,
              minValue: 0.5,
              maxValue: 2.0,
              divisions: 6,
              sliderLabel: (value) => '${value.toStringAsFixed(1)}x',
              onChanged: (value) {
                context.read<SettingsBloc>().add(UpdateSpeechPitchEvent(value));
              },
            ),
          ],
          SettingsTile(
            title: 'settings.sound_effects'.tr(),
            description: 'settings.sound_effects_description'.tr(),
            leadingIcon: Iconsax.music_play,
            type: SettingsTileType.toggle,
            value: settings.enableSoundEffects,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleSoundEffectsEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.haptic_feedback'.tr(),
            description: 'settings.haptic_feedback_description'.tr(),
            leadingIcon: Iconsax.mobile,
            type: SettingsTileType.toggle,
            value: settings.enableHapticFeedback,
            onChanged: (value) {
              context
                  .read<SettingsBloc>()
                  .add(ToggleHapticFeedbackEvent(value));
            },
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Accessibility Section
          _buildSectionHeader(
              'settings.accessibility'.tr(), Iconsax.eye, brightness),
          SettingsTile(
            title: 'settings.font_size'.tr(),
            description: 'settings.font_size_description'.tr(),
            leadingIcon: Iconsax.text,
            type: SettingsTileType.slider,
            value: settings.fontSizeMultiplier,
            minValue: 0.8,
            maxValue: 1.5,
            divisions: 7,
            sliderLabel: (value) => '${(value * 100).round()}%',
            onChanged: (value) {
              context.read<SettingsBloc>().add(UpdateFontSizeEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.high_contrast'.tr(),
            description: 'settings.high_contrast_description'.tr(),
            leadingIcon: Iconsax.colors_square,
            type: SettingsTileType.toggle,
            value: settings.enableHighContrast,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleHighContrastEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.reduce_motion'.tr(),
            description: 'settings.reduce_motion_description'.tr(),
            leadingIcon: Iconsax.pause,
            type: SettingsTileType.toggle,
            value: settings.enableReduceMotion,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleReduceMotionEvent(value));
            },
          ),
          const SizedBox(height: AppConstants.largePadding),

          // Data & Privacy Section
          _buildSectionHeader(
              'settings.data_privacy'.tr(), Iconsax.shield_tick, brightness),
          SettingsTile(
            title: 'settings.data_usage'.tr(),
            description: 'settings.data_usage_description'.tr(),
            leadingIcon: Iconsax.data,
            type: SettingsTileType.selection,
            value: settings.dataUsageMode,
            options: _getDataUsageOptions(),
            onChanged: (value) {
              context.read<SettingsBloc>().add(UpdateDataUsageModeEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.offline_mode'.tr(),
            description: 'settings.offline_mode_description'.tr(),
            leadingIcon: Iconsax.wifi_square,
            type: SettingsTileType.toggle,
            value: settings.enableOfflineMode,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleOfflineModeEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.analytics'.tr(),
            description: 'settings.analytics_description'.tr(),
            leadingIcon: Iconsax.chart,
            type: SettingsTileType.toggle,
            value: settings.analyticsConsent,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleAnalyticsEvent(value));
            },
          ),
          SettingsTile(
            title: 'settings.crash_reporting'.tr(),
            description: 'settings.crash_reporting_description'.tr(),
            leadingIcon: Iconsax.danger,
            type: SettingsTileType.toggle,
            value: settings.crashReportingConsent,
            onChanged: (value) {
              context
                  .read<SettingsBloc>()
                  .add(ToggleCrashReportingEvent(value));
            },
          ),
          const SizedBox(height: AppConstants.largePadding),

          // App Info Section
          _buildSectionHeader(
              'settings.app_info'.tr(), Iconsax.info_circle, brightness),
          SettingsTile(
            title: 'settings.about_app'.tr(),
            description: 'settings.app_version_info'.tr(),
            leadingIcon: Iconsax.mobile,
            type: SettingsTileType.navigation,
            onTap: _showAboutDialog,
          ),
          SettingsTile(
            title: 'settings.export_settings'.tr(),
            description: 'settings.export_settings_description'.tr(),
            leadingIcon: Iconsax.export,
            type: SettingsTileType.action,
            onTap: _exportSettings,
          ),
          SettingsTile(
            title: 'settings.import_settings'.tr(),
            description: 'settings.import_settings_description'.tr(),
            leadingIcon: Iconsax.import,
            type: SettingsTileType.action,
            onTap: _importSettings,
          ),
          const SizedBox(height: AppConstants.largePadding),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeRegular,
            color: AppColors.surface(brightness),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SettingsError state, Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: AppConstants.iconSizeExtraLarge,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'settings.settings_error'.tr(),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            CustomButton(
              text: 'retry'.tr(),
              onPressed: () {
                context.read<SettingsBloc>().add(const LoadSettingsEvent());
                debugPrint(
                  state.message,
                );
              },
              variant: ButtonVariant.primary,
              icon: Iconsax.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.setting,
              size: AppConstants.iconSizeExtraLarge,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'settings.no_settings'.tr(),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<SettingsOption> _getLanguageOptions() {
    return [
      const SettingsOption(
        label: 'English',
        value: 'en',
        icon: Iconsax.flag,
      ),
      const SettingsOption(
        label: 'Español',
        value: 'es',
        icon: Iconsax.flag,
      ),
      const SettingsOption(
        label: 'Français',
        value: 'fr',
        icon: Iconsax.flag,
      ),
      const SettingsOption(
        label: 'Deutsch',
        value: 'de',
        icon: Iconsax.flag,
      ),
      const SettingsOption(
        label: '中文',
        value: 'zh',
        icon: Iconsax.flag,
      ),
      const SettingsOption(
        label: '日本語',
        value: 'ja',
        icon: Iconsax.flag,
      ),
    ];
  }

  List<SettingsOption> _getDataUsageOptions() {
    return [
      SettingsOption(
        label: DataUsageMode.low.displayName,
        value: DataUsageMode.low,
        description: DataUsageMode.low.description,
        icon: Iconsax.data,
      ),
      SettingsOption(
        label: DataUsageMode.standard.displayName,
        value: DataUsageMode.standard,
        description: DataUsageMode.standard.description,
        icon: Iconsax.data,
      ),
      SettingsOption(
        label: DataUsageMode.unlimited.displayName,
        value: DataUsageMode.unlimited,
        description: DataUsageMode.unlimited.description,
        icon: Iconsax.data,
      ),
    ];
  }

  void _showResetDialog() {
    final brightness = context.brightness;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(brightness),
        title: Text(
          'reset_settings'.tr(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary(brightness),
          ),
        ),
        content: Text(
          'reset_settings_confirmation'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedForeground(brightness),
          ),
        ),
        actions: [
          CustomButton(
            text: 'cancel'.tr(),
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
          ),
          CustomButton(
            text: 'reset'.tr(),
            onPressed: () {
              context.read<SettingsBloc>().add(const ResetSettingsEvent());
              Navigator.of(context).pop();
            },
            variant: ButtonVariant.destructive,
            size: ButtonSize.small,
            icon: Iconsax.refresh,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final brightness = context.brightness;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(brightness),
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary(brightness),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'version'.tr() + ': ${AppConstants.appVersion}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'build'.tr() + ': ${AppConstants.appBuildNumber}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'close'.tr(),
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _exportSettings() {
    // TODO: Implement settings export
    context.showInfo('export_settings_coming_soon'.tr());
  }

  void _importSettings() {
    // TODO: Implement settings import
    context.showInfo('import_settings_coming_soon'.tr());
  }
}
