import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../features/conversation/data/models/conversation_session_model.dart';
import '../constants/app_constants.dart';
import '../../features/history/data/models/history_item_model.dart';
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
    debugPrint('✅ Injectable dependencies configured');

    debugPrint('✅ Camera dependencies checked/registered');

    debugPrint('✅ All dependencies initialized successfully');
  } catch (e) {
    debugPrint('❌ Dependency injection initialization failed: $e');
    // Don't rethrow - let the app continue with limited functionality
  }
}

Future<void> _registerCameraDependencies() async {
  try {
    // Image Picker - Manual registration (plugin initialization)
    if (!sl.isRegistered<ImagePicker>()) {
      sl.registerLazySingleton<ImagePicker>(() => ImagePicker());
      debugPrint('✅ ImagePicker registered');
    }

    // Text Recognizer - Manual registration (ML Kit initialization)
    if (!sl.isRegistered<TextRecognizer>()) {
      sl.registerLazySingleton<TextRecognizer>(() => TextRecognizer());
      debugPrint('✅ TextRecognizer registered');
    }

    debugPrint('✅ Camera translation dependencies registered');
  } catch (e) {
    debugPrint('❌ Camera translation dependencies registration failed: $e');
    // Don't rethrow - camera features will just be disabled
  }
}

/// Register ONLY dependencies that can't use @injectable (async initialization required)
Future<void> _registerManualDependencies() async {
  try {
    // Uuid - Must be registered manually (needed by ConversationRepositoryImpl)
    if (!sl.isRegistered<Uuid>()) {
      sl.registerLazySingleton<Uuid>(() => const Uuid());
      debugPrint('✅ Uuid registered');
    }

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
    await _registerCameraDependencies();
  } catch (e) {
    debugPrint('❌ Manual dependencies registration failed: $e');
    rethrow;
  }
}

/// Initialize Hive storage boxes - Register as named instances for injectable
/// **FIXED: Proper type registration for historyBox**
Future<void> _initializeHiveBoxes() async {
  try {
    // Translations Box
    if (!sl.isRegistered<Box>(instanceName: 'translationsBox')) {
      final translationsBox =
          await Hive.openBox(AppConstants.translationsBoxName)
              .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => translationsBox,
        instanceName: 'translationsBox',
      );
      debugPrint('✅ Translations box registered');
    }

    // Languages Box
    if (!sl.isRegistered<Box>(instanceName: 'languagesBox')) {
      final languagesBox = await Hive.openBox(AppConstants.languagesBoxName)
          .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => languagesBox,
        instanceName: 'languagesBox',
      );
      debugPrint('✅ Languages box registered');
    }

    // Settings Box
    if (!sl.isRegistered<Box>(instanceName: 'settingsBox')) {
      final settingsBox = await Hive.openBox(AppConstants.settingsBoxName)
          .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box>(
        () => settingsBox,
        instanceName: 'settingsBox',
      );
      debugPrint('✅ Settings box registered');
    }
    // History Box (Typed)
    if (!sl.isRegistered<Box<HistoryItemModel>>(instanceName: 'historyBox')) {
      final historyBox =
          await Hive.openBox<HistoryItemModel>(AppConstants.historyBoxName)
              .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box<HistoryItemModel>>(
        () => historyBox,
        instanceName: 'historyBox',
      );
      debugPrint('✅ History box registered');
    }
    if (!sl.isRegistered<Box<ConversationSessionModel>>(
        instanceName: 'conversationsBox')) {
      final conversationsBox =
          await Hive.openBox<ConversationSessionModel>('conversations')
              .timeout(const Duration(seconds: 10));
      sl.registerLazySingleton<Box<ConversationSessionModel>>(
        () => conversationsBox,
        instanceName: 'conversationsBox',
      );
      debugPrint('✅ Conversations box registered');
    }
    debugPrint('✅ All Hive boxes initialized successfully');
  } catch (e) {
    debugPrint('❌ Hive boxes initialization failed: $e');
    rethrow;
  }
}
