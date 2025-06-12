import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_utils.dart';
import '../../../history/domain/entities/history_item.dart';
import '../../../history/domain/usecases/save_to_history.dart';
import '../../../settings/domain/usecases/get_settings.dart';
import '../../domain/repositories/translation_repository.dart';
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
  final SaveToHistory _saveToHistory;
  final GetSettings _getSettings;
  final Uuid _uuid = const Uuid();
  final TranslationRepository _translationRepository;
  TranslationBloc(
    this._translateText,
    this._detectLanguage,
    this._getSupportedLanguages,
    this._saveToHistory,
    this._getSettings,
    this._translationRepository,
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

    await result.fold(
      (failure) async {
        emit(currentState.copyWith(
          status: TranslationStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (translation) async {
        // Emit success state first
        emit(currentState.copyWith(
          status: TranslationStatus.success,
          currentTranslation: translation,
          errorMessage: null,
          sourceText: event.text,
          sourceLanguage: event.sourceLanguage,
          targetLanguage: event.targetLanguage,
        ));

        // **AUTO-SAVE TO HISTORY**
        await _saveTranslationToHistoryIfEnabled(
          translation: translation,
          sourceText: event.text,
          sourceLanguage: event.sourceLanguage,
          targetLanguage: event.targetLanguage,
        );
      },
    );
  }

  /// Save translation to history if auto-save is enabled
  Future<void> _saveTranslationToHistoryIfEnabled({
    required dynamic translation, // Your Translation entity
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Get current settings to check if auto-save is enabled
      final settingsResult = await _getSettings();

      await settingsResult.fold(
        (failure) async {
          // If we can't get settings, assume auto-save is disabled
          print(
              '⚠️ Could not get settings for auto-save check: ${failure.message}');
        },
        (settings) async {
          // Check if auto-save translations is enabled
          if (settings.autoSaveTranslations) {
            // Create history item
            final historyItem = HistoryItem(
              id: _uuid.v4(),
              sourceText: sourceText,
              translatedText: translation.translatedText,
              sourceLanguage: sourceLanguage,
              targetLanguage: targetLanguage,
              timestamp: DateTime.now(),
              isFavorite: false,
              confidence: translation.confidence,
              alternatives: translation.alternatives,
            );

            // Save to history
            final saveResult = await _saveToHistory(historyItem);
            saveResult.fold(
              (failure) {
                print(
                    '⚠️ Failed to auto-save translation to history: ${failure.message}');
              },
              (_) {
                print('✅ Translation auto-saved to history');
              },
            );
          } else {
            print('ℹ️ Auto-save translations is disabled');
          }
        },
      );
    } catch (e) {
      print('❌ Error during auto-save to history: $e');
    }
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

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<TranslationState> emit,
  ) async {
    final currentState = state;

    if (currentState.currentTranslation == null) {
      emit(currentState.copyWith(
        errorMessage: 'No translation to favorite',
      ));
      return;
    }

    try {
      final result =
          await _translationRepository.toggleFavorite(event.translationId);

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            errorMessage: failure.message,
          ));
        },
        (updatedTranslation) {
          emit(currentState.copyWith(
            currentTranslation: updatedTranslation,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(currentState.copyWith(
        errorMessage: 'Failed to toggle favorite: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSaveCurrentTranslation(
    SaveCurrentTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    final currentState = state;

    if (currentState.currentTranslation == null) {
      emit(currentState.copyWith(
        errorMessage: 'No translation to save',
      ));
      return;
    }

    try {
      // Save to history
      final historyItem = HistoryItem(
        id: _uuid.v4(),
        sourceText: currentState.currentTranslation!.sourceText,
        translatedText: currentState.currentTranslation!.translatedText,
        sourceLanguage: currentState.currentTranslation!.sourceLanguage,
        targetLanguage: currentState.currentTranslation!.targetLanguage,
        timestamp: DateTime.now(),
        confidence: currentState.currentTranslation!.confidence,
        isFavorite: event.asFavorite,
      );

      final result = await _saveToHistory(historyItem);

      result.fold(
        (failure) {
          emit(currentState.copyWith(
            errorMessage: failure.message,
          ));
        },
        (_) {
          // Successfully saved - you might want to emit a success state or just clear error
          emit(currentState.copyWith(
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(currentState.copyWith(
        errorMessage: 'Failed to save translation: ${e.toString()}',
      ));
    }
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
