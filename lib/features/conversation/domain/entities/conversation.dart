// lib/features/conversation/domain/entities/conversation.dart
import 'package:equatable/equatable.dart';
import 'message.dart';

/// Domain entity representing a conversation
class Conversation extends Equatable {
  /// Unique identifier for the conversation
  final String id;

  /// Title of the conversation
  final String title;

  /// List of messages in the conversation
  final List<Message> messages;

  /// When the conversation was created
  final DateTime createdAt;

  /// When the conversation was last updated
  final DateTime updatedAt;

  /// Source language for the conversation
  final String sourceLanguage;

  /// Target language for the conversation
  final String targetLanguage;

  /// Whether the conversation is archived
  final bool isArchived;

  /// Whether the conversation is pinned
  final bool isPinned;

  /// Participant information (if any)
  final String? participantName;

  /// Conversation category/tag
  final String? category;

  const Conversation({
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

  /// Create a copy of this conversation with updated values
  Conversation copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isArchived,
    bool? isPinned,
    String? participantName,
    String? category,
  }) {
    return Conversation(
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

  /// Get the last message in the conversation
  Message? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get message count
  int get messageCount => messages.length;

  /// Check if conversation has unread messages
  bool get hasUnreadMessages {
    return messages.any((message) => !message.isRead);
  }

  /// Get unread message count
  int get unreadMessageCount {
    return messages.where((message) => !message.isRead).length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        messages,
        createdAt,
        updatedAt,
        sourceLanguage,
        targetLanguage,
        isArchived,
        isPinned,
        participantName,
        category,
      ];

  @override
  String toString() =>
      'Conversation(id: $id, title: $title, messageCount: $messageCount)';
}
