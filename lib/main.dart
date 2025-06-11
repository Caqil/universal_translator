// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:translate_app/config/routes/app_router.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_bloc.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_event.dart';

import 'core/constants/app_constants.dart';
import 'core/services/injection_container.dart';
import 'core/utils/cache_repair_utility.dart';
import 'features/settings/data/models/app_settings_model.dart';

/// Import for development utilities
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;

import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize system UI
  await _initializeSystemUI();

  // Initialize Hive
  await _initializeHive();
  await CacheRepairUtility.repairAllCaches();
  try {
    await init();
    debugPrint('✅ App initialization completed successfully');
  } catch (e) {
    debugPrint('❌ App initialization failed: $e');
    // Continue with limited functionality
  }

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Run the app
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
        Locale('zh', 'CN'),
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
        Locale('ar', 'SA'),
        Locale('pt', 'BR'),
        Locale('ru', 'RU'),
        Locale('it', 'IT'),
        Locale('nl', 'NL'),
        Locale('tr', 'TR'),
        Locale('hi', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      useOnlyLangCode: true,
      child: const TranslateApp(),
    ),
  );
}

/// Initialize system UI configuration
Future<void> _initializeSystemUI() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register adapters if needed
  // Note: Add your Hive type adapters here when you create them
  // Hive.registerAdapter(TranslationModelAdapter());
  // Hive.registerAdapter(SettingsModelAdapter());
}

/// Main application widget
class TranslateApp extends StatelessWidget {
  const TranslateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Settings BLoC - Global
        BlocProvider<SettingsBloc>(
          create: (context) =>
              sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<TranslationBloc>(
          create: (context) =>
              sl<TranslationBloc>()..add(const LoadSupportedLanguagesEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Get settings or use defaults
          final settings = settingsState is SettingsLoaded
              ? settingsState.settings
              : const AppSettings(); // Default settings

          return ShadApp.router(
            // App Configuration
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Localization
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            themeMode: _getThemeMode(settings.theme),

            // Router Configuration
            routerConfig: appRouter,

            // App Metadata
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling doesn't break layout
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    (settings.fontSizeMultiplier).clamp(0.8, 1.5),
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  /// Convert AppTheme enum to ThemeMode
  ThemeMode? _getThemeMode(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}

/// Custom error widget for better error display in debug mode
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorDetails.exception.toString(),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (kDebugMode) ...[
                const Text(
                  'Stack Trace (Debug Mode):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      errorDetails.stack.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
