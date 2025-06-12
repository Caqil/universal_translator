// lib/features/camera/domain/entities/translation_result.dart
import 'package:equatable/equatable.dart';

class TranslationResult extends Equatable {
  final List<String> recognizedTexts;
  final List<String> translatedTexts;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;

  const TranslationResult({
    required this.recognizedTexts,
    required this.translatedTexts,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.confidence = 0.0,
  });

  @override
  List<Object?> get props => [
        recognizedTexts,
        translatedTexts,
        sourceLanguage,
        targetLanguage,
        confidence,
      ];
}
