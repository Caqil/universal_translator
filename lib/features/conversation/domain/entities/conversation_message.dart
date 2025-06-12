// lib/features/conversation/domain/entities/conversation_message.dart
import 'package:equatable/equatable.dart';

class ConversationMessage extends Equatable {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isUser1; // true for user 1, false for user 2
  final DateTime timestamp;
  final double confidence;
  final List<String> alternatives;
  final String? emotion; // detected emotion: happy, neutral, urgent, etc.

  const ConversationMessage({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.isUser1,
    required this.timestamp,
    this.confidence = 1.0,
    this.alternatives = const [],
    this.emotion,
  });

  ConversationMessage copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isUser1,
    DateTime? timestamp,
    double? confidence,
    List<String>? alternatives,
    String? emotion,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isUser1: isUser1 ?? this.isUser1,
      timestamp: timestamp ?? this.timestamp,
      confidence: confidence ?? this.confidence,
      alternatives: alternatives ?? this.alternatives,
      emotion: emotion ?? this.emotion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        isUser1,
        timestamp,
        confidence,
        alternatives,
        emotion
      ];
}
