// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translate_app/config/routes/app_router.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_bloc.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_event.dart';

import 'core/constants/app_constants.dart';
import 'core/services/injection_container.dart';
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

  // Initialize dependency injection (uncomment when ready)
  // await initializeDependencies();

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
    // For now, using default settings. Uncomment MultiBlocProvider when BLoCs are ready
    const settings = AppSettings(); // Default settings

    // Uncomment this when you have BLoCs set up:

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

          return MaterialApp.router(
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

/// Global error handler
void _setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    // Log to crashlytics in production
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);

    // Show custom error widget in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    // Log to crashlytics in production
    // FirebaseCrashlytics.instance.recordError(error, stack);

    if (kDebugMode) {
      debugPrint('Platform Error: $error');
      debugPrint('Stack Trace: $stack');
    }

    return true;
  };
}

/// Global app configuration
class AppConfig {
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;

  // Feature flags
  static const bool enableConversationMode = true;
  static const bool enableOfflineTranslation = true;
  static const bool enableVoiceInput = true;
  static const bool enableCameraTranslation = true;

  // API Configuration
  static const String apiBaseUrl = 'https://api.translate.app';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultBorderRadius = 12.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
}

/// Development utilities
class DevUtils {
  /// Initialize development tools
  static void initDevTools() {
    if (kDebugMode) {
      // Setup development shortcuts
      // Setup debug overlays
      // Setup performance monitoring
      debugPrint('🛠️ Development tools initialized');
    }
  }

  /// Log app startup information
  static void logStartupInfo() {
    if (kDebugMode) {
      debugPrint('🚀 App starting...');
      debugPrint('📱 Platform: ${Platform.operatingSystem}');
      debugPrint('🌍 Locale: ${PlatformDispatcher.instance.locale}');
      debugPrint(
          '🎨 Brightness: ${PlatformDispatcher.instance.platformBrightness}');
    }
  }
}
