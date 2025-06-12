// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_tts/flutter_tts.dart' as _i50;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:speech_to_text/speech_to_text.dart' as _i941;
import 'package:uuid/uuid.dart' as _i706;

import '../../features/camera/data/datasources/camera_datasource.dart' as _i261;
import '../../features/camera/data/datasources/ocr_datasource.dart' as _i638;
import '../../features/camera/data/repositories/camera_repository_impl.dart'
    as _i145;
import '../../features/camera/domain/repositories/camera_repository.dart'
    as _i491;
import '../../features/camera/domain/usecases/capture_image_usecase.dart'
    as _i567;
import '../../features/camera/domain/usecases/initialize_camera_usecase.dart'
    as _i638;
import '../../features/camera/domain/usecases/process_image_for_translation_usecase.dart'
    as _i737;
import '../../features/camera/domain/usecases/select_image_from_gallery_usecase.dart'
    as _i595;
import '../../features/camera/presentation/bloc/camera_bloc.dart' as _i702;
import '../../features/conversation/data/datasources/conversation_local_datasource.dart'
    as _i411;
import '../../features/conversation/data/models/conversation_session_model.dart'
    as _i955;
import '../../features/conversation/data/repositories/conversation_repository_impl.dart'
    as _i144;
import '../../features/conversation/domain/repositories/conversation_repository.dart'
    as _i937;
import '../../features/conversation/domain/usecases/get_conversations_usecase.dart'
    as _i496;
import '../../features/conversation/domain/usecases/save_conversation_usecase.dart'
    as _i704;
import '../../features/conversation/domain/usecases/start_conversation_usecase.dart'
    as _i946;
import '../../features/conversation/presentation/bloc/conversation_bloc.dart'
    as _i943;
import '../../features/history/data/datasources/history_local_datasource.dart'
    as _i665;
import '../../features/history/data/models/history_item_model.dart' as _i13;
import '../../features/history/data/repositories/history_repository_impl.dart'
    as _i751;
import '../../features/history/domain/repositories/history_repository.dart'
    as _i142;
import '../../features/history/domain/usecases/clear_history.dart' as _i772;
import '../../features/history/domain/usecases/delete_history_item.dart'
    as _i391;
import '../../features/history/domain/usecases/get_history.dart' as _i886;
import '../../features/history/domain/usecases/save_to_history.dart' as _i952;
import '../../features/history/presentation/bloc/history_bloc.dart' as _i1070;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i723;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_settings.dart' as _i558;
import '../../features/settings/domain/usecases/update_settings.dart' as _i986;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../../features/speech/data/datasources/speech_datasource.dart' as _i334;
import '../../features/speech/data/repositories/speech_repository_impl.dart'
    as _i753;
import '../../features/speech/domain/repositories/speech_repository.dart'
    as _i921;
import '../../features/speech/domain/usecases/start_listening.dart' as _i296;
import '../../features/speech/domain/usecases/stop_listening.dart' as _i339;
import '../../features/speech/domain/usecases/text_to_speech.dart' as _i351;
import '../../features/speech/presentation/bloc/speech_bloc.dart' as _i437;
import '../../features/translation/data/datasources/translation_local_datasource.dart'
    as _i657;
import '../../features/translation/data/datasources/translation_remote_datasource.dart'
    as _i440;
import '../../features/translation/data/repositories/translation_repository_impl.dart'
    as _i645;
import '../../features/translation/domain/repositories/translation_repository.dart'
    as _i683;
import '../../features/translation/domain/usecases/detect_language.dart'
    as _i376;
import '../../features/translation/domain/usecases/get_supported_languages.dart'
    as _i858;
import '../../features/translation/domain/usecases/translate_text.dart'
    as _i301;
import '../../features/translation/presentation/bloc/translation_bloc.dart'
    as _i152;
