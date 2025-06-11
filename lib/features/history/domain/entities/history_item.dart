import 'package:equatable/equatable.dart';

/// History item entity representing a translation history entry
class HistoryItem extends Equatable {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final bool isFavorite;
  final double? confidence;
  final List<String>? alternatives;

  const HistoryItem({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isFavorite = false,
    this.confidence,
    this.alternatives,
  });

  HistoryItem copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    bool? isFavorite,
    double? confidence,
    List<String>? alternatives,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      confidence: confidence ?? this.confidence,
      alternatives: alternatives ?? this.alternatives,
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
      ];
}
