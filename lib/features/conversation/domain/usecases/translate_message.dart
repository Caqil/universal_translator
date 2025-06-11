// lib/features/conversation/domain/usecases/translate_message.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/conversation_repository.dart';

@injectable
class TranslateMessageParams extends Equatable {
  final String messageId;
  final String targetLanguage;

  const TranslateMessageParams({
    required this.messageId,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [messageId, targetLanguage];
}

/// Use case for translating a message in a conversation
@injectable
class TranslateMessage implements UseCase<Message, TranslateMessageParams> {
  final ConversationRepository _repository;

  TranslateMessage(this._repository);

  @override
  Future<Either<Failure, Message>> call(TranslateMessageParams params) async {
    // Validate parameters
    if (params.messageId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Message ID cannot be empty',
        code: 'INVALID_MESSAGE_ID',
      ));
    }

    if (params.targetLanguage.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Target language cannot be empty',
        code: 'INVALID_TARGET_LANGUAGE',
      ));
    }

    return await _repository.translateMessage(
      messageId: params.messageId.trim(),
      targetLanguage: params.targetLanguage,
    );
  }
}

/// Validation failure for translation operations
class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
    required String code,
  }) : super(message: message, code: code);
}
