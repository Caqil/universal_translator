// lib/main.dart - VERIFIED SETUP FOR HIVE
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:translate_app/config/routes/app_router.dart';
import 'package:translate_app/features/history/presentation/bloc/history_bloc.dart';
import 'package:translate_app/features/speech/presentation/bloc/speech_bloc.dart';
import 'package:translate_app/features/speech/presentation/bloc/speech_event.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_bloc.dart';
import 'package:translate_app/features/translation/presentation/bloc/translation_event.dart';

import 'core/app_theme_adapter.dart';
import 'core/constants/app_constants.dart';
import 'core/data_usage_mode_adapter.dart';
import 'core/services/injection_container.dart';
import 'core/utils/cache_repair_utility.dart';
import 'features/conversation/presentation/bloc/conversation_bloc.dart';
import 'features/conversation/presentation/bloc/conversation_event.dart';
import 'features/history/data/models/history_item_model.dart';
import 'features/history/presentation/bloc/history_event.dart';
import 'features/settings/data/models/app_settings_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize system UI
  await _initializeSystemUI();

  // **CRITICAL: Register Hive adapters BEFORE initializing dependency injection**
  await _registerHiveAdapters();

  // Initialize Hive
  await _initializeHive();

  // Initialize cache repair utility
  await CacheRepairUtility.repairAllCaches();

  // **IMPORTANT: Initialize dependency injection AFTER Hive adapters are registered**
  try {
    await init(); // This calls your injection_container.dart init()
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

/// **CRITICAL: Register all Hive adapters BEFORE opening any boxes**
Future<void> _registerHiveAdapters() async {
  try {
    debugPrint('🔄 Registering Hive adapters...');

    // **Check if adapters are already registered to avoid duplicate registration**
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppThemeAdapter());
      debugPrint('✅ AppThemeAdapter registered (typeId: 1)');
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DataUsageModeAdapter());
      debugPrint('✅ DataUsageModeAdapter registered (typeId: 2)');
    }

    // **CRITICAL: HistoryItemModel adapter MUST be registered before opening historyBox**
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HistoryItemModelAdapter());
      debugPrint('✅ HistoryItemModelAdapter registered (typeId: 3)');
    }

    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SettingsModelAdapter());
      debugPrint('✅ SettingsModelAdapter registered (typeId: 5)');
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ConversationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(MessageTypeAdapterAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(MessageSenderAdapterAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    debugPrint('✅ All Hive adapters registered successfully');
  } catch (e) {
    debugPrint('❌ Failed to register Hive adapters: $e');
    rethrow; // This is critical - app cannot continue without adapters
  }
}

/// Initialize Hive database
Future<void> _initializeHive() async {
  try {
    debugPrint('🔄 Initializing Hive...');
    await Hive.initFlutter();
    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Hive: $e');
    rethrow;
  }
}

/// Initialize system UI configuration
Future<void> _initializeSystemUI() async {
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for Android
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    debugPrint('✅ System UI initialized');
  } catch (e) {
    debugPrint('❌ Failed to initialize system UI: $e');
  }
}

class TranslateApp extends StatelessWidget {
  const TranslateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ShadColorScheme.fromName('violet');
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryBloc>(
          create: (context) => sl<HistoryBloc>()..add(const LoadHistoryEvent()),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) =>
              sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<TranslationBloc>(
          create: (context) =>
              sl<TranslationBloc>()..add(const LoadSupportedLanguagesEvent()),
        ),
        BlocProvider<SpeechBloc>(
          create: (context) =>
              sl<SpeechBloc>()..add(const InitializeSpeechEvent()),
        ),
        BlocProvider<ConversationBloc>(
          create: (context) =>
              sl<ConversationBloc>()..add(const LoadConversationsEvent()),
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
            locale: _getLocale(settings.language),

            // Theme Configuration - FIXED
            themeMode: _getThemeMode(settings.theme),
            theme: ShadThemeData(
                brightness: Brightness.light, colorScheme: colorScheme),
            darkTheme: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: colorScheme,
            ),

            // Router Configuration
            routerConfig: appRouter,

            // App Metadata
            builder: (context, child) {
              return MediaQuery(
                // Apply font size settings - FIXED
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    settings.fontSizeMultiplier.clamp(0.8, 2.0),
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

  /// Convert AppTheme enum to ThemeMode - FIXED MISSING FUNCTION
  ThemeMode _getThemeMode(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  /// Get locale from language code - ADDED NEW FUNCTION
  Locale _getLocale(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'es':
        return const Locale('es', 'ES');
      case 'fr':
        return const Locale('fr', 'FR');
      case 'de':
        return const Locale('de', 'DE');
      case 'zh':
        return const Locale('zh', 'CN');
      case 'ja':
        return const Locale('ja', 'JP');
      case 'ko':
        return const Locale('ko', 'KR');
      case 'ar':
        return const Locale('ar', 'SA');
      case 'pt':
        return const Locale('pt', 'BR');
      case 'ru':
        return const Locale('ru', 'RU');
      case 'it':
        return const Locale('it', 'IT');
      case 'nl':
        return const Locale('nl', 'NL');
      case 'tr':
        return const Locale('tr', 'TR');
      case 'hi':
        return const Locale('hi', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }
}
