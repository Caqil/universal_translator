// lib/features/conversation/data/repositories/conversation_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Implementation of conversation repository
@LazySingleton(as: ConversationRepository)
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource _localDataSource;
  final Uuid _uuid;

  ConversationRepositoryImpl(
    this._localDataSource,
    this._uuid,
  );

  @override
  Future<Either<Failure, List<Conversation>>> getConversations({
    int? limit,
    int? offset,
    bool includeArchived = false,
  }) async {
    try {
      final conversations = await _localDataSource.getConversations(
        limit: limit,
        offset: offset,
        includeArchived: includeArchived,
      );
      return Right(conversations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Conversation?>> getConversationById(String id) async {
    try {
      final conversation = await _localDataSource.getConversationById(id);
      return Right(conversation?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String title,
    required String sourceLanguage,
    required String targetLanguage,
    String? participantName,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      final conversation = ConversationModel(
        id: _uuid.v4(),
        title: title,
        messages: [],
        createdAt: now,
        updatedAt: now,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        participantName: participantName,
        category: category,
      );

      await _localDataSource.saveConversation(conversation);
      return Right(conversation.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while creating conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation(
    String conversationId,
    Conversation conversation,
  ) async {
    try {
      final model = ConversationModel.fromEntity(
        conversation.copyWith(updatedAt: DateTime.now()),
      );
      await _localDataSource.saveConversation(model);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while updating conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
      String conversationId) async {
    try {
      await _localDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while deleting conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Conversation>> toggleArchiveConversation(
    String conversationId,
  ) async {
    try {
      final conversation =
          await _localDataSource.getConversationById(conversationId);
      if (conversation == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedConversation = conversation.copyWith(
        isArchived: !conversation.isArchived,
        updatedAt: DateTime.now(),
      );

      await _localDataSource.saveConversation(updatedConversation);
      return Right(updatedConversation.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while archiving conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Conversation>> togglePinConversation(
    String conversationId,
  ) async {
    try {
      final conversation =
          await _localDataSource.getConversationById(conversationId);
      if (conversation == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedConversation = conversation.copyWith(
        isPinned: !conversation.isPinned,
        updatedAt: DateTime.now(),
      );

      await _localDataSource.saveConversation(updatedConversation);
      return Right(updatedConversation.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while pinning conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
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
  }) async {
    try {
      final conversation =
          await _localDataSource.getConversationById(conversationId);
      if (conversation == null) {
        return Left(CacheFailure.notFound());
      }

      final message = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        type: MessageModel.messageTypeToAdapter(type),
        sender: MessageModel.messageSenderToAdapter(sender),
        originalText: originalText,
        translatedText: translatedText,
        originalLanguage: originalLanguage,
        translatedLanguage: translatedLanguage,
        timestamp: DateTime.now(),
        voiceFilePath: voiceFilePath,
        voiceDuration: voiceDuration,
      );

      await _localDataSource.addMessage(conversationId, message);

      // Update conversation's last updated time
      final updatedConversation = conversation.copyWith(
        updatedAt: DateTime.now(),
      );
      await _localDataSource.saveConversation(updatedConversation);

      return Right(message.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while adding message',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Message>> updateMessage(
    String messageId,
    Message message,
  ) async {
    try {
      final model = MessageModel.fromEntity(message);
      await _localDataSource.updateMessage(model);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while updating message',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _localDataSource.deleteMessage(messageId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while deleting message',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Message>> translateMessage({
    required String messageId,
    required String targetLanguage,
  }) async {
    try {
      // This would typically call a translation service
      // For now, we'll just mark the message as translating
      final message = await _localDataSource.getMessageById(messageId);
      if (message == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedMessage = message.copyWith(
        isTranslating: true,
        translatedLanguage: targetLanguage,
      );

      await _localDataSource.updateMessage(updatedMessage);
      return Right(updatedMessage.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while translating message',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Message>> markMessageAsRead(String messageId) async {
    try {
      final message = await _localDataSource.getMessageById(messageId);
      if (message == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedMessage = message.copyWith(isRead: true);
      await _localDataSource.updateMessage(updatedMessage);
      return Right(updatedMessage.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while marking message as read',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markConversationAsRead(
      String conversationId) async {
    try {
      await _localDataSource.markConversationAsRead(conversationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while marking conversation as read',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Message>> toggleMessageFavorite(
      String messageId) async {
    try {
      final message = await _localDataSource.getMessageById(messageId);
      if (message == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedMessage = message.copyWith(
        isFavorite: !message.isFavorite,
      );

      await _localDataSource.updateMessage(updatedMessage);
      return Right(updatedMessage.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while toggling message favorite',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> searchConversations(
    String query,
  ) async {
    try {
      final conversations = await _localDataSource.searchConversations(query);
      return Right(conversations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while searching conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> searchMessages(
    String query, {
    String? conversationId,
  }) async {
    try {
      final messages = await _localDataSource.searchMessages(
        query,
        conversationId: conversationId,
      );
      return Right(messages.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while searching messages',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getRecentConversations({
    int limit = 10,
  }) async {
    try {
      final conversations =
          await _localDataSource.getRecentConversations(limit: limit);
      return Right(conversations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting recent conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getConversationStats() async {
    try {
      final stats = await _localDataSource.getConversationStats();
      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting conversation stats',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> exportConversation(
    String conversationId, {
    bool includeTranslations = true,
    bool includeTimestamps = true,
  }) async {
    try {
      final exportData = await _localDataSource.exportConversation(
        conversationId,
        includeTranslations: includeTranslations,
        includeTimestamps: includeTimestamps,
      );
      return Right(exportData);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while exporting conversation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllConversations() async {
    try {
      await _localDataSource.clearAllConversations();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while clearing conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversationsByLanguages({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final conversations = await _localDataSource.getConversationsByLanguages(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      return Right(conversations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message:
            'Unexpected error occurred while getting conversations by languages',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getFavoriteMessages({
    int? limit,
    int? offset,
  }) async {
    try {
      final messages = await _localDataSource.getFavoriteMessages(
        limit: limit,
        offset: offset,
      );
      return Right(messages.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting favorite messages',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> backupConversations() async {
    try {
      final backupData = await _localDataSource.backupConversations();
      return Right(backupData);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while backing up conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> restoreConversations(String backupData) async {
    try {
      await _localDataSource.restoreConversations(backupData);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while restoring conversations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }
}
