// lib/features/conversation/presentation/bloc/conversation_event.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

/// Base class for all conversation events
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all conversations
class LoadConversationsEvent extends ConversationEvent {
  final bool includeArchived;
  final bool forceRefresh;

  const LoadConversationsEvent({
    this.includeArchived = false,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [includeArchived, forceRefresh];
}

/// Event to load a specific conversation
class LoadConversationEvent extends ConversationEvent {
  final String conversationId;

  const LoadConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to start a new conversation
class StartConversationEvent extends ConversationEvent {
  final String title;
  final String sourceLanguage;
  final String targetLanguage;
  final String? participantName;
  final String? category;

  const StartConversationEvent({
    required this.title,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.participantName,
    this.category,
  });

  @override
  List<Object?> get props => [
        title,
        sourceLanguage,
        targetLanguage,
        participantName,
        category,
      ];
}

/// Event to update conversation details
class UpdateConversationEvent extends ConversationEvent {
  final String conversationId;
  final Conversation conversation;

  const UpdateConversationEvent({
    required this.conversationId,
    required this.conversation,
  });

  @override
  List<Object?> get props => [conversationId, conversation];
}

/// Event to delete a conversation
class DeleteConversationEvent extends ConversationEvent {
  final String conversationId;

  const DeleteConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to archive/unarchive a conversation
class ToggleArchiveConversationEvent extends ConversationEvent {
  final String conversationId;

  const ToggleArchiveConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to pin/unpin a conversation
class TogglePinConversationEvent extends ConversationEvent {
  final String conversationId;

  const TogglePinConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to add a message to a conversation
class AddMessageEvent extends ConversationEvent {
  final String conversationId;
  final String originalText;
  final String originalLanguage;
  final MessageType type;
  final MessageSender sender;
  final String? translatedText;
  final String? translatedLanguage;
  final String? voiceFilePath;
  final int? voiceDuration;

  const AddMessageEvent({
    required this.conversationId,
    required this.originalText,
    required this.originalLanguage,
    required this.type,
    required this.sender,
    this.translatedText,
    this.translatedLanguage,
    this.voiceFilePath,
    this.voiceDuration,
  });

  @override
  List<Object?> get props => [
        conversationId,
        originalText,
        originalLanguage,
        type,
        sender,
        translatedText,
        translatedLanguage,
        voiceFilePath,
        voiceDuration,
      ];
}

/// Event to translate a message
class TranslateMessageEvent extends ConversationEvent {
  final String messageId;
  final String targetLanguage;

  const TranslateMessageEvent({
    required this.messageId,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [messageId, targetLanguage];
}

/// Event to update a message
class UpdateMessageEvent extends ConversationEvent {
  final String messageId;
  final Message message;

  const UpdateMessageEvent({
    required this.messageId,
    required this.message,
  });

  @override
  List<Object?> get props => [messageId, message];
}

/// Event to delete a message
class DeleteMessageEvent extends ConversationEvent {
  final String messageId;

  const DeleteMessageEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Event to mark message as read
class MarkMessageAsReadEvent extends ConversationEvent {
  final String messageId;

  const MarkMessageAsReadEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Event to mark conversation as read
class MarkConversationAsReadEvent extends ConversationEvent {
  final String conversationId;

  const MarkConversationAsReadEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to toggle message favorite status
class ToggleMessageFavoriteEvent extends ConversationEvent {
  final String messageId;

  const ToggleMessageFavoriteEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Event to search conversations
class SearchConversationsEvent extends ConversationEvent {
  final String query;

  const SearchConversationsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to search messages
class SearchMessagesEvent extends ConversationEvent {
  final String query;
  final String? conversationId;

  const SearchMessagesEvent({
    required this.query,
    this.conversationId,
  });

  @override
  List<Object?> get props => [query, conversationId];
}

/// Event to clear search results
class ClearSearchEvent extends ConversationEvent {
  const ClearSearchEvent();
}

/// Event to load recent conversations
class LoadRecentConversationsEvent extends ConversationEvent {
  final int limit;

  const LoadRecentConversationsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Event to export conversation
class ExportConversationEvent extends ConversationEvent {
  final String conversationId;
  final bool includeTranslations;
  final bool includeTimestamps;

  const ExportConversationEvent({
    required this.conversationId,
    this.includeTranslations = true,
    this.includeTimestamps = true,
  });

  @override
  List<Object?> get props => [
        conversationId,
        includeTranslations,
        includeTimestamps,
      ];
}

/// Event to select/deselect conversation
class SelectConversationEvent extends ConversationEvent {
  final String? conversationId;

  const SelectConversationEvent(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Event to set conversation languages
class SetConversationLanguagesEvent extends ConversationEvent {
  final String sourceLanguage;
  final String targetLanguage;

  const SetConversationLanguagesEvent({
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [sourceLanguage, targetLanguage];
}

/// Event to swap conversation languages
class SwapConversationLanguagesEvent extends ConversationEvent {
  const SwapConversationLanguagesEvent();
}
