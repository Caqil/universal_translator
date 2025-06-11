// lib/core/services/injection_container.dart - UPDATED WITH CAMERA DEPENDENCIES
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

// Camera feature imports
import '../../features/camera/data/datasources/ocr_datasource.dart';
import '../../features/camera/data/datasources/ocr_datasource_impl.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/usecases/initialize_camera.dart';
import '../../features/camera/domain/usecases/capture_image.dart';
import '../../features/camera/domain/usecases/process_ocr.dart';
import '../../features/camera/domain/usecases/get_available_cameras.dart';
import '../../features/camera/domain/usecases/save_image.dart';
import '../../features/camera/domain/usecases/check_camera_permission.dart';
import '../../features/camera/domain/usecases/request_camera_permission.dart';
import '../../features/camera/presentation/bloc/camera_bloc.dart';

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

    // Step 4: Register camera dependencies safely (only if not already registered by injectable)
    await _registerCameraDependencies();
    debugPrint('✅ Camera dependencies checked/registered');

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

/// Register camera-specific dependencies (safe registration with duplicate check)
Future<void> _registerCameraDependencies() async {
  try {
    debugPrint('🔄 Checking camera dependencies...');

    // Check if camera dependencies are already registered by injectable
    final cameraAlreadyConfigured = sl.isRegistered<CameraRepository>() ||
        sl.isRegistered<CheckCameraPermission>() ||
        sl.isRegistered<CameraBloc>();

    if (cameraAlreadyConfigured) {
      debugPrint(
          'ℹ️ Camera dependencies already configured by injectable, skipping manual registration');
      return;
    }

    // Manual registration only if not already configured
    debugPrint('🔄 Registering camera dependencies manually...');

    // Data Sources
    _safeRegisterLazySingleton<OcrDataSource>(
      () => OcrDataSourceImpl(),
      'OcrDataSource',
    );

    // Repositories
    _safeRegisterLazySingleton<CameraRepository>(
      () => CameraRepositoryImpl(ocrDataSource: sl<OcrDataSource>()),
      'CameraRepository',
    );

    // Use Cases
    _safeRegisterLazySingleton<InitializeCamera>(
      () => InitializeCamera(sl<CameraRepository>()),
      'InitializeCamera',
    );

    _safeRegisterLazySingleton<CaptureImage>(
      () => CaptureImage(sl<CameraRepository>()),
      'CaptureImage',
    );

    _safeRegisterLazySingleton<ProcessOcr>(
      () => ProcessOcr(sl<CameraRepository>()),
      'ProcessOcr',
    );

    _safeRegisterLazySingleton<GetAvailableCameras>(
      () => GetAvailableCameras(sl<CameraRepository>()),
      'GetAvailableCameras',
    );

    _safeRegisterLazySingleton<SaveImage>(
      () => SaveImage(sl<CameraRepository>()),
      'SaveImage',
    );

    _safeRegisterLazySingleton<CheckCameraPermission>(
      () => CheckCameraPermission(sl<CameraRepository>()),
      'CheckCameraPermission',
    );

    _safeRegisterLazySingleton<RequestCameraPermission>(
      () => RequestCameraPermission(sl<CameraRepository>()),
      'RequestCameraPermission',
    );

    // BLoC - Factory registration
    _safeRegisterFactory<CameraBloc>(
      () => CameraBloc(cameraRepository: sl<CameraRepository>()),
      'CameraBloc',
    );

    debugPrint('✅ Camera dependencies registered manually');
  } catch (e) {
    debugPrint('❌ Camera dependencies registration failed: $e');
    // Don't rethrow - let the app continue
  }
}

/// Safe registration helper for lazy singletons
void _safeRegisterLazySingleton<T extends Object>(
  T Function() factoryFunc,
  String name,
) {
  try {
    if (!sl.isRegistered<T>()) {
      sl.registerLazySingleton<T>(factoryFunc);
      debugPrint('  ✅ $name registered');
    } else {
      debugPrint('  ℹ️ $name already registered, skipping');
    }
  } catch (e) {
    debugPrint('  ⚠️ Failed to register $name: $e');
  }
}

/// Safe registration helper for factories
void _safeRegisterFactory<T extends Object>(
  T Function() factoryFunc,
  String name,
) {
  try {
    if (!sl.isRegistered<T>()) {
      sl.registerFactory<T>(factoryFunc);
      debugPrint('  ✅ $name registered');
    } else {
      debugPrint('  ℹ️ $name already registered, skipping');
    }
  } catch (e) {
    debugPrint('  ⚠️ Failed to register $name: $e');
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
