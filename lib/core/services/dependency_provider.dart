// lib/core/services/dependency_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Core dependencies
import '../network/dio_client.dart';
import '../network/network_info.dart';

// Data sources
import '../../features/translation/data/datasources/translation_local_datasource.dart';
import '../../features/translation/data/datasources/translation_remote_datasource.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/speech/data/datasources/speech_datasource.dart';

// Repositories
import '../../features/translation/domain/repositories/translation_repository.dart';
import '../../features/translation/data/repositories/translation_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/speech/domain/repositories/speech_repository.dart';
import '../../features/speech/data/repositories/speech_repository_impl.dart';

// Use cases - Translation
import '../../features/translation/domain/usecases/translate_text.dart';
import '../../features/translation/domain/usecases/detect_language.dart';
import '../../features/translation/domain/usecases/get_supported_languages.dart';

// Use cases - Settings
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_settings.dart';

// Use cases - Speech
import '../../features/speech/domain/usecases/start_listening.dart';
import '../../features/speech/domain/usecases/stop_listening.dart';
import '../../features/speech/domain/usecases/text_to_speech.dart';

// BLoCs
import '../../features/translation/presentation/bloc/translation_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/speech/presentation/bloc/speech_bloc.dart';

/// Dependency provider that replaces injectable/get_it
/// Manually creates and manages all dependencies
class DependencyProvider {
  // External dependencies
  late final SharedPreferences _sharedPreferences;
  late final SpeechToText _speechToText;
  late final FlutterTts _flutterTts;
  late final List<CameraDescription> _cameras;
  late final Connectivity _connectivity;
  late final InternetConnectionChecker _internetChecker;

  // Hive boxes
  late final Box _translationsBox;
  late final Box _languagesBox;
  late final Box _settingsBox;

  // Core dependencies
  late final DioClient _dioClient;
  late final NetworkInfo _networkInfo;

  // Data sources
  late final TranslationLocalDataSource _translationLocalDataSource;
  late final TranslationRemoteDataSource _translationRemoteDataSource;
  late final SettingsLocalDataSource _settingsLocalDataSource;
  late final SpeechDataSource _speechDataSource;

  // Repositories
  late final TranslationRepository _translationRepository;
  late final SettingsRepository _settingsRepository;
  late final SpeechRepository _speechRepository;

  // Use cases - Translation
  late final TranslateText _translateText;
  late final DetectLanguage _detectLanguage;
  late final GetSupportedLanguages _getSupportedLanguages;

  // Use cases - Settings
  late final GetSettings _getSettings;
  late final UpdateSettings _updateSettings;
  late final UpdateSetting _updateSetting;
  late final ResetSettings _resetSettings;
  late final ExportSettings _exportSettings;
  late final ImportSettings _importSettings;
  late final WatchSettings _watchSettings;

  // Use cases - Speech
  late final StartListening _startListening;
  late final StopListening _stopListening;
  late final TextToSpeech _textToSpeech;

  // Private constructor
  DependencyProvider._();

  /// Initialize all dependencies
  static Future<DependencyProvider> initialize() async {
    final provider = DependencyProvider._();
    await provider._initializeDependencies();
    return provider;
  }

