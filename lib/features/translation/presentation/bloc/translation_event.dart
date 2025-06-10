import 'package:equatable/equatable.dart';

/// Base class for all translation events
abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to translate text
class TranslateTextEvent extends TranslationEvent {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslateTextEvent({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [text, sourceLanguage, targetLanguage];
}

/// Event to detect language of text
class DetectLanguageEvent extends TranslationEvent {
  final String text;

  const DetectLanguageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Event to load supported languages
class LoadSupportedLanguagesEvent extends TranslationEvent {
  final bool forceRefresh;

  const LoadSupportedLanguagesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to swap source and target languages
class SwapLanguagesEvent extends TranslationEvent {
  const SwapLanguagesEvent();
}

/// Event to clear current translation
class ClearTranslationEvent extends TranslationEvent {
  const ClearTranslationEvent();
}

/// Event to set source language
class SetSourceLanguageEvent extends TranslationEvent {
  final String languageCode;

  const SetSourceLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to set target language
class SetTargetLanguageEvent extends TranslationEvent {
  final String languageCode;

  const SetTargetLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to set source text
class SetSourceTextEvent extends TranslationEvent {
  final String text;

  const SetSourceTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}
