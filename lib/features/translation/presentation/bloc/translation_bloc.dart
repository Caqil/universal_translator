import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/usecases/detect_language.dart';
import '../../domain/usecases/get_supported_languages.dart';
import '../../domain/usecases/translate_text.dart';
import 'translation_event.dart';
import 'translation_state.dart';

@injectable
class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslateText _translateText;
  final DetectLanguage _detectLanguage;
  final GetSupportedLanguages _getSupportedLanguages;

  TranslationBloc(
    this._translateText,
    this._detectLanguage,
    this._getSupportedLanguages,
  ) : super(const TranslationInitial()) {
    on<TranslateTextEvent>(_onTranslateText);
    on<DetectLanguageEvent>(_onDetectLanguage);
    on<LoadSupportedLanguagesEvent>(_onLoadSupportedLanguages);
    on<SwapLanguagesEvent>(_onSwapLanguages);
    on<ClearTranslationEvent>(_onClearTranslation);
    on<SetSourceLanguageEvent>(_onSetSourceLanguage);
    on<SetTargetLanguageEvent>(_onSetTargetLanguage);
    on<SetSourceTextEvent>(_onSetSourceText);
  }

  Future<void> _onTranslateText(
    TranslateTextEvent event,
    Emitter<TranslationState> emit,
  ) async {
    final currentState = state;

    // Don't translate if text is empty or same as current
    if (event.text.trim().isEmpty) {
      emit(currentState.copyWith(
        status: TranslationStatus.initial,
        currentTranslation: null,
        errorMessage: null,
      ));
      return;
    }

    // Show loading state
    emit(currentState.copyWith(
      status: TranslationStatus.translating,
      errorMessage: null,
    ));

    // Estimate translation time for better UX
    final estimatedTime = AppUtils.estimateTranslationTime(event.text);

    // Perform translation
    final result = await _translateText(TranslateTextParams(
      text: event.text,
      sourceLanguage: event.sourceLanguage,
      targetLanguage: event.targetLanguage,
    ));

    result.fold(
      (failure) => emit(currentState.copyWith(
        status: TranslationStatus.failure,
        errorMessage: failure.message,
      )),
      (translation) => emit(currentState.copyWith(
        status: TranslationStatus.success,
        currentTranslation: translation,
        errorMessage: null,
        sourceText: event.text,
        sourceLanguage: event.sourceLanguage,
        targetLanguage: event.targetLanguage,
      )),
    );
  }

  Future<void> _onDetectLanguage(
    DetectLanguageEvent event,
    Emitter<TranslationState> emit,
  ) async {
    final currentState = state;

    if (event.text.trim().isEmpty) return;

    emit(currentState.copyWith(
      status: TranslationStatus.detectingLanguage,
      errorMessage: null,
    ));

    final result =
        await _detectLanguage(DetectLanguageParams(text: event.text));

    result.fold(
      (failure) => emit(currentState.copyWith(
        status: TranslationStatus.failure,
        errorMessage: failure.message,
      )),
      (detectedLanguage) => emit(currentState.copyWith(
        status: TranslationStatus.languageDetected,
        detectedLanguage: detectedLanguage,
        sourceLanguage: detectedLanguage,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadSupportedLanguages(
    LoadSupportedLanguagesEvent event,
    Emitter<TranslationState> emit,
  ) async {
    final currentState = state;

    if (currentState.supportedLanguages.isNotEmpty && !event.forceRefresh) {
      return; // Already loaded
    }

    emit(currentState.copyWith(
      status: TranslationStatus.loadingLanguages,
      errorMessage: null,
    ));

    final result = await _getSupportedLanguages();

    result.fold(
      (failure) => emit(currentState.copyWith(
        status: TranslationStatus.failure,
        errorMessage: failure.message,
      )),
      (languages) => emit(currentState.copyWith(
        status: TranslationStatus.languagesLoaded,
        supportedLanguages: languages,
        errorMessage: null,
      )),
    );
  }

  void _onSwapLanguages(
    SwapLanguagesEvent event,
    Emitter<TranslationState> emit,
  ) {
    final currentState = state;

    // Don't swap if source is auto-detect
    if (currentState.sourceLanguage == 'auto') return;

    final newSourceLanguage = currentState.targetLanguage;
    final newTargetLanguage = currentState.sourceLanguage;

    emit(currentState.copyWith(
      sourceLanguage: newSourceLanguage,
      targetLanguage: newTargetLanguage,
      sourceText: currentState.currentTranslation?.translatedText ?? '',
      currentTranslation: null,
      status: TranslationStatus.initial,
    ));
  }

  void _onClearTranslation(
    ClearTranslationEvent event,
    Emitter<TranslationState> emit,
  ) {
    final currentState = state;

    emit(currentState.copyWith(
      status: TranslationStatus.initial,
      sourceText: '',
      currentTranslation: null,
      detectedLanguage: null,
      errorMessage: null,
    ));
  }

  void _onSetSourceLanguage(
    SetSourceLanguageEvent event,
    Emitter<TranslationState> emit,
  ) {
    final currentState = state;

    emit(currentState.copyWith(
      sourceLanguage: event.languageCode,
      detectedLanguage: null,
    ));
  }

  void _onSetTargetLanguage(
    SetTargetLanguageEvent event,
    Emitter<TranslationState> emit,
  ) {
    final currentState = state;

    emit(currentState.copyWith(
      targetLanguage: event.languageCode,
    ));
  }

  void _onSetSourceText(
    SetSourceTextEvent event,
    Emitter<TranslationState> emit,
  ) {
    final currentState = state;

    emit(currentState.copyWith(
      sourceText: event.text,
      currentTranslation: null,
      detectedLanguage: null,
      status: event.text.trim().isEmpty
          ? TranslationStatus.initial
          : TranslationStatus.ready,
    ));
  }
}
