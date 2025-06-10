import 'package:equatable/equatable.dart';

import '../../domain/entities/language.dart';
import '../../domain/entities/translation.dart';

/// Translation status enum
enum TranslationStatus {
  initial,
  ready,
  translating,
  detectingLanguage,
  loadingLanguages,
  success,
  languageDetected,
  languagesLoaded,
  failure,
}

/// Translation state
class TranslationState extends Equatable {
  final TranslationStatus status;
  final String sourceText;
  final String sourceLanguage;
  final String targetLanguage;
  final Translation? currentTranslation;
  final String? detectedLanguage;
  final List<Language> supportedLanguages;
  final String? errorMessage;

  const TranslationState({
    this.status = TranslationStatus.initial,
    this.sourceText = '',
    this.sourceLanguage = 'auto',
    this.targetLanguage = 'en',
    this.currentTranslation,
    this.detectedLanguage,
    this.supportedLanguages = const [],
    this.errorMessage,
  });

  /// Copy with new values
  TranslationState copyWith({
    TranslationStatus? status,
    String? sourceText,
    String? sourceLanguage,
    String? targetLanguage,
    Translation? currentTranslation,
    String? detectedLanguage,
    List<Language>? supportedLanguages,
    String? errorMessage,
  }) {
    return TranslationState(
      status: status ?? this.status,
      sourceText: sourceText ?? this.sourceText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      currentTranslation: currentTranslation,
      detectedLanguage: detectedLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceText,
        sourceLanguage,
        targetLanguage,
        currentTranslation,
        detectedLanguage,
        supportedLanguages,
        errorMessage,
      ];
}

/// Initial state
class TranslationInitial extends TranslationState {
  const TranslationInitial() : super();
}

// Translation state convenience getters
extension TranslationStateX on TranslationState {
  bool get isLoading =>
      status == TranslationStatus.translating ||
      status == TranslationStatus.detectingLanguage ||
      status == TranslationStatus.loadingLanguages;

  bool get hasError => status == TranslationStatus.failure;

  bool get hasTranslation => currentTranslation != null;

  bool get canTranslate =>
      sourceText.isNotEmpty &&
      sourceLanguage.isNotEmpty &&
      targetLanguage.isNotEmpty &&
      !isLoading;

  bool get canSwapLanguages =>
      sourceLanguage != 'auto' &&
      sourceLanguage.isNotEmpty &&
      targetLanguage.isNotEmpty;

  Language? getSourceLanguageInfo() {
    if (sourceLanguage == 'auto') return null;
    return supportedLanguages
        .where((lang) => lang.code == sourceLanguage)
        .firstOrNull;
  }

  Language? getTargetLanguageInfo() {
    return supportedLanguages
        .where((lang) => lang.code == targetLanguage)
        .firstOrNull;
  }
}
