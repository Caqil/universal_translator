// lib/features/conversation/data/datasources/conversation_local_datasource_impl.dart
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'conversation_local_datasource.dart';

/// Implementation of conversation local data source using Hive
@LazySingleton(as: ConversationLocalDataSource)
class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';

  late Box<ConversationModel> _conversationsBox;
  late Box<MessageModel> _messagesBox;

  ConversationLocalDataSourceImpl() {
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    try {
      _conversationsBox =
          await Hive.openBox<ConversationModel>(_conversationsBoxName);
      _messagesBox = await Hive.openBox<MessageModel>(_messagesBoxName);
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize conversation storage',
        code: 'INITIALIZATION_FAILED',
      );
    }
  }

  @override
  Future<List<ConversationModel>> getConversations({
    int? limit,
    int? offset,
    bool includeArchived = false,
  }) async {
    try {
      await _ensureBoxesInitialized();

      var conversations = _conversationsBox.values.toList();

      // Filter archived conversations if not included
      if (!includeArchived) {
        conversations =
            conversations.where((conv) => !conv.isArchived).toList();
      }

      // Sort by updated date (most recent first)
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Apply pagination
      if (offset != null) {
        conversations = conversations.skip(offset).toList();
      }
      if (limit != null) {
        conversations = conversations.take(limit).toList();
      }

      return conversations;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get conversations from cache',
        code: 'GET_CONVERSATIONS_FAILED',
      );
    }
  }

  @override
  Future<ConversationModel?> getConversationById(String id) async {
    try {
      await _ensureBoxesInitialized();

      final conversation = _conversationsBox.get(id);
      if (conversation == null) return null;

      // Load associated messages
      final messages = _messagesBox.values
          .where((msg) => msg.conversationId == id)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return conversation.copyWith(messages: messages);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get conversation from cache',
        code: 'GET_CONVERSATION_FAILED',
      );
    }
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    try {
      await _ensureBoxesInitialized();
      await _conversationsBox.put(conversation.id, conversation);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save conversation to cache',
        code: 'SAVE_CONVERSATION_FAILED',
      );
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _ensureBoxesInitialized();

      // Delete all messages in the conversation first
      final messagesToDelete = _messagesBox.values
          .where((msg) => msg.conversationId == conversationId)
          .map((msg) => msg.key)
          .toList();

      for (final key in messagesToDelete) {
        await _messagesBox.delete(key);
      }

      // Delete the conversation
      await _conversationsBox.delete(conversationId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete conversation from cache',
        code: 'DELETE_CONVERSATION_FAILED',
      );
    }
  }

  @override
  Future<void> addMessage(String conversationId, MessageModel message) async {
    try {
      await _ensureBoxesInitialized();

      // Save the message
      await _messagesBox.put(message.id, message);

      // Update conversation's updated timestamp
      final conversation = _conversationsBox.get(conversationId);
      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          updatedAt: DateTime.now(),
        );
        await _conversationsBox.put(conversationId, updatedConversation);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to add message to cache',
        code: 'ADD_MESSAGE_FAILED',
      );
    }
  }

  @override
  Future<void> updateMessage(MessageModel message) async {
    try {
      await _ensureBoxesInitialized();
      await _messagesBox.put(message.id, message);
    } catch (e) {
      throw CacheException(
        message: 'Failed to update message in cache',
        code: 'UPDATE_MESSAGE_FAILED',
      );
    }
  }

  @override
  Future<MessageModel?> getMessageById(String messageId) async {
    try {
      await _ensureBoxesInitialized();
      return _messagesBox.get(messageId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get message from cache',
        code: 'GET_MESSAGE_FAILED',
      );
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _ensureBoxesInitialized();
      await _messagesBox.delete(messageId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete message from cache',
        code: 'DELETE_MESSAGE_FAILED',
      );
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _ensureBoxesInitialized();

      // Get all messages in the conversation
      final messages = _messagesBox.values
          .where((msg) => msg.conversationId == conversationId)
          .toList();

      // Update all unread messages to read
      for (final message in messages) {
        if (!message.isRead) {
          final updatedMessage = message.copyWith(isRead: true);
          await _messagesBox.put(message.id, updatedMessage);
        }
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to mark conversation as read',
        code: 'MARK_CONVERSATION_READ_FAILED',
      );
    }
  }

  @override
  Future<List<ConversationModel>> searchConversations(String query) async {
    try {
      await _ensureBoxesInitialized();

      final lowercaseQuery = query.toLowerCase();
      final conversations = _conversationsBox.values.where((conversation) {
        return conversation.title.toLowerCase().contains(lowercaseQuery) ||
            (conversation.participantName
                    ?.toLowerCase()
                    .contains(lowercaseQuery) ??
                false) ||
            (conversation.category?.toLowerCase().contains(lowercaseQuery) ??
                false);
      }).toList();

      // Sort by relevance (title matches first, then updated date)
      conversations.sort((a, b) {
        final aTitle = a.title.toLowerCase().contains(lowercaseQuery);
        final bTitle = b.title.toLowerCase().contains(lowercaseQuery);

        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;

        return b.updatedAt.compareTo(a.updatedAt);
      });

      return conversations;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search conversations',
        code: 'SEARCH_CONVERSATIONS_FAILED',
      );
    }
  }

  @override
  Future<List<MessageModel>> searchMessages(
    String query, {
    String? conversationId,
  }) async {
    try {
      await _ensureBoxesInitialized();

      final lowercaseQuery = query.toLowerCase();
      var messages = _messagesBox.values.where((message) {
        final textMatch = message.originalText
                .toLowerCase()
                .contains(lowercaseQuery) ||
            (message.translatedText?.toLowerCase().contains(lowercaseQuery) ??
                false);

        final conversationMatch =
            conversationId == null || message.conversationId == conversationId;

        return textMatch && conversationMatch;
      }).toList();

      // Sort by timestamp (most recent first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return messages;
    } catch (e) {
      throw CacheException(
        message: 'Failed to search messages',
        code: 'SEARCH_MESSAGES_FAILED',
      );
    }
  }

  @override
  Future<List<ConversationModel>> getRecentConversations({
    int limit = 10,
  }) async {
    try {
      await _ensureBoxesInitialized();

      var conversations =
          _conversationsBox.values.where((conv) => !conv.isArchived).toList();

      // Sort by updated date (most recent first)
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return conversations.take(limit).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get recent conversations',
        code: 'GET_RECENT_CONVERSATIONS_FAILED',
      );
    }
  }

  @override
  Future<Map<String, int>> getConversationStats() async {
    try {
      await _ensureBoxesInitialized();

      final conversations = _conversationsBox.values.toList();
      final messages = _messagesBox.values.toList();

      final totalConversations = conversations.length;
      final archivedConversations =
          conversations.where((c) => c.isArchived).length;
      final pinnedConversations = conversations.where((c) => c.isPinned).length;
      final totalMessages = messages.length;
      final favoriteMessages = messages.where((m) => m.isFavorite).length;
      final unreadMessages = messages.where((m) => !m.isRead).length;

      return {
        'totalConversations': totalConversations,
        'archivedConversations': archivedConversations,
        'pinnedConversations': pinnedConversations,
        'totalMessages': totalMessages,
        'favoriteMessages': favoriteMessages,
        'unreadMessages': unreadMessages,
      };
    } catch (e) {
      throw CacheException(
        message: 'Failed to get conversation statistics',
        code: 'GET_STATS_FAILED',
      );
    }
  }

  @override
  Future<String> exportConversation(
    String conversationId, {
    bool includeTranslations = true,
    bool includeTimestamps = true,
  }) async {
    try {
      await _ensureBoxesInitialized();

      final conversation = await getConversationById(conversationId);
      if (conversation == null) {
        throw CacheException(
          message: 'Conversation not found',
          code: 'CONVERSATION_NOT_FOUND',
        );
      }

      final buffer = StringBuffer();

      // Header
      buffer.writeln('=== ${conversation.title} ===');
      buffer.writeln(
          'Languages: ${conversation.sourceLanguage} → ${conversation.targetLanguage}');
      if (conversation.participantName != null) {
        buffer.writeln('Participant: ${conversation.participantName}');
      }
      buffer.writeln(
          'Created: ${DateFormat.yMMMd().add_jm().format(conversation.createdAt)}');
      buffer.writeln('Messages: ${conversation.messages.length}');
      buffer.writeln();

      // Messages
      for (final message in conversation.messages) {
        if (includeTimestamps) {
          buffer.writeln('[${DateFormat.Hm().format(message.timestamp)}]');
        }

        final sender =
            message.sender == MessageSenderAdapter.user ? 'You' : 'Participant';
        buffer.writeln('$sender: ${message.originalText}');

        if (includeTranslations && message.translatedText != null) {
          buffer.writeln('Translation: ${message.translatedText}');
        }

        buffer.writeln();
      }

      return buffer.toString();
    } catch (e) {
      throw CacheException(
        message: 'Failed to export conversation',
        code: 'EXPORT_CONVERSATION_FAILED',
      );
    }
  }

  @override
  Future<void> clearAllConversations() async {
    try {
      await _ensureBoxesInitialized();
      await _conversationsBox.clear();
      await _messagesBox.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all conversations',
        code: 'CLEAR_CONVERSATIONS_FAILED',
      );
    }
  }

  @override
  Future<List<ConversationModel>> getConversationsByLanguages({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      await _ensureBoxesInitialized();

      final conversations = _conversationsBox.values.where((conversation) {
        return (conversation.sourceLanguage == sourceLanguage &&
                conversation.targetLanguage == targetLanguage) ||
            (conversation.sourceLanguage == targetLanguage &&
                conversation.targetLanguage == sourceLanguage);
      }).toList();

      // Sort by updated date (most recent first)
      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return conversations;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get conversations by languages',
        code: 'GET_CONVERSATIONS_BY_LANGUAGES_FAILED',
      );
    }
  }

  @override
  Future<List<MessageModel>> getFavoriteMessages({
    int? limit,
    int? offset,
  }) async {
    try {
      await _ensureBoxesInitialized();

      var messages =
          _messagesBox.values.where((message) => message.isFavorite).toList();

      // Sort by timestamp (most recent first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      if (offset != null) {
        messages = messages.skip(offset).toList();
      }
      if (limit != null) {
        messages = messages.take(limit).toList();
      }

      return messages;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get favorite messages',
        code: 'GET_FAVORITE_MESSAGES_FAILED',
      );
    }
  }

  @override
  Future<String> backupConversations() async {
    try {
      await _ensureBoxesInitialized();

      final conversations = _conversationsBox.values.toList();
      final messages = _messagesBox.values.toList();

      final backup = {
        'conversations': conversations.map((c) => c.toJson()).toList(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      return jsonEncode(backup);
    } catch (e) {
      throw CacheException(
        message: 'Failed to backup conversations',
        code: 'BACKUP_CONVERSATIONS_FAILED',
      );
    }
  }

  @override
  Future<void> restoreConversations(String backupData) async {
    try {
      await _ensureBoxesInitialized();

      final backup = jsonDecode(backupData) as Map<String, dynamic>;

      // Clear existing data
      await _conversationsBox.clear();
      await _messagesBox.clear();

      // Restore conversations
      final conversationsData = backup['conversations'] as List<dynamic>;
      for (final conversationData in conversationsData) {
        final conversation = ConversationModel.fromJson(
          conversationData as Map<String, dynamic>,
        );
        await _conversationsBox.put(conversation.id, conversation);
      }

      // Restore messages
      final messagesData = backup['messages'] as List<dynamic>;
      for (final messageData in messagesData) {
        final message = MessageModel.fromJson(
          messageData as Map<String, dynamic>,
        );
        await _messagesBox.put(message.id, message);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to restore conversations',
        code: 'RESTORE_CONVERSATIONS_FAILED',
      );
    }
  }

  Future<void> _ensureBoxesInitialized() async {
    if (!Hive.isBoxOpen(_conversationsBoxName)) {
      _conversationsBox =
          await Hive.openBox<ConversationModel>(_conversationsBoxName);
    }
    if (!Hive.isBoxOpen(_messagesBoxName)) {
      _messagesBox = await Hive.openBox<MessageModel>(_messagesBoxName);
    }
  }
}
