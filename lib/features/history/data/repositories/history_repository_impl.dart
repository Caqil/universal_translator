import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/history_item_model.dart';

/// Implementation of history repository
@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource _localDataSource;

  HistoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final historyModels = await _localDataSource.getHistory(
        limit: limit,
        offset: offset,
      );
      final historyItems =
          historyModels.map((model) => model.toEntity()).toList();
      return Right(historyItems);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> searchHistory(String query) async {
    try {
      final historyModels = await _localDataSource.searchHistory(query);
      final historyItems =
          historyModels.map((model) => model.toEntity()).toList();
      return Right(historyItems);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while searching history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveToHistory(HistoryItem item) async {
    try {
      final model = HistoryItemModel.fromEntity(item);
      await _localDataSource.saveToHistory(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while saving to history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistoryItem(String id) async {
    try {
      await _localDataSource.deleteHistoryItem(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while deleting history item',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await _localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while clearing history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, HistoryItem>> toggleFavorite(String id) async {
    try {
      final model = await _localDataSource.toggleFavorite(id);
      if (model == null) {
        return Left(CacheFailure.notFound());
      }
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while toggling favorite',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> getFavoriteHistory() async {
    try {
      final historyModels = await _localDataSource.getFavoriteHistory();
      final historyItems =
          historyModels.map((model) => model.toEntity()).toList();
      return Right(historyItems);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting favorite history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportHistory() async {
    try {
      final exportData = await _localDataSource.exportHistory();
      return Right(exportData);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while exporting history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> importHistory(Map<String, dynamic> data) async {
    try {
      await _localDataSource.importHistory(data);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while importing history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final items = await _localDataSource.getHistoryByDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      return Right(items.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get history by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<HistoryItem>>>>
      getGroupedHistory() async {
    try {
      final groupedModels = await _localDataSource.getGroupedHistory();
      final groupedItems = <String, List<HistoryItem>>{};

      for (final entry in groupedModels.entries) {
        groupedItems[entry.key] =
            entry.value.map((model) => model.toEntity()).toList();
      }

      return Right(groupedItems);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting grouped history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }
}
