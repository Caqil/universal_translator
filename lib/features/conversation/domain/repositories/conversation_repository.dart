// lib/features/conversation/domain/repositories/conversation_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_session.dart';
import '../entities/conversation_message.dart';

abstract class ConversationRepository {
  /// Start a new conversation session
  Future<Either<Failure, ConversationSession>> startConversation({
    required String user1Language,
    required String user2Language,
    required String user1LanguageName,
    required String user2LanguageName,
  });

  /// Save conversation session
  Future<Either<Failure, void>> saveConversation(ConversationSession session);

  /// Get conversation session by ID
  Future<Either<Failure, ConversationSession?>> getConversation(String id);

  /// Get all conversation sessions
  Future<Either<Failure, List<ConversationSession>>> getAllConversations();

  /// Delete conversation session
  Future<Either<Failure, void>> deleteConversation(String id);

  /// Add message to conversation
  Future<Either<Failure, void>> addMessage(
      String sessionId, ConversationMessage message);

  /// Update conversation session
  Future<Either<Failure, void>> updateConversation(ConversationSession session);

  /// Search conversations
  Future<Either<Failure, List<ConversationSession>>> searchConversations(
      String query);

  /// Get favorite conversations
  Future<Either<Failure, List<ConversationSession>>> getFavoriteConversations();

  /// Toggle conversation favorite status
  Future<Either<Failure, void>> toggleFavorite(String sessionId);
}
