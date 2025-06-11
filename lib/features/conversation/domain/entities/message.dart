// lib/features/conversation/domain/entities/message.dart
import 'package:equatable/equatable.dart';

/// Message types in a conversation
enum MessageType {
  text,
  translation,
  voice,
  system,
}

/// Message sender types
enum MessageSender {
  user,
  participant,
  system,
}

/// Domain entity representing a message in a conversation
class Message extends Equatable {
  /// Unique identifier for the message
  final String id;

  /// ID of the conversation this message belongs to
  final String conversationId;

  /// Type of the message
  final MessageType type;

  /// Who sent the message
  final MessageSender sender;

  /// Original text content
  final String originalText;

  /// Translated text content (if applicable)
  final String? translatedText;

  /// Language of the original text
  final String originalLanguage;

  /// Language of the translated text (if applicable)
  final String? translatedLanguage;

  /// When the message was created
  final DateTime timestamp;

  /// Whether the message has been read
  final bool isRead;

  /// Whether the message is currently being translated
  final bool isTranslating;

  /// Translation confidence score (0.0 to 1.0)
  final double? confidence;

  /// Voice message file path (if applicable)
  final String? voiceFilePath;

  /// Voice message duration in seconds (if applicable)
  final int? voiceDuration;

  /// Whether this message failed to translate
  final bool hasTranslationError;

  /// Translation error message
  final String? translationError;

  /// Whether this message is favorited
  final bool isFavorite;

  const Message({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.sender,
    required this.originalText,
    this.translatedText,
    required this.originalLanguage,
    this.translatedLanguage,
    required this.timestamp,
    this.isRead = false,
    this.isTranslating = false,
    this.confidence,
    this.voiceFilePath,
    this.voiceDuration,
    this.hasTranslationError = false,
    this.translationError,
    this.isFavorite = false,
  });

  /// Create a copy of this message with updated values
  Message copyWith({
    String? id,
    String? conversationId,
    MessageType? type,
    MessageSender? sender,
    String? originalText,
    String? translatedText,
    String? originalLanguage,
    String? translatedLanguage,
    DateTime? timestamp,
    bool? isRead,
    bool? isTranslating,
    double? confidence,
    String? voiceFilePath,
    int? voiceDuration,
    bool? hasTranslationError,
    String? translationError,
    bool? isFavorite,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isTranslating: isTranslating ?? this.isTranslating,
      confidence: confidence ?? this.confidence,
      voiceFilePath: voiceFilePath ?? this.voiceFilePath,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      hasTranslationError: hasTranslationError ?? this.hasTranslationError,
      translationError: translationError ?? this.translationError,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Check if this message has a translation
  bool get hasTranslation =>
      translatedText != null && translatedText!.isNotEmpty;

  /// Check if this message is from the user
  bool get isFromUser => sender == MessageSender.user;

  /// Check if this message is from a participant
  bool get isFromParticipant => sender == MessageSender.participant;

  /// Check if this message is a system message
  bool get isSystemMessage => sender == MessageSender.system;

  /// Check if this message has voice content
  bool get hasVoice => voiceFilePath != null && voiceFilePath!.isNotEmpty;

  /// Get display text based on preference
  String getDisplayText({bool preferTranslation = false}) {
    if (preferTranslation && hasTranslation) {
      return translatedText!;
    }
    return originalText;
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        type,
        sender,
        originalText,
        translatedText,
        originalLanguage,
        translatedLanguage,
        timestamp,
        isRead,
        isTranslating,
        confidence,
        voiceFilePath,
        voiceDuration,
        hasTranslationError,
        translationError,
        isFavorite,
      ];

  @override
  String toString() => 'Message(id: $id, type: $type, sender: $sender)';
}