import '../network/dio_client.dart' as _i667;
import '../network/network_info.dart' as _i932;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final networkModule = _$NetworkModule();
  gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient());
  gh.lazySingleton<_i895.Connectivity>(() => networkModule.connectivity);
  gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => networkModule.internetConnectionChecker);
  gh.lazySingleton<_i638.OcrDataSource>(() => _i638.OcrDataSourceImpl());
  gh.lazySingleton<_i657.TranslationLocalDataSource>(
      () => _i657.TranslationLocalDataSourceImpl(
            gh<_i979.Box<dynamic>>(instanceName: 'translationsBox'),
            gh<_i979.Box<dynamic>>(instanceName: 'languagesBox'),
            gh<_i979.Box<dynamic>>(instanceName: 'settingsBox'),
          ));
  gh.lazySingleton<_i723.SettingsLocalDataSource>(() =>
      _i723.SettingsLocalDataSourceImpl(
          gh<_i979.Box<dynamic>>(instanceName: 'settingsBox')));
  gh.lazySingleton<_i261.CameraDataSource>(() => _i261.CameraDataSourceImpl());
  gh.lazySingleton<_i440.TranslationRemoteDataSource>(
      () => _i440.TranslationRemoteDataSourceImpl(gh<_i667.DioClient>()));
  gh.lazySingleton<_i665.HistoryLocalDataSource>(() =>
      _i665.HistoryLocalDataSourceImpl(
          gh<_i979.Box<_i13.HistoryItemModel>>(instanceName: 'historyBox')));
  gh.lazySingleton<_i411.ConversationLocalDataSource>(() =>
      _i411.ConversationLocalDataSourceImpl(
          gh<_i979.Box<_i955.ConversationSessionModel>>(
              instanceName: 'conversationsBox')));
  gh.lazySingleton<_i334.SpeechDataSource>(() => _i334.SpeechDataSourceImpl(
        gh<_i941.SpeechToText>(),
        gh<_i50.FlutterTts>(),
      ));
  gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl(
        gh<_i895.Connectivity>(),
        gh<_i973.InternetConnectionChecker>(),
      ));
  gh.lazySingleton<_i937.ConversationRepository>(
      () => _i144.ConversationRepositoryImpl(
            gh<_i411.ConversationLocalDataSource>(),
            gh<_i706.Uuid>(),
          ));
  gh.lazySingleton<_i142.HistoryRepository>(
      () => _i751.HistoryRepositoryImpl(gh<_i665.HistoryLocalDataSource>()));
  gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i723.SettingsLocalDataSource>()));
  gh.factory<_i496.GetConversationsUsecase>(
      () => _i496.GetConversationsUsecase(gh<_i937.ConversationRepository>()));
  gh.factory<_i946.StartConversationUsecase>(
      () => _i946.StartConversationUsecase(gh<_i937.ConversationRepository>()));
  gh.factory<_i704.SaveConversationUsecase>(
      () => _i704.SaveConversationUsecase(gh<_i937.ConversationRepository>()));
  gh.lazySingleton<_i683.TranslationRepository>(
      () => _i645.TranslationRepositoryImpl(
            gh<_i440.TranslationRemoteDataSource>(),
            gh<_i657.TranslationLocalDataSource>(),
            gh<_i932.NetworkInfo>(),
          ));
  gh.lazySingleton<_i921.SpeechRepository>(
      () => _i753.SpeechRepositoryImpl(gh<_i334.SpeechDataSource>()));
  gh.factory<_i339.StopListening>(
      () => _i339.StopListening(gh<_i921.SpeechRepository>()));
  gh.factory<_i296.StartListening>(
      () => _i296.StartListening(gh<_i921.SpeechRepository>()));
  gh.factory<_i351.TextToSpeech>(
      () => _i351.TextToSpeech(gh<_i921.SpeechRepository>()));
  gh.lazySingleton<_i491.CameraRepository>(() => _i145.CameraRepositoryImpl(
        gh<_i261.CameraDataSource>(),
        gh<_i638.OcrDataSource>(),
        gh<_i683.TranslationRepository>(),
      ));
  gh.factory<_i952.SaveToHistory>(
      () => _i952.SaveToHistory(gh<_i142.HistoryRepository>()));
  gh.factory<_i886.GetHistory>(
      () => _i886.GetHistory(gh<_i142.HistoryRepository>()));
  gh.factory<_i391.DeleteHistoryItem>(
      () => _i391.DeleteHistoryItem(gh<_i142.HistoryRepository>()));
  gh.factory<_i772.ClearHistory>(
      () => _i772.ClearHistory(gh<_i142.HistoryRepository>()));
  gh.factory<_i1070.HistoryBloc>(() => _i1070.HistoryBloc(
        gh<_i886.GetHistory>(),
        gh<_i952.SaveToHistory>(),
        gh<_i391.DeleteHistoryItem>(),
        gh<_i772.ClearHistory>(),
        gh<_i142.HistoryRepository>(),
      ));
  gh.factory<_i558.GetSettings>(
      () => _i558.GetSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i558.GetSetting<dynamic>>(
      () => _i558.GetSetting<dynamic>(gh<_i674.SettingsRepository>()));
  gh.factory<_i558.HasSettings>(
      () => _i558.HasSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i558.WatchSettings>(
      () => _i558.WatchSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i558.ExportSettings>(
      () => _i558.ExportSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.UpdateSettings>(
      () => _i986.UpdateSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.UpdateSetting<dynamic>>(
      () => _i986.UpdateSetting<dynamic>(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.ResetSettings>(
      () => _i986.ResetSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.ImportSettings>(
      () => _i986.ImportSettings(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.UpdateTheme>(
      () => _i986.UpdateTheme(gh<_i674.SettingsRepository>()));
  gh.factory<_i986.UpdateLanguage>(
      () => _i986.UpdateLanguage(gh<_i674.SettingsRepository>()));
  gh.factory<_i858.GetSupportedLanguages>(
      () => _i858.GetSupportedLanguages(gh<_i683.TranslationRepository>()));
  gh.factory<_i376.DetectLanguage>(
      () => _i376.DetectLanguage(gh<_i683.TranslationRepository>()));
  gh.factory<_i301.TranslateText>(
      () => _i301.TranslateText(gh<_i683.TranslationRepository>()));
  gh.factory<_i585.SettingsBloc>(() => _i585.SettingsBloc(
        gh<_i558.GetSettings>(),
        gh<_i986.UpdateSettings>(),
        gh<_i986.UpdateSetting<dynamic>>(),
        gh<_i986.ResetSettings>(),
        gh<_i558.ExportSettings>(),
        gh<_i986.ImportSettings>(),
        gh<_i558.WatchSettings>(),
      ));
  gh.factory<_i437.SpeechBloc>(() => _i437.SpeechBloc(
        gh<_i296.StartListening>(),
        gh<_i339.StopListening>(),
        gh<_i351.TextToSpeech>(),
        gh<_i921.SpeechRepository>(),
      ));
  gh.factory<_i567.CaptureImageUseCase>(
      () => _i567.CaptureImageUseCase(gh<_i491.CameraRepository>()));
  gh.factory<_i595.SelectImageFromGalleryUseCase>(
      () => _i595.SelectImageFromGalleryUseCase(gh<_i491.CameraRepository>()));
  gh.factory<_i737.ProcessImageForTranslationUseCase>(() =>
      _i737.ProcessImageForTranslationUseCase(gh<_i491.CameraRepository>()));
  gh.factory<_i638.InitializeCameraUseCase>(
      () => _i638.InitializeCameraUseCase(gh<_i491.CameraRepository>()));
  gh.factory<_i152.TranslationBloc>(() => _i152.TranslationBloc(
        gh<_i301.TranslateText>(),
        gh<_i376.DetectLanguage>(),
        gh<_i858.GetSupportedLanguages>(),
        gh<_i952.SaveToHistory>(),
        gh<_i558.GetSettings>(),
        gh<_i683.TranslationRepository>(),
      ));
  gh.factory<_i943.ConversationBloc>(() => _i943.ConversationBloc(
        gh<_i301.TranslateText>(),
        gh<_i858.GetSupportedLanguages>(),
        gh<_i296.StartListening>(),
        gh<_i339.StopListening>(),
        gh<_i351.TextToSpeech>(),
        gh<_i946.StartConversationUsecase>(),
        gh<_i704.SaveConversationUsecase>(),
        gh<_i706.Uuid>(),
      ));
  gh.factory<_i702.CameraBloc>(() => _i702.CameraBloc(
        gh<_i638.InitializeCameraUseCase>(),
        gh<_i567.CaptureImageUseCase>(),
        gh<_i595.SelectImageFromGalleryUseCase>(),
        gh<_i737.ProcessImageForTranslationUseCase>(),
      ));
  return getIt;
}

class _$NetworkModule extends _i932.NetworkModule {}
