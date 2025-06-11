import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Use case for deleting a history item
@injectable
class DeleteHistoryItem implements UseCase<void, String> {
  final HistoryRepository repository;

  DeleteHistoryItem(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteHistoryItem(params);
  }
}
