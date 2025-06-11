// lib/features/conversation/data/datasources/conversation_local_datasource.dart
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Abstract class for conversation local data source
abstract class ConversationLocalDataSource {
  /// Get all conversations from local storage
  Future<List<ConversationModel>> getConversations({
    int? limit,
    int? offset,
    bool includeArchived = false,
  });

  /// Get a specific conversation by ID
  Future<ConversationModel?> getConversationById(String id);

  /// Save a conversation to local storage
  Future<void> saveConversation(ConversationModel conversation);

  /// Delete a conversation from local storage
  Future<void> deleteConversation(String conversationId);

  /// Add a message to a conversation
  Future<void> addMessage(String conversationId, MessageModel message);

  /// Update a message
  Future<void> updateMessage(MessageModel message);

  /// Get a message by ID
  Future<MessageModel?> getMessageById(String messageId);

  /// Delete a message
  Future<void> deleteMessage(String messageId);

  /// Mark all messages in a conversation as read
  Future<void> markConversationAsRead(String conversationId);

  /// Search conversations by query
  Future<List<ConversationModel>> searchConversations(String query);

  /// Search messages by query
  Future<List<MessageModel>> searchMessages(
    String query, {
    String? conversationId,
  });

  /// Get recent conversations sorted by last message timestamp
  Future<List<ConversationModel>> getRecentConversations({
    int limit = 10,
  });

  /// Get conversation statistics
  Future<Map<String, int>> getConversationStats();

  /// Export conversation as formatted text
  Future<String> exportConversation(
    String conversationId, {
    bool includeTranslations = true,
    bool includeTimestamps = true,
  });

  /// Clear all conversations
  Future<void> clearAllConversations();

  /// Get conversations by language pair
  Future<List<ConversationModel>> getConversationsByLanguages({
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Get favorite messages
  Future<List<MessageModel>> getFavoriteMessages({
    int? limit,
    int? offset,
  });

  /// Backup conversations to JSON string
  Future<String> backupConversations();

  /// Restore conversations from JSON string
  Future<void> restoreConversations(String backupData);
}
