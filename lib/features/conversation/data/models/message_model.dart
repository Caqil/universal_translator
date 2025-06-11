// lib/features/conversation/data/models/message_model.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/message.dart';

part 'message_model.g.dart';

/// Hive adapter for MessageType enum
@HiveType(typeId: 7)
enum MessageTypeAdapter {
  @HiveField(0)
  text,
  @HiveField(1)
  translation,
  @HiveField(2)
  voice,
  @HiveField(3)
  system,
}

/// Hive adapter for MessageSender enum
@HiveType(typeId: 8)
enum MessageSenderAdapter {
  @HiveField(0)
  user,
  @HiveField(1)
  participant,
  @HiveField(2)
  system,
}

/// Data model for message with Hive and JSON serialization
@HiveType(typeId: 9)
@JsonSerializable()
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final MessageTypeAdapter type;

  @HiveField(3)
  final MessageSenderAdapter sender;

  @HiveField(4)
  final String originalText;

  @HiveField(5)
  final String? translatedText;

  @HiveField(6)
  final String originalLanguage;

  @HiveField(7)
  final String? translatedLanguage;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final bool isRead;

  @HiveField(10)
  final bool isTranslating;

  @HiveField(11)
  final double? confidence;

  @HiveField(12)
  final String? voiceFilePath;

  @HiveField(13)
  final int? voiceDuration;

  @HiveField(14)
  final bool hasTranslationError;

  @HiveField(15)
  final String? translationError;

  @HiveField(16)
  final bool isFavorite;

  MessageModel({
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

  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// Create from domain entity
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      conversationId: message.conversationId,
      type: messageTypeToAdapter(message.type),
      sender: messageSenderToAdapter(message.sender),
      originalText: message.originalText,
      translatedText: message.translatedText,
      originalLanguage: message.originalLanguage,
      translatedLanguage: message.translatedLanguage,
      timestamp: message.timestamp,
      isRead: message.isRead,
      isTranslating: message.isTranslating,
      confidence: message.confidence,
      voiceFilePath: message.voiceFilePath,
      voiceDuration: message.voiceDuration,
      hasTranslationError: message.hasTranslationError,
      translationError: message.translationError,
      isFavorite: message.isFavorite,
    );
  }

  /// Convert to domain entity
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      type: adapterToMessageType(type),
      sender: adapterToMessageSender(sender),
      originalText: originalText,
      translatedText: translatedText,
      originalLanguage: originalLanguage,
      translatedLanguage: translatedLanguage,
      timestamp: timestamp,
      isRead: isRead,
      isTranslating: isTranslating,
      confidence: confidence,
      voiceFilePath: voiceFilePath,
      voiceDuration: voiceDuration,
      hasTranslationError: hasTranslationError,
      translationError: translationError,
      isFavorite: isFavorite,
    );
  }

  /// Create a copy with updated values
  MessageModel copyWith({
    String? id,
    String? conversationId,
    MessageTypeAdapter? type,
    MessageSenderAdapter? sender,
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
    return MessageModel(
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

  /// Convert MessageType to MessageTypeAdapter
  static MessageTypeAdapter messageTypeToAdapter(MessageType type) {
    switch (type) {
      case MessageType.text:
        return MessageTypeAdapter.text;
      case MessageType.translation:
        return MessageTypeAdapter.translation;
      case MessageType.voice:
        return MessageTypeAdapter.voice;
      case MessageType.system:
        return MessageTypeAdapter.system;
    }
  }

  /// Convert MessageTypeAdapter to MessageType
  static MessageType adapterToMessageType(MessageTypeAdapter adapter) {
    switch (adapter) {
      case MessageTypeAdapter.text:
        return MessageType.text;
      case MessageTypeAdapter.translation:
        return MessageType.translation;
      case MessageTypeAdapter.voice:
        return MessageType.voice;
      case MessageTypeAdapter.system:
        return MessageType.system;
    }
  }

  /// Convert MessageSender to MessageSenderAdapter
  static MessageSenderAdapter messageSenderToAdapter(MessageSender sender) {
    switch (sender) {
      case MessageSender.user:
        return MessageSenderAdapter.user;
      case MessageSender.participant:
        return MessageSenderAdapter.participant;
      case MessageSender.system:
        return MessageSenderAdapter.system;
    }
  }

  /// Convert MessageSenderAdapter to MessageSender
  static MessageSender adapterToMessageSender(MessageSenderAdapter adapter) {
    switch (adapter) {
      case MessageSenderAdapter.user:
        return MessageSender.user;
      case MessageSenderAdapter.participant:
        return MessageSender.participant;
      case MessageSenderAdapter.system:
        return MessageSender.system;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.type == type &&
        other.sender == sender &&
        other.originalText == originalText &&
        other.translatedText == translatedText &&
        other.originalLanguage == originalLanguage &&
        other.translatedLanguage == translatedLanguage &&
        other.timestamp == timestamp &&
        other.isRead == isRead &&
        other.isTranslating == isTranslating &&
        other.confidence == confidence &&
        other.voiceFilePath == voiceFilePath &&
        other.voiceDuration == voiceDuration &&
        other.hasTranslationError == hasTranslationError &&
        other.translationError == translationError &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return Object.hash(
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
    );
  }

  @override
  String toString() => 'MessageModel(id: $id, type: $type, sender: $sender)';
}
