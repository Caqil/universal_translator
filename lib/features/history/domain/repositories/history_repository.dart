import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';

/// Abstract repository for history operations
abstract class HistoryRepository {
  /// Get all history items
  Future<Either<Failure, List<HistoryItem>>> getHistory({
    int? limit,
    int? offset,
  });

  /// Search history items
  Future<Either<Failure, List<HistoryItem>>> searchHistory(String query);

  /// Save translation to history
  Future<Either<Failure, void>> saveToHistory(HistoryItem item);

  /// Delete specific history item
  Future<Either<Failure, void>> deleteHistoryItem(String id);

  /// Clear all history
  Future<Either<Failure, void>> clearHistory();

  /// Toggle favorite status of history item
  Future<Either<Failure, HistoryItem>> toggleFavorite(String id);

  /// Get favorite history items
  Future<Either<Failure, List<HistoryItem>>> getFavoriteHistory();

  /// Export history as JSON
  Future<Either<Failure, Map<String, dynamic>>> exportHistory();

  /// Import history from JSON
  Future<Either<Failure, void>> importHistory(Map<String, dynamic> data);

  Future<Either<Failure, List<HistoryItem>>> getHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    int? offset,
  });

  /// Get history grouped by date
  Future<Either<Failure, Map<String, List<HistoryItem>>>> getGroupedHistory();
}
