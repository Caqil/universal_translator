// lib/features/conversation/domain/usecases/add_message.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/conversation_repository.dart';

@injectable
class AddMessageParams extends Equatable {
  final String conversationId;
  final String originalText;
  final String originalLanguage;
  final MessageType type;
  final MessageSender sender;
  final String? translatedText;
  final String? translatedLanguage;
  final String? voiceFilePath;
  final int? voiceDuration;

  const AddMessageParams({
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

/// Use case for adding a message to a conversation
@injectable
class AddMessage implements UseCase<Message, AddMessageParams> {
  final ConversationRepository _repository;

  AddMessage(this._repository);

  @override
  Future<Either<Failure, Message>> call(AddMessageParams params) async {
    // Validate parameters
    if (params.conversationId.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Conversation ID cannot be empty',
        code: 'INVALID_CONVERSATION_ID',
      ));
    }

    if (params.originalText.trim().isEmpty &&
        params.type != MessageType.voice) {
      return Left(ValidationFailure(
        message: 'Message text cannot be empty',
        code: 'INVALID_MESSAGE_TEXT',
      ));
    }

    if (params.originalLanguage.trim().isEmpty) {
      return Left(ValidationFailure(
        message: 'Original language cannot be empty',
        code: 'INVALID_ORIGINAL_LANGUAGE',
      ));
    }

    // Validate voice message specific parameters
    if (params.type == MessageType.voice) {
      if (params.voiceFilePath == null ||
          params.voiceFilePath!.trim().isEmpty) {
        return Left(ValidationFailure(
          message: 'Voice file path is required for voice messages',
          code: 'INVALID_VOICE_FILE_PATH',
        ));
      }

      if (params.voiceDuration == null || params.voiceDuration! <= 0) {
        return Left(ValidationFailure(
          message: 'Valid voice duration is required for voice messages',
          code: 'INVALID_VOICE_DURATION',
        ));
      }
    }

    // Validate translation parameters
    if (params.translatedText != null && params.translatedText!.isNotEmpty) {
      if (params.translatedLanguage == null ||
          params.translatedLanguage!.trim().isEmpty) {
        return Left(ValidationFailure(
          message:
              'Translated language is required when translation is provided',
          code: 'INVALID_TRANSLATED_LANGUAGE',
        ));
      }

      if (params.originalLanguage == params.translatedLanguage) {
        return Left(ValidationFailure(
          message: 'Original and translated languages cannot be the same',
          code: 'SAME_LANGUAGES',
        ));
      }
    }

    return await _repository.addMessage(
      conversationId: params.conversationId.trim(),
      originalText: params.originalText.trim(),
      originalLanguage: params.originalLanguage,
      type: params.type,
      sender: params.sender,
      translatedText: params.translatedText?.trim(),
      translatedLanguage: params.translatedLanguage,
      voiceFilePath: params.voiceFilePath?.trim(),
      voiceDuration: params.voiceDuration,
    );
  }
}

/// Validation failure for message operations
class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
    required String code,
  }) : super(message: message, code: code);
}
