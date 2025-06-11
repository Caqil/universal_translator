import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:translate_app/core/utils/extensions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
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

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  bool _showGrouped = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  String _currentFilter = 'all'; // all, favorites, today, week, month

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
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
    // Show/hide FAB based on scroll position
    if (_scrollController.position.pixels > 200) {
      if (!_fabController.isCompleted) _fabController.forward();
    } else {
      if (_fabController.isCompleted) _fabController.reverse();
    }

    // Pagination
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
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
    final brightness = context.brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: _buildAppBar(brightness),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(brightness),
              _buildFilterChips(brightness),
              Expanded(
                child: BlocConsumer<HistoryBloc, HistoryState>(
                  listener: _handleStateChange,
                  builder: (context, state) {
                    return _buildContent(context, state, brightness);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(brightness),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.surface(brightness),
      elevation: 0,
      title: Text(
        _isSelectionMode
            ? 'history.selected_count'
                .tr(args: [_selectedItems.length.toString()])
            : 'history.translation_history'.tr(),
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.adaptive(
            light: AppColors.lightForeground,
            dark: AppColors.darkForeground,
            brightness: brightness,
          ),
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: _isSelectionMode
          ? IconButton(
              icon: Icon(
                Iconsax.close_circle,
                color: AppColors.adaptive(
                  light: AppColors.lightForeground,
                  dark: AppColors.darkForeground,
                  brightness: brightness,
                ),
              ),
              onPressed: _exitSelectionMode,
            )
          : null,
      actions: _isSelectionMode
          ? _buildSelectionActions(brightness)
          : _buildNormalActions(brightness),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.border(brightness).withOpacity(0),
                AppColors.border(brightness),
                AppColors.border(brightness).withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNormalActions(Brightness brightness) {
    return [
      IconButton(
        icon: Icon(
          _showGrouped ? Iconsax.element_4 : Iconsax.category,
          color: AppColors.adaptive(
            light: AppColors.lightForeground,
            dark: AppColors.darkForeground,
            brightness: brightness,
          ),
        ),
        onPressed: () {
          setState(() {
            _showGrouped = !_showGrouped;
          });
          _loadHistory();
        },
        tooltip: _showGrouped
            ? 'history.list_view'.tr()
            : 'history.grouped_view'.tr(),
      ),
      PopupMenuButton<String>(
        icon: Icon(
          Iconsax.more,
          color: AppColors.adaptive(
            light: AppColors.lightForeground,
            dark: AppColors.darkForeground,
            brightness: brightness,
          ),
        ),
        onSelected: _handleMenuAction,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        itemBuilder: (context) => [
          _buildMenuItem(
            value: 'favorites',
            icon: Iconsax.heart5,
            title: 'favorites.favorite_translations'.tr(),
            brightness: brightness,
          ),
          _buildMenuItem(
            value: 'select',
            icon: Iconsax.tick_square,
            title: 'history.select_items'.tr(),
            brightness: brightness,
          ),
          const PopupMenuDivider(),
          _buildMenuItem(
            value: 'export',
            icon: Iconsax.export,
            title: 'history.export_history'.tr(),
            brightness: brightness,
          ),
          _buildMenuItem(
            value: 'import',
            icon: Iconsax.import,
            title: 'history.import_history'.tr(),
            brightness: brightness,
          ),
          const PopupMenuDivider(),
          _buildMenuItem(
            value: 'clear',
            icon: Iconsax.trash,
            title: 'history.clear_history'.tr(),
            brightness: brightness,
            isDestructive: true,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSelectionActions(Brightness brightness) {
    return [
      IconButton(
        icon: Icon(
          Iconsax.heart,
          color: AppColors.adaptive(
            light: AppColors.lightForeground,
            dark: AppColors.darkForeground,
            brightness: brightness,
          ),
        ),
        onPressed: _selectedItems.isNotEmpty ? _favoriteSelected : null,
        tooltip: 'favorites.add_to_favorites'.tr(),
      ),
      IconButton(
        icon: Icon(
          Iconsax.export,
          color: AppColors.adaptive(
            light: AppColors.lightForeground,
            dark: AppColors.darkForeground,
            brightness: brightness,
          ),
        ),
        onPressed: _selectedItems.isNotEmpty ? _shareSelected : null,
        tooltip: 'app.share'.tr(),
      ),
      IconButton(
        icon: Icon(Iconsax.trash, color: AppColors.destructive(brightness)),
        onPressed: _selectedItems.isNotEmpty ? _deleteSelected : null,
        tooltip: 'app.delete'.tr(),
      ),
    ];
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required Brightness brightness,
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeSmall,
            color: isDestructive
                ? AppColors.destructive(brightness)
                : AppColors.adaptive(
                    light: AppColors.lightForeground,
                    dark: AppColors.darkForeground,
                    brightness: brightness,
                  ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDestructive
                  ? AppColors.destructive(brightness)
                  : AppColors.adaptive(
                      light: AppColors.lightForeground,
                      dark: AppColors.darkForeground,
                      brightness: brightness,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        boxShadow: [
          BoxShadow(
            color: AppColors.border(brightness).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(Brightness brightness) {
    final filters = [
      {'key': 'all', 'label': 'app.all'.tr(), 'icon': Iconsax.element_4},
      {
        'key': 'favorites',
        'label': 'app.favorites'.tr(),
        'icon': Iconsax.heart5
      },
      {'key': 'today', 'label': 'app.today'.tr(), 'icon': Iconsax.calendar_1},
      {'key': 'week', 'label': 'app.this_week'.tr(), 'icon': Iconsax.calendar},
      {
        'key': 'month',
        'label': 'app.this_month'.tr(),
        'icon': Iconsax.calendar_2
      },
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        itemCount: filters.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppConstants.smallPadding),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _currentFilter == filter['key'];

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter['icon'] as IconData,
                  size: AppConstants.iconSizeSmall,
                  color: isSelected
                      ? AppColors.adaptive(
                          light: AppColors.lightPrimaryForeground,
                          dark: AppColors.darkPrimaryForeground,
                          brightness: brightness,
                        )
                      : AppColors.mutedForeground(brightness),
                ),
                const SizedBox(width: AppConstants.smallPadding / 2),
                Text(
                  filter['label'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.adaptive(
                            light: AppColors.lightPrimaryForeground,
                            dark: AppColors.darkPrimaryForeground,
                            brightness: brightness,
                          )
                        : AppColors.mutedForeground(brightness),
                  ),
                ),
              ],
            ),
            onSelected: (selected) {
              setState(() {
                _currentFilter = filter['key'] as String;
              });
              _applyFilter(filter['key'] as String);
            },
            backgroundColor: AppColors.surface(brightness),
            selectedColor: AppColors.primary(brightness),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary(brightness)
                    : AppColors.border(brightness),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, HistoryState state, Brightness brightness) {
    if (state is HistoryLoading) {
      return _buildShimmerLoading(brightness);
    }

    if (state is HistoryError) {
      return _buildErrorState(state, brightness);
    }

    if (state is HistoryEmpty) {
      return _buildEmptyState(state, brightness);
    }

    if (state is HistoryGroupedLoaded) {
      return _buildGroupedHistory(context, state, brightness);
    }

    if (state is HistoryLoaded) {
      return _buildListHistory(context, state, brightness);
    }

    if (state is FavoriteHistoryLoaded) {
      return _buildFavoriteHistory(context, state, brightness);
    }

    return const SizedBox.shrink();
  }

  Widget _buildShimmerLoading(Brightness brightness) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 8,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.defaultPadding),
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(color: AppColors.border(brightness)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildShimmerBox(100, 16, brightness),
                    const Spacer(),
                    _buildShimmerBox(60, 16, brightness),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                _buildShimmerBox(double.infinity, 20, brightness),
                const SizedBox(height: AppConstants.smallPadding / 2),
                _buildShimmerBox(200, 16, brightness),
                const Spacer(),
                Row(
                  children: [
                    _buildShimmerBox(40, 32, brightness),
                    const SizedBox(width: AppConstants.smallPadding),
                    _buildShimmerBox(40, 32, brightness),
                    const SizedBox(width: AppConstants.smallPadding),
                    _buildShimmerBox(40, 32, brightness),
                    const Spacer(),
                    _buildShimmerBox(80, 16, brightness),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(double width, double height, Brightness brightness) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.adaptive(
          light: AppColors.lightMuted,
          dark: AppColors.darkMuted,
          brightness: brightness,
        ),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
    );
  }

  Widget _buildErrorState(HistoryError state, Brightness brightness) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
              color: AppColors.destructive(brightness).withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 48,
              color: AppColors.destructive(brightness),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'app.error'.tr(),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.adaptive(
                  light: AppColors.lightForeground,
                  dark: AppColors.darkForeground,
                  brightness: brightness,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            CustomButton(
              text: 'app.retry'.tr(),
              onPressed: _loadHistory,
              variant: ButtonVariant.outline,
              icon: Iconsax.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(HistoryEmpty state, Brightness brightness) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.extraLargePadding),
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(color: AppColors.border(brightness)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: AppColors.adaptive(
                  light: AppColors.lightMuted,
                  dark: AppColors.darkMuted,
                  brightness: brightness,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isSearching
                    ? Iconsax.search_normal
                    : Iconsax.document_text,
                size: 48,
                color: AppColors.mutedForeground(brightness),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              state.isSearching
                  ? 'history.no_search_results'.tr()
                  : 'history.history_empty'.tr(),
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.adaptive(
                  light: AppColors.lightForeground,
                  dark: AppColors.darkForeground,
                  brightness: brightness,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.isSearching
                  ? 'history.try_different_search'.tr()
                  : 'history.start_translating'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            if (state.isSearching) ...[
              const SizedBox(height: AppConstants.largePadding),
              CustomButton(
                text: 'app.clear_search'.tr(),
                onPressed: () {
                  context.read<HistoryBloc>().add(const ClearSearchEvent());
                },
                variant: ButtonVariant.outline,
                icon: Iconsax.close_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListHistory(
      BuildContext context, HistoryLoaded state, Brightness brightness) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const RefreshHistoryEvent());
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppConstants.defaultPadding),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return _buildLoadingIndicator(brightness);
          }

          final item = state.items[index];
          return _buildHistoryCard(item, brightness, index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item, Brightness brightness, int index) {
    final isSelected = _selectedItems.contains(item.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..translate(0.0, isSelected ? -4.0 : 0.0),
      child: InkWell(
        onTap: () =>
            _isSelectionMode ? _toggleSelection(item.id) : _handleItemTap(item),
        onLongPress: () => _enterSelectionMode(item.id),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.border(brightness).withOpacity(0.1),
                blurRadius: isSelected ? 12 : 4,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: HistoryItemWidget(
            item: item,
            isSelected: isSelected,
            isSelectionMode: _isSelectionMode,
            onTap: () => _handleItemTap(item),
            onFavoriteToggle: () => _toggleFavorite(item.id),
            onDelete: () => _deleteItem(item.id),
            onCopy: () => _copyItem(item),
            onShare: () => _shareItem(item),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedHistory(
      BuildContext context, HistoryGroupedLoaded state, Brightness brightness) {
    final groups = ['Today', 'Yesterday', 'This Week', 'This Month', 'Older'];

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const LoadGroupedHistoryEvent());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final groupKey = groups[index];
          final items = state.groupedItems[groupKey] ?? [];

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(groupKey, brightness),
              const SizedBox(height: AppConstants.defaultPadding),
              ...items.asMap().entries.map((entry) {
                final itemIndex = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: itemIndex < items.length - 1
                        ? AppConstants.defaultPadding
                        : AppConstants.largePadding,
                  ),
                  child: _buildHistoryCard(item, brightness, itemIndex),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupHeader(String groupKey, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.adaptive(
          light: AppColors.lightMuted,
          dark: AppColors.darkMuted,
          brightness: brightness,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Text(
        'history.$groupKey'.tr(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.mutedForeground(brightness),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFavoriteHistory(BuildContext context,
      FavoriteHistoryLoaded state, Brightness brightness) {
    if (state.favoriteItems.isEmpty) {
      return _buildEmptyFavorites(brightness);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryBloc>().add(const LoadFavoriteHistoryEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: state.favoriteItems.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppConstants.defaultPadding),
        itemBuilder: (context, index) {
          final item = state.favoriteItems[index];
          return _buildHistoryCard(item, brightness, index);
        },
      ),
    );
  }

  Widget _buildEmptyFavorites(Brightness brightness) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.extraLargePadding),
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          border: Border.all(color: AppColors.border(brightness)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: AppColors.warning(brightness).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.heart,
                size: 48,
                color: AppColors.warning(brightness),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              'favorites.no_favorites'.tr(),
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.adaptive(
                  light: AppColors.lightForeground,
                  dark: AppColors.darkForeground,
                  brightness: brightness,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'favorites.tap_star_to_favorite'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary(brightness),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Text(
            'app.loading_more'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground(brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(Brightness brightness) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: AppColors.primary(brightness),
        foregroundColor: AppColors.adaptive(
          light: AppColors.lightPrimaryForeground,
          dark: AppColors.darkPrimaryForeground,
          brightness: brightness,
        ),
        child: const Icon(Iconsax.arrow_up_2),
      ),
    );
  }

  // Event handlers
  void _handleStateChange(BuildContext context, HistoryState state) {
    final sonner = ShadSonner.of(context);

    if (state is HistoryItemDeleted) {
      sonner.show(
        ShadToast(
          description: Text('history.history_item_deleted'.tr()),
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
      sonner.show(
        ShadToast(description: Text('history.history_cleared'.tr())),
      );
    }

    if (state is HistoryExported) {
      sonner.show(
        ShadToast(description: Text('history.export_success'.tr())),
      );
    }

    if (state is HistoryImported) {
      sonner.show(
        ShadToast(
          description: Text('history.import_success'.tr().replaceAll(
                '{count}',
                state.importedCount.toString(),
              )),
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'favorites':
        setState(() {
          _currentFilter = 'favorites';
        });
        context.read<HistoryBloc>().add(const LoadFavoriteHistoryEvent());
        break;
      case 'select':
        _enterSelectionMode();
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

  void _applyFilter(String filter) {
    switch (filter) {
      case 'all':
        _loadHistory();
        break;
      case 'favorites':
        context.read<HistoryBloc>().add(const LoadFavoriteHistoryEvent());
        break;
      case 'today':
        context.read<HistoryBloc>().add(const LoadHistoryByDateEvent(days: 1));
        break;
      case 'week':
        context.read<HistoryBloc>().add(const LoadHistoryByDateEvent(days: 7));
        break;
      case 'month':
        context.read<HistoryBloc>().add(const LoadHistoryByDateEvent(days: 30));
        break;
    }
  }

  void _enterSelectionMode([String? initialSelection]) {
    setState(() {
      _isSelectionMode = true;
      _selectedItems.clear();
      if (initialSelection != null) {
        _selectedItems.add(initialSelection);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _favoriteSelected() {
    for (final id in _selectedItems) {
      context.read<HistoryBloc>().add(ToggleFavoriteEvent(id));
    }
    _exitSelectionMode();
  }

  void _shareSelected() {
    // TODO: Implement bulk share
    _exitSelectionMode();
  }

  void _deleteSelected() {
    for (final id in _selectedItems) {
      context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id));
    }
    _exitSelectionMode();
  }

  void _handleItemTap(HistoryItem item) {
    if (_isSelectionMode) {
      _toggleSelection(item.id);
    } else {
      // TODO: Navigate to translation page with pre-filled data
      // Navigator.pushNamed(context, '/translation', arguments: item);
    }
  }

  void _toggleFavorite(String id) {
    context.read<HistoryBloc>().add(ToggleFavoriteEvent(id));
  }

  void _deleteItem(String id) {
    context.read<HistoryBloc>().add(DeleteHistoryItemEvent(id));
  }

  void _copyItem(HistoryItem item) {
    Clipboard.setData(ClipboardData(text: item.translatedText));
    ShadSonner.of(context).show(
      ShadToast(
        description: Row(
          children: [
            Icon(Iconsax.copy_success, size: AppConstants.iconSizeSmall),
            const SizedBox(width: AppConstants.smallPadding),
            Text('app.copied'.tr()),
          ],
        ),
      ),
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
          CustomButton(
            text: 'app.cancel'.tr(),
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomButton(
            text: 'app.clear'.tr(),
            variant: ButtonVariant.destructive,
            icon: Iconsax.trash,
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HistoryBloc>().add(const ClearHistoryEvent());
            },
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
        title: Text('history.import_history'.tr()),
        description: Text('history.import_history_description'.tr()),
        actions: [
          CustomButton(
            text: 'app.cancel'.tr(),
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomButton(
            text: 'app.import'.tr(),
            icon: Iconsax.import,
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Pick file and import
            },
          ),
        ],
      ),
    );
  }

  // TODO: Add LoadHistoryByDateEvent class to your history_event.dart:
  /*
  class LoadHistoryByDateEvent extends HistoryEvent {
    final int days;
    const LoadHistoryByDateEvent({required this.days});
    @override
    List<Object?> get props => [days];
  }
  */
}
