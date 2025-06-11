// lib/core/services/injection_container.dart - FIXED - No Duplicates
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  try {
    $initGetIt(sl);
    debugPrint('✅ Injectable dependencies configured successfully');
  } catch (e) {
    debugPrint('❌ Injectable configuration failed: $e');
    rethrow;
  }
}

/// Initialize all dependencies for the application
Future<void> init() async {
  try {
    debugPrint('🔄 Starting dependency injection initialization...');

    // Step 1: Register ONLY non-injectable dependencies manually
    await _registerManualDependencies();
    debugPrint('✅ Manual dependencies registered');

    // Step 2: Initialize Hive storage
    await _initializeHiveBoxes();
    debugPrint('✅ Hive boxes initialized');

    // Step 3: Configure injectable dependencies (handles all @injectable/@module classes)
    await configureDependencies();
    debugPrint('✅ All dependencies initialized successfully');
  } catch (e) {
    debugPrint('❌ Dependency injection initialization failed: $e');
    // Don't rethrow - let the app continue with limited functionality
  }
}

/// Register ONLY dependencies that can't use @injectable (async initialization required)
Future<void> _registerManualDependencies() async {
  try {
    // SharedPreferences - Must be registered manually (async initialization)
    if (!sl.isRegistered<SharedPreferences>()) {
      final sharedPreferences = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
      debugPrint('✅ SharedPreferences registered');
    }

    // Speech to Text - Manual registration (plugin initialization)
    if (!sl.isRegistered<SpeechToText>()) {
      final speechToText = SpeechToText();
      sl.registerLazySingleton<SpeechToText>(() => speechToText);
      debugPrint('✅ SpeechToText registered');
    }

    // Text to Speech - Manual registration (plugin initialization)
    if (!sl.isRegistered<FlutterTts>()) {
      final flutterTts = FlutterTts();
      sl.registerLazySingleton<FlutterTts>(() => flutterTts);
      debugPrint('✅ FlutterTts registered');
    }

    // Camera - Manual registration with error handling (async + can fail)
    if (!sl.isRegistered<List<CameraDescription>>()) {
      try {
        final cameras =
            await availableCameras().timeout(const Duration(seconds: 5));
        sl.registerLazySingleton<List<CameraDescription>>(() => cameras);
        debugPrint('✅ Cameras registered (${cameras.length} cameras found)');
      } catch (e) {
        debugPrint('⚠️ Camera initialization failed: $e');
        sl.registerLazySingleton<List<CameraDescription>>(() => []);
      }
    }
  } catch (e) {
    debugPrint('❌ Manual dependencies registration failed: $e');
    rethrow;
  }
}

/// Initialize Hive storage boxes - Register as named instances for injectable
Future<void> _initializeHiveBoxes() async {
  try {
    // Translations Box
    if (!sl.isRegistered<Box>(instanceName: 'translationsBox')) {
      final translationsBox = await Hive.openBox('translations_history')
          .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => translationsBox,
        instanceName: 'translationsBox',
      );
      debugPrint('✅ Translations box registered');
    }

    // Languages Box
    if (!sl.isRegistered<Box>(instanceName: 'languagesBox')) {
      final languagesBox =
          await Hive.openBox('languages').timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => languagesBox,
        instanceName: 'languagesBox',
      );
      debugPrint('✅ Languages box registered');
    }

    // Settings Box
    if (!sl.isRegistered<Box>(instanceName: 'settingsBox')) {
      final settingsBox =
          await Hive.openBox('settings').timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => settingsBox,
        instanceName: 'settingsBox',
      );
      debugPrint('✅ Settings box registered');
    }
  } catch (e) {
    debugPrint('❌ Hive boxes initialization failed: $e');
    rethrow;
  }
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  try {
    await sl.reset();
    debugPrint('✅ Dependencies reset successfully');
  } catch (e) {
    debugPrint('❌ Dependencies reset failed: $e');
  }
}

/// Check if a dependency is registered
bool isRegistered<T extends Object>({String? instanceName}) {
  return sl.isRegistered<T>(instanceName: instanceName);
}

/// Get dependency instance with error handling
T get<T extends Object>({String? instanceName}) {
  try {
    return sl.get<T>(instanceName: instanceName);
  } catch (e) {
    debugPrint('❌ Failed to get dependency ${T.toString()}: $e');
    rethrow;
  }
}
