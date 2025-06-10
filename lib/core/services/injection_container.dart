// lib/core/services/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';

import 'injection_container.config.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../constants/app_constants.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName:
      r'$initGetIt', // Ensure this matches the generated function name
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  $initGetIt(sl); // Call the generated function
}

/// Initialize all dependencies for the application
Future<void> init() async {
// External dependencies
  await _initExternalDependencies();

  // Core dependencies
  await _initCoreDependencies();

  // Feature dependencies
  await _initFeatureDependencies();
}

/// Initialize external dependencies (packages, plugins)
Future<void> _initExternalDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Internet Connection Checker
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(), // Use createInstance
  );

  // Hive Boxes
  await _initHiveBoxes();

  // Speech to Text
  sl.registerLazySingleton<SpeechToText>(() => SpeechToText());

  // Text to Speech
  sl.registerLazySingleton<FlutterTts>(() => FlutterTts());

  // Camera
  final cameras = await availableCameras();
  sl.registerLazySingleton<List<CameraDescription>>(() => cameras);
}

/// Initialize Hive storage boxes
Future<void> _initHiveBoxes() async {
  // History Box
  final historyBox = await Hive.openBox(AppConstants.historyBoxName);
  sl.registerLazySingleton<Box>(() => historyBox, instanceName: 'historyBox');

  // Favorites Box
  final favoritesBox = await Hive.openBox(AppConstants.favoritesBoxName);
  sl.registerLazySingleton<Box>(() => favoritesBox,
      instanceName: 'favoritesBox');

  // Settings Box
  final settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  sl.registerLazySingleton<Box>(() => settingsBox, instanceName: 'settingsBox');

  // Languages Box
  final languagesBox = await Hive.openBox(AppConstants.languagesBoxName);
  sl.registerLazySingleton<Box>(() => languagesBox,
      instanceName: 'languagesBox');

  // Conversations Box
  final conversationsBox =
      await Hive.openBox(AppConstants.conversationsBoxName);
  sl.registerLazySingleton<Box>(() => conversationsBox,
      instanceName: 'conversationsBox');
}

/// Initialize core dependencies
Future<void> _initCoreDependencies() async {
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl(), sl()),
  );

  // Dio Client
  sl.registerLazySingleton<DioClient>(() => DioClient(sl()));
}

/// Initialize feature-specific dependencies
Future<void> _initFeatureDependencies() async {
  // Translation Feature
  await _initTranslationDependencies();

  // Speech Feature
  await _initSpeechDependencies();

  // Camera Feature
  await _initCameraDependencies();

  // History Feature
  await _initHistoryDependencies();

  // Favorites Feature
  await _initFavoritesDependencies();

  // Settings Feature
  await _initSettingsDependencies();

  // Conversation Feature
  await _initConversationDependencies();
}

/// Translation feature dependencies
Future<void> _initTranslationDependencies() async {
  // Data sources will be registered via @injectable annotations
  // Repositories will be registered via @injectable annotations
  // Use cases will be registered via @injectable annotations
  // BLoCs will be registered via @injectable annotations
}

/// Speech feature dependencies
Future<void> _initSpeechDependencies() async {
  // Speech-specific dependencies will be registered via @injectable annotations
}

/// Camera feature dependencies
Future<void> _initCameraDependencies() async {
  // Camera-specific dependencies will be registered via @injectable annotations
}

/// History feature dependencies
Future<void> _initHistoryDependencies() async {
  // History-specific dependencies will be registered via @injectable annotations
}

/// Favorites feature dependencies
Future<void> _initFavoritesDependencies() async {
  // Favorites-specific dependencies will be registered via @injectable annotations
}

/// Settings feature dependencies
Future<void> _initSettingsDependencies() async {
  // Settings-specific dependencies will be registered via @injectable annotations
}

/// Conversation feature dependencies
Future<void> _initConversationDependencies() async {
  // Conversation-specific dependencies will be registered via @injectable annotations
}

/// Reset all dependencies (useful for testing)
Future<void> reset() async {
  await sl.reset();
}

/// Check if a dependency is registered
bool isRegistered<T extends Object>({String? instanceName}) {
  return sl.isRegistered<T>(instanceName: instanceName);
}

/// Get dependency instance
T get<T extends Object>({String? instanceName}) {
  return sl.get<T>(instanceName: instanceName);
}