  /// Initialize all dependencies in the correct order
  Future<void> _initializeDependencies() async {
    try {
      debugPrint('🔄 Starting dependency initialization...');

      // Step 1: Initialize external dependencies
      await _initializeExternalDependencies();
      debugPrint('✅ External dependencies initialized');

      // Step 2: Initialize Hive boxes
      await _initializeHiveBoxes();
      debugPrint('✅ Hive boxes initialized');

      // Step 3: Initialize core dependencies
      _initializeCoreDependencies();
      debugPrint('✅ Core dependencies initialized');

      // Step 4: Initialize data sources
      _initializeDataSources();
      debugPrint('✅ Data sources initialized');

      // Step 5: Initialize repositories
      _initializeRepositories();
      debugPrint('✅ Repositories initialized');

      // Step 6: Initialize use cases
      _initializeUseCases();
      debugPrint('✅ Use cases initialized');

      debugPrint('✅ All dependencies initialized successfully');
    } catch (e) {
      debugPrint('❌ Dependency initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize external dependencies
  Future<void> _initializeExternalDependencies() async {
    // SharedPreferences
    _sharedPreferences = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 10));

    // Speech to Text
    _speechToText = SpeechToText();

    // Text to Speech
    _flutterTts = FlutterTts();

    // Camera
    try {
      _cameras = await availableCameras().timeout(const Duration(seconds: 5));
      debugPrint('✅ Cameras initialized (${_cameras.length} cameras found)');
    } catch (e) {
      debugPrint('⚠️ Camera initialization failed: $e');
      _cameras = [];
    }

    // Connectivity
    _connectivity = Connectivity();

    // Internet Connection Checker
    _internetChecker = InternetConnectionChecker.createInstance();
  }

  /// Initialize Hive boxes
  Future<void> _initializeHiveBoxes() async {
    _translationsBox = await Hive.openBox('translations_history')
        .timeout(const Duration(seconds: 10));

    _languagesBox =
        await Hive.openBox('languages').timeout(const Duration(seconds: 10));

    _settingsBox =
        await Hive.openBox('settings').timeout(const Duration(seconds: 10));
  }

  /// Initialize core dependencies
  void _initializeCoreDependencies() {
    _dioClient = DioClient();
    _networkInfo = NetworkInfoImpl(_connectivity, _internetChecker);
  }

  /// Initialize data sources
  void _initializeDataSources() {
    _translationLocalDataSource = TranslationLocalDataSourceImpl(
      _translationsBox,
      _languagesBox,
      _settingsBox,
    );

    _translationRemoteDataSource = TranslationRemoteDataSourceImpl(_dioClient);

    _settingsLocalDataSource = SettingsLocalDataSourceImpl(_settingsBox);

    _speechDataSource = SpeechDataSourceImpl(_speechToText, _flutterTts);
  }

  /// Initialize repositories
  void _initializeRepositories() {
    _translationRepository = TranslationRepositoryImpl(
      _translationRemoteDataSource,
      _translationLocalDataSource,
      _networkInfo,
    );

    _settingsRepository = SettingsRepositoryImpl(_settingsLocalDataSource);

    _speechRepository = SpeechRepositoryImpl(_speechDataSource);
  }

  /// Initialize use cases
  void _initializeUseCases() {
    // Translation use cases
    _translateText = TranslateText(_translationRepository);
    _detectLanguage = DetectLanguage(_translationRepository);
    _getSupportedLanguages = GetSupportedLanguages(_translationRepository);

    // Settings use cases
    _getSettings = GetSettings(_settingsRepository);
    _updateSettings = UpdateSettings(_settingsRepository);
    _updateSetting = UpdateSetting(_settingsRepository);
    _resetSettings = ResetSettings(_settingsRepository);
    _exportSettings = ExportSettings(_settingsRepository);
    _importSettings = ImportSettings(_settingsRepository);
    _watchSettings = WatchSettings(_settingsRepository);

    // Speech use cases
    _startListening = StartListening(_speechRepository);
    _stopListening = StopListening(_speechRepository);
    _textToSpeech = TextToSpeech(_speechRepository);
  }

  /// Create BLoC providers for the app
  List<BlocProvider> createBlocProviders() {
    return [
      BlocProvider<TranslationBloc>(
        create: (context) => TranslationBloc(
          _translateText,
          _detectLanguage,
          _getSupportedLanguages,
        ),
      ),
      BlocProvider<SettingsBloc>(
        create: (context) => SettingsBloc(
          _getSettings,
          _updateSettings,
          _updateSetting,
          _resetSettings,
          _exportSettings,
          _importSettings,
          _watchSettings,
        ),
      ),
      BlocProvider<SpeechBloc>(
        create: (context) => SpeechBloc(
          _startListening,
          _stopListening,
          _textToSpeech,
          _speechRepository,
        ),
      ),
    ];
  }

  /// Get specific dependency (if needed for direct access)
  T getDependency<T>() {
    switch (T) {
      case const (SharedPreferences):
        return _sharedPreferences as T;
      case const (SpeechToText):
        return _speechToText as T;
      case const (FlutterTts):
        return _flutterTts as T;
      case const (List<CameraDescription>):
        return _cameras as T;
      case const (TranslationRepository):
        return _translationRepository as T;
      case const (SettingsRepository):
        return _settingsRepository as T;
      case const (SpeechRepository):
        return _speechRepository as T;
      default:
        throw Exception('Dependency of type $T not found');
    }
  }
}
