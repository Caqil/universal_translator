import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

/// Use case for getting history items
@injectable
class GetHistory implements UseCase<List<HistoryItem>, GetHistoryParams> {
  final HistoryRepository repository;

  GetHistory(this.repository);

  @override
  Future<Either<Failure, List<HistoryItem>>> call(GetHistoryParams params) {
    return repository.getHistory(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetHistoryParams extends Equatable {
  final int? limit;
  final int? offset;

  const GetHistoryParams({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}
