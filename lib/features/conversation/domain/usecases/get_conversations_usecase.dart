// lib/features/conversation/domain/usecases/get_conversations_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation_session.dart';
import '../repositories/conversation_repository.dart';

@injectable
class GetConversationsUsecase
    implements UseCase<List<ConversationSession>, NoParams> {
  final ConversationRepository _repository;

  GetConversationsUsecase(this._repository);

  @override
  Future<Either<Failure, List<ConversationSession>>> call(
      NoParams params) async {
    return await _repository.getAllConversations();
  }
}
