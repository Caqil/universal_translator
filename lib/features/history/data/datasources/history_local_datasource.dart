import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/history_item_model.dart';

/// Abstract interface for history local data source
abstract class HistoryLocalDataSource {
  /// Get all history items
  Future<List<HistoryItemModel>> getHistory({int? limit, int? offset});

  /// Search history items
  Future<List<HistoryItemModel>> searchHistory(String query);

  /// Save item to history
  Future<void> saveToHistory(HistoryItemModel item);

  /// Delete specific history item
  Future<void> deleteHistoryItem(String id);

  /// Clear all history
  Future<void> clearHistory();

  /// Get favorite history items
  Future<List<HistoryItemModel>> getFavoriteHistory();

  /// Toggle favorite status
  Future<HistoryItemModel?> toggleFavorite(String id);

  /// Export history as JSON
  Future<Map<String, dynamic>> exportHistory();

  /// Import history from JSON
  Future<void> importHistory(Map<String, dynamic> data);

  /// Get history grouped by date
  Future<Map<String, List<HistoryItemModel>>> getGroupedHistory();
}

/// Implementation of history local data source using Hive
@LazySingleton(as: HistoryLocalDataSource)
class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Box<HistoryItemModel> _historyBox;

  HistoryLocalDataSourceImpl(
    @Named('historyBox') this._historyBox,
  );

  @override
  Future<List<HistoryItemModel>> getHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final items = _historyBox.values.toList();

      // Sort by timestamp (newest first)
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      final startIndex = offset ?? 0;
      final endIndex = limit != null
          ? (startIndex + limit).clamp(0, items.length)
          : items.length;

      if (startIndex >= items.length) {
        return [];
      }

      return items.sublist(startIndex, endIndex);
    } catch (e) {
      throw CacheException.readError('Failed to get history: $e');
    }
  }

  @override
  Future<List<HistoryItemModel>> searchHistory(String query) async {
    try {
      final items = _historyBox.values.toList();
      final queryLower = query.toLowerCase();

      final filteredItems = items.where((item) {
        return item.sourceText.toLowerCase().contains(queryLower) ||
            item.translatedText.toLowerCase().contains(queryLower);
      }).toList();

      // Sort by timestamp (newest first)
      filteredItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return filteredItems;
    } catch (e) {
      throw CacheException.readError('Failed to search history: $e');
    }
  }

  @override
  Future<void> saveToHistory(HistoryItemModel item) async {
    try {
      await _historyBox.put(item.id, item);
      await _maintainSizeLimit();
    } catch (e) {
      throw CacheException.writeError('Failed to save to history: $e');
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    try {
      await _historyBox.delete(id);
    } catch (e) {
      throw CacheException.deleteError('Failed to delete history item: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _historyBox.clear();
    } catch (e) {
      throw CacheException.deleteError('Failed to clear history: $e');
    }
  }

  @override
  Future<List<HistoryItemModel>> getFavoriteHistory() async {
    try {
      final items =
          _historyBox.values.where((item) => item.isFavorite).toList();

      // Sort by timestamp (newest first)
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return items;
    } catch (e) {
      throw CacheException.readError('Failed to get favorite history: $e');
    }
  }

  @override
  Future<HistoryItemModel?> toggleFavorite(String id) async {
    try {
      final item = _historyBox.get(id);
      if (item == null) return null;

      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await _historyBox.put(id, updatedItem);

      return updatedItem;
    } catch (e) {
      throw CacheException.writeError('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportHistory() async {
    try {
      final items = _historyBox.values.toList();
      final historyData = items.map((item) => item.toJson()).toList();

      return {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'count': items.length,
        'history': historyData,
      };
    } catch (e) {
      throw CacheException.readError('Failed to export history: $e');
    }
  }

  @override
  Future<void> importHistory(Map<String, dynamic> data) async {
    try {
      final historyData = data['history'] as List<dynamic>;

      for (final itemData in historyData) {
        final item = HistoryItemModel.fromJson(
          Map<String, dynamic>.from(itemData),
        );
        await _historyBox.put(item.id, item);
      }

      await _maintainSizeLimit();
    } catch (e) {
      throw CacheException.writeError('Failed to import history: $e');
    }
  }

  @override
  Future<Map<String, List<HistoryItemModel>>> getGroupedHistory() async {
    try {
      final items = await getHistory();
      final groupedItems = <String, List<HistoryItemModel>>{};

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final thisWeek = today.subtract(Duration(days: now.weekday - 1));
      final thisMonth = DateTime(now.year, now.month);

      for (final item in items) {
        final itemDate = DateTime(
          item.timestamp.year,
          item.timestamp.month,
          item.timestamp.day,
        );

        String groupKey;
        if (itemDate.isAtSameMomentAs(today)) {
          groupKey = 'Today';
        } else if (itemDate.isAtSameMomentAs(yesterday)) {
          groupKey = 'Yesterday';
        } else if (itemDate.isAfter(thisWeek) ||
            itemDate.isAtSameMomentAs(thisWeek)) {
          groupKey = 'This Week';
        } else if (itemDate.isAfter(thisMonth) ||
            itemDate.isAtSameMomentAs(thisMonth)) {
          groupKey = 'This Month';
        } else {
          groupKey = 'Older';
        }

        groupedItems.putIfAbsent(groupKey, () => []);
        groupedItems[groupKey]!.add(item);
      }

      return groupedItems;
    } catch (e) {
      throw CacheException.readError('Failed to get grouped history: $e');
    }
  }

  /// Maintain history size limit
  Future<void> _maintainSizeLimit() async {
    try {
      const maxHistoryItems = 1000;

      if (_historyBox.length > maxHistoryItems) {
        final items = _historyBox.values.toList();
        items.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final toRemove = items.length - maxHistoryItems;
        for (int i = 0; i < toRemove; i++) {
          await _historyBox.delete(items[i].id);
        }
      }
    } catch (e) {
      print('Warning: Failed to maintain history size limit: $e');
    }
  }
}
