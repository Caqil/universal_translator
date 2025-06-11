// lib/features/conversation/data/models/conversation_model.dart
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/conversation.dart';
import 'message_model.dart';
part 'conversation_model.g.dart';

/// Data model for conversation with Hive and JSON serialization
@HiveType(typeId: 6)
@JsonSerializable()
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<MessageModel> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final String sourceLanguage;

  @HiveField(6)
  final String targetLanguage;

  @HiveField(7)
  final bool isArchived;

  @HiveField(8)
  final bool isPinned;

  @HiveField(9)
  final String? participantName;

  @HiveField(10)
  final String? category;

  ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.isArchived = false,
    this.isPinned = false,
    this.participantName,
    this.category,
  });

  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  /// Create from domain entity
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages
          .map((message) => MessageModel.fromEntity(message))
          .toList(),
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      sourceLanguage: conversation.sourceLanguage,
      targetLanguage: conversation.targetLanguage,
      isArchived: conversation.isArchived,
      isPinned: conversation.isPinned,
      participantName: conversation.participantName,
      category: conversation.category,
    );
  }

  /// Convert to domain entity
  Conversation toEntity() {
    return Conversation(
      id: id,
      title: title,
      messages: messages.map((message) => message.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isArchived: isArchived,
      isPinned: isPinned,
      participantName: participantName,
      category: category,
    );
  }

  /// Create a copy with updated values
  ConversationModel copyWith({
    String? id,
    String? title,
    List<MessageModel>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isArchived,
    bool? isPinned,
    String? participantName,
    String? category,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      participantName: participantName ?? this.participantName,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel &&
        other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.sourceLanguage == sourceLanguage &&
        other.targetLanguage == targetLanguage &&
        other.isArchived == isArchived &&
        other.isPinned == isPinned &&
        other.participantName == participantName &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      createdAt,
      updatedAt,
      sourceLanguage,
      targetLanguage,
      isArchived,
      isPinned,
      participantName,
      category,
    );
  }

  @override
  String toString() => 'ConversationModel(id: $id, title: $title)';
}
