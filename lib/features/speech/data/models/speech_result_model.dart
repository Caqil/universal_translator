// lib/features/speech/data/models/speech_result_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/speech_result.dart';

part 'speech_result_model.g.dart';

/// Data model for speech recognition result
@JsonSerializable()
class SpeechResultModel extends Equatable {
  /// The recognized words/text
  final String recognizedWords;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Whether this is the final result
  final bool isFinal;

  /// Language code used for recognition
  final String languageCode;

  /// When the recognition occurred
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime timestamp;

  /// Alternative recognition results
  final List<String>? alternatives;

  /// Duration of the speech
  final Duration? duration;

  /// Whether the result has high confidence
  final bool hasHighConfidence;

  const SpeechResultModel({
    required this.recognizedWords,
    required this.confidence,
    required this.isFinal,
    required this.languageCode,
    required this.timestamp,
    this.alternatives,
    this.duration,
    this.hasHighConfidence = false,
  });

  /// Create from JSON
  factory SpeechResultModel.fromJson(Map<String, dynamic> json) =>
      _$SpeechResultModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SpeechResultModelToJson(this);

  /// Convert to domain entity
  SpeechResult toEntity() {
    return SpeechResult(
      recognizedWords: recognizedWords,
      confidence: confidence,
      isFinal: isFinal,
      languageCode: languageCode,
      timestamp: timestamp,
      alternatives: alternatives,
      duration: duration,
      hasHighConfidence: hasHighConfidence,
    );
  }

  /// Create from domain entity
  factory SpeechResultModel.fromEntity(SpeechResult entity) {
    return SpeechResultModel(
      recognizedWords: entity.recognizedWords,
      confidence: entity.confidence,
      isFinal: entity.isFinal,
      languageCode: entity.languageCode,
      timestamp: entity.timestamp,
      alternatives: entity.alternatives,
      duration: entity.duration,
      hasHighConfidence: entity.hasHighConfidence,
    );
  }

  /// Copy with new values
  SpeechResultModel copyWith({
    String? recognizedWords,
    double? confidence,
    bool? isFinal,
    String? languageCode,
    DateTime? timestamp,
    List<String>? alternatives,
    Duration? duration,
    bool? hasHighConfidence,
  }) {
    return SpeechResultModel(
      recognizedWords: recognizedWords ?? this.recognizedWords,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
      languageCode: languageCode ?? this.languageCode,
      timestamp: timestamp ?? this.timestamp,
      alternatives: alternatives ?? this.alternatives,
      duration: duration ?? this.duration,
      hasHighConfidence: hasHighConfidence ?? this.hasHighConfidence,
    );
  }

  @override
  List<Object?> get props => [
        recognizedWords,
        confidence,
        isFinal,
        languageCode,
        timestamp,
        alternatives,
        duration,
        hasHighConfidence,
      ];

  @override
  String toString() =>
      'SpeechResultModel(words: $recognizedWords, confidence: $confidence, isFinal: $isFinal)';

  /// Helper functions for JSON serialization
  static DateTime _dateTimeFromJson(String json) => DateTime.parse(json);
  static String _dateTimeToJson(DateTime dateTime) =>
      dateTime.toIso8601String();
}
