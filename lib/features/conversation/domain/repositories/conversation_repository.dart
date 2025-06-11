// lib/features/conversation/domain/repositories/conversation_repository.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Abstract repository for conversation operations
abstract class ConversationRepository {
  /// Get all conversations
  Future<Either<Failure, List<Conversation>>> getConversations({
    int? limit,
    int? offset,
    bool includeArchived = false,
  });

  /// Get a specific conversation by ID
  Future<Either<Failure, Conversation?>> getConversationById(String id);

  /// Create a new conversation
  Future<Either<Failure, Conversation>> createConversation({
    required String title,
    required String sourceLanguage,
    required String targetLanguage,
    String? participantName,
    String? category,
  });

  /// Update conversation details
  Future<Either<Failure, Conversation>> updateConversation(
    String conversationId,
    Conversation conversation,
  );

  /// Delete a conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Archive/Unarchive a conversation
  Future<Either<Failure, Conversation>> toggleArchiveConversation(
    String conversationId,
  );

  /// Pin/Unpin a conversation
  Future<Either<Failure, Conversation>> togglePinConversation(
    String conversationId,
  );

  /// Add a message to a conversation
  Future<Either<Failure, Message>> addMessage({
    required String conversationId,
    required String originalText,
    required String originalLanguage,
    required MessageType type,
    required MessageSender sender,
    String? translatedText,
    String? translatedLanguage,
    String? voiceFilePath,
    int? voiceDuration,
  });

  /// Update a message
  Future<Either<Failure, Message>> updateMessage(
    String messageId,
    Message message,
  );

  /// Delete a message
  Future<Either<Failure, void>> deleteMessage(String messageId);

  /// Translate a message
  Future<Either<Failure, Message>> translateMessage({
    required String messageId,
    required String targetLanguage,
  });

  /// Mark message as read
  Future<Either<Failure, Message>> markMessageAsRead(String messageId);

  /// Mark all messages in conversation as read
  Future<Either<Failure, void>> markConversationAsRead(String conversationId);

  /// Toggle message favorite status
  Future<Either<Failure, Message>> toggleMessageFavorite(String messageId);

  /// Search conversations
  Future<Either<Failure, List<Conversation>>> searchConversations(
    String query,
  );

  /// Search messages within conversations
  Future<Either<Failure, List<Message>>> searchMessages(
    String query, {
    String? conversationId,
  });

  /// Get recent conversations (sorted by last message timestamp)
  Future<Either<Failure, List<Conversation>>> getRecentConversations({
    int limit = 10,
  });

  /// Get conversation statistics
  Future<Either<Failure, Map<String, int>>> getConversationStats();

  /// Export conversation as text
  Future<Either<Failure, String>> exportConversation(
    String conversationId, {
    bool includeTranslations = true,
    bool includeTimestamps = true,
  });

  /// Clear all conversations
  Future<Either<Failure, void>> clearAllConversations();

  /// Get conversations by language pair
  Future<Either<Failure, List<Conversation>>> getConversationsByLanguages({
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Get favorite messages
  Future<Either<Failure, List<Message>>> getFavoriteMessages({
    int? limit,
    int? offset,
  });

  /// Backup conversations to cloud/file
  Future<Either<Failure, String>> backupConversations();

  /// Restore conversations from backup
  Future<Either<Failure, void>> restoreConversations(String backupData);
}
