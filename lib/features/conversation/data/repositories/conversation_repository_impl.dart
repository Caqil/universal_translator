// lib/features/conversation/data/repositories/conversation_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation_session.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';
import '../models/conversation_session_model.dart';
import '../models/conversation_message_model.dart';

@LazySingleton(as: ConversationRepository)
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource _localDataSource;
  final Uuid _uuid;

  ConversationRepositoryImpl(this._localDataSource, this._uuid);

  @override
  Future<Either<Failure, ConversationSession>> startConversation({
    required String user1Language,
    required String user2Language,
    required String user1LanguageName,
    required String user2LanguageName,
  }) async {
    try {
      final session = ConversationSession(
        id: _uuid.v4(),
        user1Language: user1Language,
        user2Language: user2Language,
        user1LanguageName: user1LanguageName,
        user2LanguageName: user2LanguageName,
        startTime: DateTime.now(),
      );

      final sessionModel = ConversationSessionModel.fromEntity(session);
      await _localDataSource.saveConversation(sessionModel);

      return Right(session);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to start conversation: ${e.toString()}',
        code: 'START_CONVERSATION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveConversation(
      ConversationSession session) async {
    try {
      final sessionModel = ConversationSessionModel.fromEntity(session);
      await _localDataSource.saveConversation(sessionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save conversation: ${e.toString()}',
        code: 'SAVE_CONVERSATION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, ConversationSession?>> getConversation(
      String id) async {
    try {
      final sessionModel = await _localDataSource.getConversation(id);
      return Right(sessionModel?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get conversation: ${e.toString()}',
        code: 'GET_CONVERSATION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ConversationSession>>>
      getAllConversations() async {
    try {
      final sessionModels = await _localDataSource.getAllConversations();
      final sessions = sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get conversations: ${e.toString()}',
        code: 'GET_CONVERSATIONS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String id) async {
    try {
      await _localDataSource.deleteConversation(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete conversation: ${e.toString()}',
        code: 'DELETE_CONVERSATION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> addMessage(
      String sessionId, ConversationMessage message) async {
    try {
      final sessionModel = await _localDataSource.getConversation(sessionId);
      if (sessionModel == null) {
        return Left(CacheFailure(
          message: 'Conversation not found',
          code: 'CONVERSATION_NOT_FOUND',
        ));
      }

      final messageModel = ConversationMessageModel.fromEntity(message);
      final updatedMessages =
          List<ConversationMessageModel>.from(sessionModel.messages)
            ..add(messageModel);

      final updatedSession = ConversationSessionModel(
        id: sessionModel.id,
        user1Language: sessionModel.user1Language,
        user2Language: sessionModel.user2Language,
        user1LanguageName: sessionModel.user1LanguageName,
        user2LanguageName: sessionModel.user2LanguageName,
        startTime: sessionModel.startTime,
        endTime: sessionModel.endTime,
        messages: updatedMessages,
        isFavorite: sessionModel.isFavorite,
        title: sessionModel.title,
      );

      await _localDataSource.saveConversation(updatedSession);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to add message: ${e.toString()}',
        code: 'ADD_MESSAGE_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateConversation(
      ConversationSession session) async {
    try {
      final sessionModel = ConversationSessionModel.fromEntity(session);
      await _localDataSource.saveConversation(sessionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update conversation: ${e.toString()}',
        code: 'UPDATE_CONVERSATION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ConversationSession>>> searchConversations(
      String query) async {
    try {
      final sessionModels = await _localDataSource.searchConversations(query);
      final sessions = sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to search conversations: ${e.toString()}',
        code: 'SEARCH_CONVERSATIONS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ConversationSession>>>
      getFavoriteConversations() async {
    try {
      final sessionModels = await _localDataSource.getFavoriteConversations();
      final sessions = sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessions);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get favorite conversations: ${e.toString()}',
        code: 'GET_FAVORITES_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String sessionId) async {
    try {
      final sessionModel = await _localDataSource.getConversation(sessionId);
      if (sessionModel == null) {
        return Left(CacheFailure(
          message: 'Conversation not found',
          code: 'CONVERSATION_NOT_FOUND',
        ));
      }

      final updatedSession = ConversationSessionModel(
        id: sessionModel.id,
        user1Language: sessionModel.user1Language,
        user2Language: sessionModel.user2Language,
        user1LanguageName: sessionModel.user1LanguageName,
        user2LanguageName: sessionModel.user2LanguageName,
        startTime: sessionModel.startTime,
        endTime: sessionModel.endTime,
        messages: sessionModel.messages,
        isFavorite: !sessionModel.isFavorite,
        title: sessionModel.title,
      );

      await _localDataSource.saveConversation(updatedSession);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to toggle favorite: ${e.toString()}',
        code: 'TOGGLE_FAVORITE_FAILED',
      ));
    }
  }
}
