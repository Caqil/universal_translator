import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

/// Use case for clearing all history
@injectable
class ClearHistory implements UseCase<void, NoParams> {
  final HistoryRepository repository;

  ClearHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.clearHistory();
  }
}
