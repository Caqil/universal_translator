// lib/features/conversation/domain/usecases/start_conversation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation_session.dart';
import '../repositories/conversation_repository.dart';

class StartConversationParams {
  final String user1Language;
  final String user2Language;
  final String user1LanguageName;
  final String user2LanguageName;

  StartConversationParams({
    required this.user1Language,
    required this.user2Language,
    required this.user1LanguageName,
    required this.user2LanguageName,
  });
}

@injectable
class StartConversationUsecase
    implements UseCase<ConversationSession, StartConversationParams> {
  final ConversationRepository _repository;

  StartConversationUsecase(this._repository);

  @override
  Future<Either<Failure, ConversationSession>> call(
      StartConversationParams params) async {
    return await _repository.startConversation(
      user1Language: params.user1Language,
      user2Language: params.user2Language,
      user1LanguageName: params.user1LanguageName,
      user2LanguageName: params.user2LanguageName,
    );
  }
}
