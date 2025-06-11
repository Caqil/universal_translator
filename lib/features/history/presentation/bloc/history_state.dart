import 'package:equatable/equatable.dart';
import '../../domain/entities/history_item.dart';

/// Base class for all history states
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Loading state
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Loaded state
class HistoryLoaded extends HistoryState {
  final List<HistoryItem> items;
  final bool isSearching;
  final String? searchQuery;
  final bool hasMore;

  const HistoryLoaded({
    required this.items,
    this.isSearching = false,
    this.searchQuery,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [items, isSearching, searchQuery, hasMore];

  HistoryLoaded copyWith({
    List<HistoryItem>? items,
    bool? isSearching,
    String? searchQuery,
    bool? hasMore,
  }) {
    return HistoryLoaded(
      items: items ?? this.items,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Grouped history loaded state
class HistoryGroupedLoaded extends HistoryState {
  final Map<String, List<HistoryItem>> groupedItems;
  final bool isSearching;
  final String? searchQuery;

  const HistoryGroupedLoaded({
    required this.groupedItems,
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [groupedItems, isSearching, searchQuery];
}

/// Favorite history loaded state
class FavoriteHistoryLoaded extends HistoryState {
  final List<HistoryItem> favoriteItems;

  const FavoriteHistoryLoaded(this.favoriteItems);

  @override
  List<Object?> get props => [favoriteItems];
}

/// Empty state
class HistoryEmpty extends HistoryState {
  final bool isSearching;
  final String? searchQuery;

  const HistoryEmpty({
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [isSearching, searchQuery];
}

/// Error state
class HistoryError extends HistoryState {
  final String message;
  final String? code;

  const HistoryError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Item deleted state
class HistoryItemDeleted extends HistoryState {
  final String deletedItemId;
  final List<HistoryItem> remainingItems;

  const HistoryItemDeleted({
    required this.deletedItemId,
    required this.remainingItems,
  });

  @override
  List<Object?> get props => [deletedItemId, remainingItems];
}

/// History cleared state
class HistoryCleared extends HistoryState {
  const HistoryCleared();
}

/// Export success state
class HistoryExported extends HistoryState {
  final Map<String, dynamic> exportData;

  const HistoryExported(this.exportData);

  @override
  List<Object?> get props => [exportData];
}

/// Import success state
class HistoryImported extends HistoryState {
  final int importedCount;

  const HistoryImported(this.importedCount);

  @override
  List<Object?> get props => [importedCount];
}

/// Item saved to history
class HistoryItemSaved extends HistoryState {
  final HistoryItem savedItem;

  const HistoryItemSaved(this.savedItem);

  @override
  List<Object?> get props => [savedItem];
}

/// Favorite toggled state
class HistoryFavoriteToggled extends HistoryState {
  final HistoryItem updatedItem;

  const HistoryFavoriteToggled(this.updatedItem);

  @override
  List<Object?> get props => [updatedItem];
}
