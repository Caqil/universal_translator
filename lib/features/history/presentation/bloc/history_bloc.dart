import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/delete_history_item.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/save_to_history.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC for managing history state
@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory _getHistory;
  final SaveToHistory _saveToHistory;
  final DeleteHistoryItem _deleteHistoryItem;
  final ClearHistory _clearHistory;
  final HistoryRepository _repository;

  HistoryBloc(
    this._getHistory,
    this._saveToHistory,
    this._deleteHistoryItem,
    this._clearHistory,
    this._repository,
  ) : super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<SearchHistoryEvent>(_onSearchHistory);
    on<ClearSearchEvent>(_onClearSearch);
    on<SaveToHistoryEvent>(_onSaveToHistory);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem);
    on<ClearHistoryEvent>(_onClearHistory);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<LoadFavoriteHistoryEvent>(_onLoadFavoriteHistory);
    on<ExportHistoryEvent>(_onExportHistory);
    on<ImportHistoryEvent>(_onImportHistory);
    on<LoadGroupedHistoryEvent>(_onLoadGroupedHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
    on<LoadHistoryByDateEvent>(_onLoadHistoryByDate);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (event.refresh || state is HistoryInitial) {
      emit(const HistoryLoading());
    }

    final result = await _getHistory(GetHistoryParams(
      limit: event.limit,
      offset: event.offset,
    ));

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (items) {
        if (items.isEmpty) {
          emit(const HistoryEmpty());
        } else {
          emit(HistoryLoaded(
            items: items,
            hasMore: event.limit != null && items.length == event.limit,
          ));
        }
      },
    );
  }

  Future<void> _onSearchHistory(
    SearchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadHistoryEvent(refresh: true));
      return;
    }

    emit(const HistoryLoading());

    final result = await _repository.searchHistory(event.query);

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (items) {
        if (items.isEmpty) {
          emit(HistoryEmpty(
            isSearching: true,
            searchQuery: event.query,
          ));
        } else {
          emit(HistoryLoaded(
            items: items,
            isSearching: true,
            searchQuery: event.query,
          ));
        }
      },
    );
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<HistoryState> emit,
  ) async {
    add(const LoadHistoryEvent(refresh: true));
  }

  Future<void> _onSaveToHistory(
    SaveToHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _saveToHistory(event.item);

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (_) {
        emit(HistoryItemSaved(event.item));
        // Refresh history after saving
        add(const LoadHistoryEvent(refresh: true));
      },
    );
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItemEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _deleteHistoryItem(event.id);

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (_) {
        // Get updated list
        final currentState = state;
        if (currentState is HistoryLoaded) {
          final updatedItems =
              currentState.items.where((item) => item.id != event.id).toList();

          emit(HistoryItemDeleted(
            deletedItemId: event.id,
            remainingItems: updatedItems,
          ));

          if (updatedItems.isEmpty) {
            emit(const HistoryEmpty());
          } else {
            emit(HistoryLoaded(
              items: updatedItems,
              isSearching: currentState.isSearching,
              searchQuery: currentState.searchQuery,
            ));
          }
        } else {
          // Refresh history
          add(const LoadHistoryEvent(refresh: true));
        }
      },
    );
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _clearHistory(NoParams());

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (_) {
        emit(const HistoryCleared());
        emit(const HistoryEmpty());
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _repository.toggleFavorite(event.id);

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (updatedItem) {
        emit(HistoryFavoriteToggled(updatedItem));

        // Update current state if it's loaded
        final currentState = state;
        if (currentState is HistoryLoaded) {
          final updatedItems = currentState.items.map((item) {
            return item.id == event.id ? updatedItem : item;
          }).toList();

          emit(HistoryLoaded(
            items: updatedItems,
            isSearching: currentState.isSearching,
            searchQuery: currentState.searchQuery,
            hasMore: currentState.hasMore,
          ));
        }
      },
    );
  }

  Future<void> _onLoadFavoriteHistory(
    LoadFavoriteHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    final result = await _repository.getFavoriteHistory();

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (items) => emit(FavoriteHistoryLoaded(items)),
    );
  }

  Future<void> _onExportHistory(
    ExportHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _repository.exportHistory();

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (exportData) => emit(HistoryExported(exportData)),
    );
  }

  Future<void> _onImportHistory(
    ImportHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await _repository.importHistory(event.data);

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (_) {
        final importedCount = (event.data['history'] as List).length;
        emit(HistoryImported(importedCount));
        // Refresh history after import
        add(const LoadHistoryEvent(refresh: true));
      },
    );
  }

  Future<void> _onLoadGroupedHistory(
    LoadGroupedHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    final result = await _repository.getGroupedHistory();

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (groupedItems) {
        if (groupedItems.isEmpty) {
          emit(const HistoryEmpty());
        } else {
          emit(HistoryGroupedLoaded(groupedItems: groupedItems));
        }
      },
    );
  }

  Future<void> _onLoadHistoryByDate(
    LoadHistoryByDateEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    // Calculate the date range
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: event.days - 1));
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final result = await _repository.getHistoryByDateRange(
      startDate: startDate,
      endDate: endDate,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(HistoryError(
        message: failure.message,
        code: failure.code,
      )),
      (items) {
        if (items.isEmpty) {
          emit(const HistoryEmpty());
        } else {
          emit(HistoryLoaded(
            items: items,
            hasMore: event.limit != null && items.length == event.limit,
            isFiltered: true,
            filterDescription: _getFilterDescription(event.days),
          ));
        }
      },
    );
  }

  String _getFilterDescription(int days) {
    switch (days) {
      case 1:
        return 'Today';
      case 7:
        return 'This week';
      case 30:
        return 'This month';
      default:
        return 'Last $days days';
    }
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    add(const LoadHistoryEvent(refresh: true));
  }
}
