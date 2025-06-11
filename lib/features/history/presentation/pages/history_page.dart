import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/history_item.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_item_widget.dart';
import '../widgets/history_search.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showGrouped = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    if (_showGrouped) {
      context.read<HistoryBloc>().add(const LoadGroupedHistoryEvent());
    } else {
      context.read<HistoryBloc>().add(const LoadHistoryEvent(limit: 50));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more items when near bottom
      final state = context.read<HistoryBloc>().state;
      if (state is HistoryLoaded && state.hasMore && !state.isSearching) {
        context.read<HistoryBloc>().add(LoadHistoryEvent(
              limit: 50,
              offset: state.items.length,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'history.translation_history'.tr(),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_mode',
                child: Row(
                  children: [
                    Icon(_showGrouped ? Icons.list : Icons.group_work),
                    const SizedBox(width: 8),
                    Text(_showGrouped
                        ? 'history.list_view'.tr()
                        : 'history.grouped_view'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    const Icon(Icons.favorite),
                    const SizedBox(width: 8),
                    Text('favorites.favorite_translations'.tr()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.download),
                    const SizedBox(width: 8),
                    Text('history.export_history'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    const Icon(Icons.upload),
                    const SizedBox(width: 8),
                    Text('history.import_history'.tr()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'history.clear_history'.tr(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          HistorySearch(
            onSearch: (query) {
              context.read<HistoryBloc>().add(SearchHistoryEvent(query));
            },
            onClear: () {
              context.read<HistoryBloc>().add(const ClearSearchEvent());
            },
            isLoading: context.select<HistoryBloc, bool>(
              (bloc) => bloc.state is HistoryLoading,
            ),
          ),
          // Content
          Expanded(
            child: BlocConsumer<HistoryBloc, HistoryState>(
              listener: _handleStateChange,
              builder: (context, state) {
                return _buildContent(context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoryState state) {
    if (state is HistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HistoryError) {
      return CustomErrorWidget(
        message: state.message,
        onRetry: _loadHistory,
      );
    }

    if (state is HistoryEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: state.isSearching
            ? 'history.no_search_results'.tr()
            : 'history.history_empty'.tr(),
        subtitle: state.isSearching
            ? 'history.try_different_search'.tr()
            : 'history.start_translating'.tr(),
        action: state.isSearching
            ? CustomButton(
                text: 'app.clear'.tr(),
                onPressed: () {
                  context.read<HistoryBloc>().add(const ClearSearchEvent());
                },
              )
            : null,
      );
    }

    if (state is HistoryGroupedLoaded) {
      return _buildGroupedHistory(context, state);
    }

    if (state is HistoryLoaded) {
      return _buildListHistory(context, state);
    }

    if (state is FavoriteHistoryLoaded) {
      return _buildFavoriteHistory(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildListHistory(BuildContext context, HistoryLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const RefreshHistoryEvent());
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            // Loading indicator for pagination
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = state.items[index];
          return HistoryItemWidget(
            item: item,
            onTap: () => _handleItemTap(item),
            onFavoriteToggle: () => _toggleFavorite(item.id),
            onDelete: () => _deleteItem(item.id),
            onCopy: () => _copyItem(item),
            onShare: () => _shareItem(item),
          );
        },
      ),
    );
  }

  Widget _buildGroupedHistory(
      BuildContext context, HistoryGroupedLoaded state) {
    final groups = ['Today', 'Yesterday', 'This Week', 'This Month', 'Older'];

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const LoadGroupedHistoryEvent());
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final groupKey = groups[index];
          final items = state.groupedItems[groupKey] ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
                child: Text(
                  'history.$groupKey'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
              // Group items
              ...items.map((item) => HistoryItemWidget(
                    item: item,
                    onTap: () => _handleItemTap(item),
                    onFavoriteToggle: () => _toggleFavorite(item.id),
                    onDelete: () => _deleteItem(item.id),
                    onCopy: () => _copyItem(item),
                    onShare: () => _shareItem(item),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFavoriteHistory(
      BuildContext context, FavoriteHistoryLoaded state) {
    if (state.favoriteItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'favorites.no_favorites'.tr(),
        subtitle: 'favorites.tap_star_to_favorite'.tr(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const LoadFavoriteHistoryEvent());
      },
      child: ListView.builder(
        itemCount: state.favoriteItems.length,
        itemBuilder: (context, index) {
          final item = state.favoriteItems[index];
          return HistoryItemWidget(
            item: item,
            onTap: () => _handleItemTap(item),
            onFavoriteToggle: () => _toggleFavorite(item.id),
            onDelete: () => _deleteItem(item.id),
            onCopy: () => _copyItem(item),
            onShare: () => _shareItem(item),
          );
        },
      ),
    );
  }

  void _handleStateChange(BuildContext context, HistoryState state) {
    if (state is HistoryItemDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('history.history_item_deleted'.tr()),
          action: SnackBarAction(
            label: 'history.restore_history_item'.tr(),
            onPressed: () {
              // TODO: Implement restore functionality
            },
          ),
        ),
      );
    }

    if (state is HistoryCleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('history.history_cleared'.tr())),
      );
    }

    if (state is HistoryExported) {
      // TODO: Handle export (save to file, share, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('history.export_success'.tr())),
      );
    }

    if (state is HistoryImported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('history.import_success'.tr().replaceAll(
                '{count}',
                state.importedCount.toString(),
              )),
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'view_mode':
        setState(() {
          _showGrouped = !_showGrouped;
        });
        _loadHistory();
        break;
      case 'favorites':
        context.read<HistoryBloc>().add(const LoadFavoriteHistoryEvent());
        break;
      case 'export':
        context.read<HistoryBloc>().add(const ExportHistoryEvent());
        break;
      case 'import':
        _showImportDialog();
        break;
      case 'clear':
        _showClearConfirmationDialog();
        break;
    }
  }

  void _handleItemTap(HistoryItem item) {
    // TODO: Navigate to translation page with pre-filled data
    // Navigator.pushNamed(context, '/translation', arguments: item);
  }

  void _toggleFavorite(String id) {
    context.read<HistoryBloc>().add(ToggleFavoriteEvent(id));
  }

  void _deleteItem(String id) {
    context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id));
  }

  void _copyItem(HistoryItem item) {
    Clipboard.setData(ClipboardData(text: item.translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('app.copied'.tr())),
    );
  }

  void _shareItem(HistoryItem item) {
    Share.share(
      '${item.sourceText}\n\n→ ${item.translatedText}',
      subject: 'translation.translation'.tr(),
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text('history.clear_history'.tr()),
        description: Text('history.clear_history_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('app.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryBloc>().add(const ClearHistoryEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('app.clear'.tr()),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    // TODO: Implement file picker for importing history
    showDialog(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: Text('history.clear_history'.tr()),
        description: Text('history.clear_history_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('app.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Pick file and import
            },
            child: Text('app.import'.tr()),
          ),
        ],
      ),
    );
  }
}
