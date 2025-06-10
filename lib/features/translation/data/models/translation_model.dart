import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/translation.dart';

part 'translation_model.g.dart';

/// Data model for translation
@JsonSerializable()
class TranslationModel extends Equatable {
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
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;

  /// Whether this translation is marked as favorite
  final bool isFavorite;

  /// Translation confidence score (0.0 to 1.0)
  final double? confidence;

  /// Alternative translations
  final List<String>? alternatives;

  /// Detected language if source was auto-detect
  final String? detectedLanguage;

  const TranslationModel({
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

  /// Create from JSON
  factory TranslationModel.fromJson(Map<String, dynamic> json) =>
      _$TranslationModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$TranslationModelToJson(this);

  /// Convert to domain entity
  Translation toEntity() {
    return Translation(
      id: id,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: timestamp,
      isFavorite: isFavorite,
      confidence: confidence,
      alternatives: alternatives,
      detectedLanguage: detectedLanguage,
    );
  }

  /// Create from domain entity
  factory TranslationModel.fromEntity(Translation entity) {
    return TranslationModel(
      id: entity.id,
      sourceText: entity.sourceText,
      translatedText: entity.translatedText,
      sourceLanguage: entity.sourceLanguage,
      targetLanguage: entity.targetLanguage,
      timestamp: entity.timestamp,
      isFavorite: entity.isFavorite,
      confidence: entity.confidence,
      alternatives: entity.alternatives,
      detectedLanguage: entity.detectedLanguage,
    );
  }

  /// Copy with new values
  TranslationModel copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    bool? isFavorite,
    double? confidence,
    List<String>? alternatives,
    String? detectedLanguage,
  }) {
    return TranslationModel(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      alternatives: alternatives ?? this.alternatives,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }

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
      'TranslationModel(id: $id, source: $sourceLanguage, target: $targetLanguage)';

  /// Helper functions for JSON serialization
  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();
}
