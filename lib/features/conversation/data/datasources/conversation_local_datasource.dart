// lib/features/conversation/data/datasources/conversation_local_datasource.dart
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_session_model.dart';
import '../models/conversation_message_model.dart';

abstract class ConversationLocalDataSource {
  Future<void> saveConversation(ConversationSessionModel session);
  Future<ConversationSessionModel?> getConversation(String id);
  Future<List<ConversationSessionModel>> getAllConversations();
  Future<void> deleteConversation(String id);
  Future<List<ConversationSessionModel>> searchConversations(String query);
  Future<List<ConversationSessionModel>> getFavoriteConversations();
  Future<void> clearAllConversations();
}

@LazySingleton(as: ConversationLocalDataSource)
class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final Box<ConversationSessionModel> _conversationsBox;

  ConversationLocalDataSourceImpl(
    @Named('conversationsBox') this._conversationsBox,
  );

  @override
  Future<void> saveConversation(ConversationSessionModel session) async {
    try {
      await _conversationsBox.put(session.id, session);
    } catch (e) {
      throw CacheException.writeError('Failed to save conversation: $e');
    }
  }

  @override
  Future<ConversationSessionModel?> getConversation(String id) async {
    try {
      return _conversationsBox.get(id);
    } catch (e) {
      throw CacheException.readError('Failed to get conversation: $e');
    }
  }

  @override
  Future<List<ConversationSessionModel>> getAllConversations() async {
    try {
      final conversations = _conversationsBox.values.toList();
      // Sort by start time (newest first)
      conversations.sort((a, b) => b.startTime.compareTo(a.startTime));
      return conversations;
    } catch (e) {
      throw CacheException.readError('Failed to get all conversations: $e');
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    try {
      await _conversationsBox.delete(id);
    } catch (e) {
      throw CacheException.deleteError('Failed to delete conversation: $e');
    }
  }

  @override
  Future<List<ConversationSessionModel>> searchConversations(
      String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      final allConversations = await getAllConversations();

      return allConversations.where((conversation) {
        // Search in title, language names, and message content
        final titleMatch =
            conversation.title?.toLowerCase().contains(lowercaseQuery) ?? false;
        final languageMatch = conversation.user1LanguageName
                .toLowerCase()
                .contains(lowercaseQuery) ||
            conversation.user2LanguageName
                .toLowerCase()
                .contains(lowercaseQuery);
        final messageMatch = conversation.messages.any((message) =>
            message.originalText.toLowerCase().contains(lowercaseQuery) ||
            message.translatedText.toLowerCase().contains(lowercaseQuery));

        return titleMatch || languageMatch || messageMatch;
      }).toList();
    } catch (e) {
      throw CacheException.readError('Failed to search conversations: $e');
    }
  }

  @override
  Future<List<ConversationSessionModel>> getFavoriteConversations() async {
    try {
      final allConversations = await getAllConversations();
      return allConversations
          .where((conversation) => conversation.isFavorite)
          .toList();
    } catch (e) {
      throw CacheException.readError(
          'Failed to get favorite conversations: $e');
    }
  }

  @override
  Future<void> clearAllConversations() async {
    try {
      await _conversationsBox.clear();
    } catch (e) {
      throw CacheException.deleteError('Failed to clear conversations: $e');
    }
  }
}
