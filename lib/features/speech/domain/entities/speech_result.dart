import 'package:equatable/equatable.dart';

/// Domain entity representing speech recognition result
class SpeechResult extends Equatable {
  /// The recognized words/text from speech
  final String recognizedWords;

  /// Confidence score of the recognition (0.0 to 1.0)
  final double confidence;

  /// Whether this is the final result or partial
  final bool isFinal;

  /// Language code used for recognition
  final String languageCode;

  /// When the recognition occurred
  final DateTime timestamp;

  /// Alternative recognition results
  final List<String>? alternatives;

  /// Duration of the speech input
  final Duration? duration;

  /// Whether the result has high confidence (>= 0.8)
  final bool hasHighConfidence;

  const SpeechResult({
    required this.recognizedWords,
    required this.confidence,
    required this.isFinal,
    required this.languageCode,
    required this.timestamp,
    this.alternatives,
    this.duration,
    this.hasHighConfidence = false,
  });

  /// Create a copy with updated values
  SpeechResult copyWith({
    String? recognizedWords,
    double? confidence,
    bool? isFinal,
    String? languageCode,
    DateTime? timestamp,
    List<String>? alternatives,
    Duration? duration,
    bool? hasHighConfidence,
  }) {
    return SpeechResult(
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

  /// Check if the recognition has text
  bool get hasText => recognizedWords.trim().isNotEmpty;

  /// Check if the confidence is low (< 0.5)
  bool get hasLowConfidence => confidence < 0.5;

  /// Check if the confidence is medium (0.5 - 0.8)
  bool get hasMediumConfidence => confidence >= 0.5 && confidence < 0.8;

  /// Get confidence as percentage
  int get confidencePercentage => (confidence * 100).round();

  /// Get confidence level description
  String get confidenceLevel {
    if (hasHighConfidence || confidence >= 0.8) return 'High';
    if (hasMediumConfidence) return 'Medium';
    return 'Low';
  }

  /// Get formatted duration if available
  String? get formattedDuration {
    if (duration == null) return null;

    final seconds = duration!.inSeconds;
    final milliseconds = duration!.inMilliseconds % 1000;

    if (seconds > 0) {
      return '${seconds}s';
    } else {
      return '${milliseconds}ms';
    }
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
      'SpeechResult(words: "$recognizedWords", confidence: $confidence, isFinal: $isFinal)';
}
