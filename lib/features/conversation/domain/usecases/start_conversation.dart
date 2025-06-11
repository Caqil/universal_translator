// lib/features/conversation/domain/usecases/start_conversation.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

@injectable
class StartConversationParams extends Equatable {
  final String title;
  final String sourceLanguage;
  final String targetLanguage;
  final String? participantName;
  final String? category;

  const StartConversationParams({
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

/// Use case for starting a new conversation
@injectable
class StartConversation
    implements UseCase<Conversation, StartConversationParams> {
  final ConversationRepository _repository;

  StartConversation(this._repository);

  @override
  Future<Either<Failure, Conversation>> call(
      StartConversationParams params) async {
    // Validate parameters
    if (params.title.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Conversation title cannot be empty',
        code: 'INVALID_TITLE',
      ));
    }

    if (params.sourceLanguage.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Source language cannot be empty',
        code: 'INVALID_SOURCE_LANGUAGE',
      ));
    }

    if (params.targetLanguage.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Target language cannot be empty',
        code: 'INVALID_TARGET_LANGUAGE',
      ));
    }

    if (params.sourceLanguage == params.targetLanguage) {
      return Left(ValidationFailure(
        message: 'Source and target languages cannot be the same',
        code: 'SAME_LANGUAGES',
      ));
    }

    return await _repository.createConversation(
      title: params.title.trim(),
      sourceLanguage: params.sourceLanguage,
      targetLanguage: params.targetLanguage,
      participantName: params.participantName?.trim(),
      category: params.category?.trim(),
    );
  }
}

/// Validation failure for conversation operations
class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
    required String code,
  }) : super(message: message, code: code);
}
