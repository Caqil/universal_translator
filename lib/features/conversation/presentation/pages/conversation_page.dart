// lib/features/conversation/presentation/pages/conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/message.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../widgets/conversation_bubble.dart';
import '../widgets/language_switch_button.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ConversationBloc>()..add(const LoadConversationsEvent()),
      child: const ConversationView(),
    );
  }
}

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  bool _isSearching = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _fabAnimationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupListeners() {
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onMessageTextChanged);
  }

  void _onScroll() {
    final showScrollButton = _scrollController.offset > 200;
    if (showScrollButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showScrollButton;
      });

      if (_showScrollToBottom) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  void _onMessageTextChanged() {
    // Can add typing indicators or other real-time features here
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: _buildAppBar(context, brightness),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Column(
            children: [
              if (_isSearching) _buildSearchBar(context, brightness),
              Expanded(child: _buildBody(context, state, brightness)),
              if (state.hasSelectedConversation)
                _buildMessageInput(context, state, brightness),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context, brightness),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, Brightness brightness) {
    return CustomAppBar(
      titleWidget: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state.hasSelectedConversation) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedConversation!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${state.selectedConversation!.messageCount} messages',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground(brightness),
                      ),
                ),
              ],
            );
          }
          return Text('conversation_title'.tr());
        },
      ),
      actions: [
        BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Iconsax.close_square : Iconsax.search_normal,
                  ),
                  onPressed: _toggleSearch,
                ),
                if (state.hasSelectedConversation) ...[
                  LanguageSwitchButton(
                    sourceLanguage: state.sourceLanguage,
                    targetLanguage: state.targetLanguage,
                    onSwap: () {
                      context
                          .read<ConversationBloc>()
                          .add(const SwapConversationLanguagesEvent());
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.more),
                    onSelected: (value) =>
                        _handleMenuAction(context, value, state),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(
                              state.selectedConversation!.isArchived
                                  ? Iconsax.archive_minus
                                  : Iconsax.archive_add,
                            ),
                            const SizedBox(width: 8),
                            Text(state.selectedConversation!.isArchived
                                ? 'unarchive'.tr()
                                : 'archive'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              state.selectedConversation!.isPinned
                                  ? Iconsax.bookmark_2
                                  : Iconsax.bookmark,
                            ),
                            const SizedBox(width: 8),
                            Text(state.selectedConversation!.isPinned
                                ? 'unpin'.tr()
                                : 'pin'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            const Icon(Iconsax.export),
                            const SizedBox(width: 8),
                            Text('export'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Iconsax.trash, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('delete'.tr(),
                                style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
      leading: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state.hasSelectedConversation) {
            return IconButton(
              icon: const Icon(Iconsax.arrow_left_2),
              onPressed: () {
                context
                    .read<ConversationBloc>()
                    .add(const SelectConversationEvent(null));
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_conversations'.tr(),
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: IconButton(
            icon: const Icon(Iconsax.close_square),
            onPressed: () {
              _searchController.clear();
              context.read<ConversationBloc>().add(const ClearSearchEvent());
            },
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.background(brightness),
        ),
        onChanged: (query) {
          if (query.trim().isNotEmpty) {
            context
                .read<ConversationBloc>()
                .add(SearchConversationsEvent(query));
          } else {
            context.read<ConversationBloc>().add(const ClearSearchEvent());
          }
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    if (state.isLoading && !state.hasConversations) {
      return CustomLoadingWidget.page(
        message: 'loading_conversations'.tr(),
      );
    }

    if (state.hasError) {
      return CustomErrorWidget.network(
        message: state.errorMessage,
        onRetry: () {
          context
              .read<ConversationBloc>()
              .add(const LoadConversationsEvent(forceRefresh: true));
        },
      );
    }

    if (state.hasSelectedConversation) {
      return _buildConversationView(context, state, brightness);
    }

    return _buildConversationsList(context, state, brightness);
  }

  Widget _buildConversationsList(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    if (_isSearching && state.searchQuery != null) {
      return _buildSearchResults(context, state, brightness);
    }

    if (!state.hasConversations) {
      return _buildEmptyState(context, brightness);
    }

    final conversations = state.recentConversations;

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary(brightness),
              child: Text(
                conversation.title.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              conversation.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (conversation.lastMessage != null)
                  Text(
                    conversation.lastMessage!.originalText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat.MMMd().format(conversation.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${conversation.messageCount} messages',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (conversation.hasUnreadMessages) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.destructive(brightness),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${conversation.unreadMessageCount}',
                          style: TextStyle(
                            color: AppColors.primary(brightness),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (conversation.isPinned)
                  Icon(
                    Iconsax.bookmark_2,
                    size: 16,
                    color: AppColors.primary(brightness),
                  ),
                const Icon(Iconsax.arrow_right_3),
              ],
            ),
            onTap: () {
              context
                  .read<ConversationBloc>()
                  .add(SelectConversationEvent(conversation.id));
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    if (state.isSearching) {
      return CustomLoadingWidget.page(
        message: 'searching'.tr(),
      );
    }

    if (state.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 64,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'no_results_found'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'search_hint'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final conversation = state.searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary(brightness),
              child: Text(conversation.title.substring(0, 1).toUpperCase()),
            ),
            title: Text(conversation.title),
            subtitle: Text(
              conversation.lastMessage?.originalText ?? 'no_messages'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              context
                  .read<ConversationBloc>()
                  .add(SelectConversationEvent(conversation.id));
              _toggleSearch();
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message,
              size: 80,
              color: AppColors.mutedForeground(brightness),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              'no_conversations_title'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.mutedForeground(brightness),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'no_conversations_subtitle'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedForeground(brightness),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            CustomButton(
              text: 'start_conversation'.tr(),
              onPressed: () => _showStartConversationDialog(context),
              icon: Iconsax.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationView(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    return Column(
      children: [
        Expanded(
          child: state.currentMessages.isEmpty
              ? _buildEmptyConversation(context, brightness)
              : _buildMessagesList(context, state, brightness),
        ),
      ],
    );
  }

  Widget _buildEmptyConversation(BuildContext context, Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_text,
            size: 64,
            color: AppColors.mutedForeground(brightness),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'start_chatting'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.mutedForeground(brightness),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: state.currentMessages.length,
      itemBuilder: (context, index) {
        final message = state.currentMessages[index];
        final isLastMessage = index == state.currentMessages.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLastMessage
                ? AppConstants.defaultPadding
                : AppConstants.smallPadding,
          ),
          child: ConversationBubble(
            message: message,
            onTranslate: (targetLang) {
              context.read<ConversationBloc>().add(
                    TranslateMessageEvent(
                      messageId: message.id,
                      targetLanguage: targetLang,
                    ),
                  );
            },
            onFavorite: () {
              context
                  .read<ConversationBloc>()
                  .add(ToggleMessageFavoriteEvent(message.id));
            },
            onDelete: () {
              context
                  .read<ConversationBloc>()
                  .add(DeleteMessageEvent(message.id));
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ConversationState state,
    Brightness brightness,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(
          top: BorderSide(
            color: AppColors.border(brightness),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'type_message'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background(brightness),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.defaultPadding,
                ),
              ),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _sendMessage(context, state),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) {
              final isLoading = state.isAddingMessageTo(
                state.selectedConversation!.id,
              );

              return CustomButton(
                onPressed:
                    isLoading ? null : () => _sendMessage(context, state),
                icon: isLoading ? null : Iconsax.send_1,
                size: ButtonSize.medium,
                variant: ButtonVariant.primary,
                child: isLoading
                    ? CustomLoadingWidget.button(
                        color: AppColors.surface(brightness),
                        size: 16,
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, Brightness brightness) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        if (state.hasSelectedConversation) {
          return AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabAnimation.value,
                child: FloatingActionButton(
                  onPressed: _scrollToBottom,
                  backgroundColor: AppColors.primary(brightness),
                  child: Icon(
                    Iconsax.arrow_down_1,
                    color: AppColors.primary(brightness),
                  ),
                ),
              );
            },
          );
        }

        return FloatingActionButton(
          onPressed: () => _showStartConversationDialog(context),
          backgroundColor: AppColors.primary(brightness),
          child: Icon(
            Iconsax.add,
            color: AppColors.primary(brightness),
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, ConversationState state) {
    if (state.status == ConversationStatus.messageAdded) {
      _messageController.clear();
      _scrollToBottom();
    }

    if (state.hasError && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  void _handleMenuAction(
      BuildContext context, String action, ConversationState state) {
    final conversationId = state.selectedConversation!.id;

    switch (action) {
      case 'archive':
        context
            .read<ConversationBloc>()
            .add(ToggleArchiveConversationEvent(conversationId));
        break;
      case 'pin':
        context
            .read<ConversationBloc>()
            .add(TogglePinConversationEvent(conversationId));
        break;
      case 'export':
        context
            .read<ConversationBloc>()
            .add(ExportConversationEvent(conversationId: conversationId));
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, conversationId);
        break;
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (!_isSearching) {
      _searchController.clear();
      context.read<ConversationBloc>().add(const ClearSearchEvent());
    }
  }

  void _sendMessage(BuildContext context, ConversationState state) {
    final text = _messageController.text.trim();
    if (text.isEmpty || !state.hasSelectedConversation) return;

    context.read<ConversationBloc>().add(
          AddMessageEvent(
            conversationId: state.selectedConversation!.id,
            originalText: text,
            originalLanguage: state.sourceLanguage,
            type: MessageType.text,
            sender: MessageSender.user,
          ),
        );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeOut,
      );
    }
  }

  void _showStartConversationDialog(BuildContext context) {
    // Implementation for start conversation dialog
    // This would show a dialog to create a new conversation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Start conversation dialog would appear here')),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_conversation'.tr()),
        content: Text('delete_conversation_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<ConversationBloc>()
                  .add(DeleteConversationEvent(conversationId));
            },
            child:
                Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
