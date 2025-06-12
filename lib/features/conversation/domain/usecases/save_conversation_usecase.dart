// lib/features/conversation/domain/usecases/save_conversation_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation_session.dart';
import '../repositories/conversation_repository.dart';

@injectable
class SaveConversationUsecase implements UseCase<void, ConversationSession> {
  final ConversationRepository _repository;

  SaveConversationUsecase(this._repository);

  @override
  Future<Either<Failure, void>> call(ConversationSession session) async {
    return await _repository.saveConversation(session);
  }
}
