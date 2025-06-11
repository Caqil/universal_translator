import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

/// Use case for saving item to history
@injectable
class SaveToHistory implements UseCase<void, HistoryItem> {
  final HistoryRepository repository;

  SaveToHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(HistoryItem params) {
    return repository.saveToHistory(params);
  }
}
