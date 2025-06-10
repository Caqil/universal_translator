import 'package:equatable/equatable.dart';

/// Domain entity representing a translation
class Translation extends Equatable {
  /// Unique identifier for the translation
  final String id;

  /// Original text that was translated
  final String sourceText;

  /// Translated text
  final String translatedText;

  /// Source language code
  final String sourceLanguage;

  /// Target language code
  final String targetLanguage;

  /// When the translation was created
  final DateTime timestamp;

  /// Whether this translation is marked as favorite
  final bool isFavorite;

  /// Translation confidence score (0.0 to 1.0)
  final double? confidence;

  /// Alternative translations
  final List<String>? alternatives;

  /// Detected language if source was auto-detect
  final String? detectedLanguage;

  const Translation({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isFavorite = false,
    this.confidence,
    this.alternatives,
    this.detectedLanguage,
  });

  @override
  List<Object?> get props => [
        id,
        sourceText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        timestamp,
        isFavorite,
        confidence,
        alternatives,
        detectedLanguage,
      ];

  @override
  String toString() =>
      'Translation(id: $id, source: $sourceLanguage, target: $targetLanguage)';
}
