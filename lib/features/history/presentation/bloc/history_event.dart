import 'package:equatable/equatable.dart';
import '../../domain/entities/history_item.dart';

/// Base class for all history events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load history
class LoadHistoryEvent extends HistoryEvent {
  final int? limit;
  final int? offset;
  final bool refresh;

  const LoadHistoryEvent({
    this.limit,
    this.offset,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [limit, offset, refresh];
}

/// Event to search history
class SearchHistoryEvent extends HistoryEvent {
  final String query;

  const SearchHistoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear search
class ClearSearchEvent extends HistoryEvent {
  const ClearSearchEvent();
}

/// Event to save item to history
class SaveToHistoryEvent extends HistoryEvent {
  final HistoryItem item;

  const SaveToHistoryEvent(this.item);

  @override
  List<Object?> get props => [item];
}

/// Event to delete history item
class DeleteHistoryItemEvent extends HistoryEvent {
  final String id;

  const DeleteHistoryItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to clear all history
class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}

/// Event to toggle favorite status
class ToggleFavoriteEvent extends HistoryEvent {
  final String id;

  const ToggleFavoriteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to load favorite history
class LoadFavoriteHistoryEvent extends HistoryEvent {
  const LoadFavoriteHistoryEvent();
}

/// Event to export history
class ExportHistoryEvent extends HistoryEvent {
  const ExportHistoryEvent();
}

/// Event to import history
class ImportHistoryEvent extends HistoryEvent {
  final Map<String, dynamic> data;

  const ImportHistoryEvent(this.data);

  @override
  List<Object?> get props => [data];
}

/// Event to load grouped history
class LoadGroupedHistoryEvent extends HistoryEvent {
  const LoadGroupedHistoryEvent();
}

/// Event to refresh history
class RefreshHistoryEvent extends HistoryEvent {
  const RefreshHistoryEvent();
}
