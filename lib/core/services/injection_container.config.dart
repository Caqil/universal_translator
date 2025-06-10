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
  gh.lazySingleton<_i895.Connectivity>(() => networkModule.connectivity);
  gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => networkModule.internetConnectionChecker);
  gh.lazySingleton<_i657.TranslationLocalDataSource>(
      () => _i657.TranslationLocalDataSourceImpl(
            gh<_i979.Box<dynamic>>(instanceName: 'translationsBox'),
            gh<_i979.Box<dynamic>>(instanceName: 'languagesBox'),
            gh<_i979.Box<dynamic>>(instanceName: 'settingsBox'),
          ));
  gh.lazySingleton<_i334.SpeechDataSource>(() => _i334.SpeechDataSourceImpl(
        gh<_i941.SpeechToText>(),
        gh<_i50.FlutterTts>(),
      ));
  gh.lazySingleton<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl(
        gh<_i895.Connectivity>(),
        gh<_i973.InternetConnectionChecker>(),
      ));
  gh.lazySingleton<_i667.DioClient>(
      () => _i667.DioClient(gh<_i932.NetworkInfo>()));
  gh.lazySingleton<_i921.SpeechRepository>(
      () => _i753.SpeechRepositoryImpl(gh<_i334.SpeechDataSource>()));
  gh.factory<_i339.StopListening>(
      () => _i339.StopListening(gh<_i921.SpeechRepository>()));
  gh.factory<_i296.StartListening>(
      () => _i296.StartListening(gh<_i921.SpeechRepository>()));
  gh.factory<_i351.TextToSpeech>(
      () => _i351.TextToSpeech(gh<_i921.SpeechRepository>()));
  gh.factory<_i437.SpeechBloc>(() => _i437.SpeechBloc(
        gh<_i296.StartListening>(),
        gh<_i339.StopListening>(),
        gh<_i351.TextToSpeech>(),
        gh<_i921.SpeechRepository>(),
      ));
  gh.lazySingleton<_i440.TranslationRemoteDataSource>(
      () => _i440.TranslationRemoteDataSourceImpl(gh<_i667.DioClient>()));
  gh.lazySingleton<_i683.TranslationRepository>(
      () => _i645.TranslationRepositoryImpl(
            gh<_i440.TranslationRemoteDataSource>(),
            gh<_i657.TranslationLocalDataSource>(),
            gh<_i932.NetworkInfo>(),
          ));
  gh.factory<_i858.GetSupportedLanguages>(
      () => _i858.GetSupportedLanguages(gh<_i683.TranslationRepository>()));
  gh.factory<_i376.DetectLanguage>(
      () => _i376.DetectLanguage(gh<_i683.TranslationRepository>()));
  gh.factory<_i301.TranslateText>(
      () => _i301.TranslateText(gh<_i683.TranslationRepository>()));
  gh.factory<_i152.TranslationBloc>(() => _i152.TranslationBloc(
        gh<_i301.TranslateText>(),
        gh<_i376.DetectLanguage>(),
        gh<_i858.GetSupportedLanguages>(),
      ));
  return getIt;
}

class _$NetworkModule extends _i932.NetworkModule {}
