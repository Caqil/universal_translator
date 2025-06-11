// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:translate_app/features/settings/data/models/settings_model.dart';

import 'core/constants/app_constants.dart';
import 'core/services/dependency_provider.dart';
import 'features/settings/data/models/app_settings_model.dart';

/// Import for development utilities
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;

import 'config/routes/app_router.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize system UI
  await _initializeSystemUI();

  // Initialize Hive
  await _initializeHive();

  // Initialize dependencies
  final dependencyProvider = await DependencyProvider.initialize();

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
      child: TranslateApp(dependencyProvider: dependencyProvider),
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
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Initialize Hive local storage
Future<void> _initializeHive() async {
  try {
    // Initialize Hive
    await Hive.initFlutter();

    debugPrint('✅ Hive initialized successfully');
  } catch (e) {
    debugPrint('❌ Hive initialization failed: $e');
    rethrow;
  }
}

/// Main app widget
class TranslateApp extends StatelessWidget {
  final DependencyProvider dependencyProvider;

  const TranslateApp({
    super.key,
    required this.dependencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: dependencyProvider.createBlocProviders(),
      child: MaterialApp.router(
        title: 'Translate App',
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // Theme
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
        ),

        // Router
        routerConfig: appRouter,
      ),
    );
  }
}
