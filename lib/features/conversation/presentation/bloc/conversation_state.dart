// lib/features/conversation/presentation/bloc/conversation_state.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

/// Conversation status enum
enum ConversationStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  addingMessage,
  messageAdded,
  translatingMessage,
  messageTranslated,
  searching,
  searchResults,
  exporting,
  exported,
  failure,
}

/// Conversation state
class ConversationState extends Equatable {
  final ConversationStatus status;
  final List<Conversation> conversations;
  final Conversation? selectedConversation;
  final List<Message> currentMessages;
  final List<Conversation> searchResults;
  final List<Message> messageSearchResults;
  final String? searchQuery;
  final String sourceLanguage;
  final String targetLanguage;
  final String? errorMessage;
  final bool isSearching;
  final Map<String, int> statistics;

  const ConversationState({
    this.status = ConversationStatus.initial,
    this.conversations = const [],
    this.selectedConversation,
    this.currentMessages = const [],
    this.searchResults = const [],
    this.messageSearchResults = const [],
    this.searchQuery,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'es',
    this.errorMessage,
    this.isSearching = false,
    this.statistics = const {},
  });

  /// Copy with new values
  ConversationState copyWith({
    ConversationStatus? status,
    List<Conversation>? conversations,
    Conversation? selectedConversation,
    List<Message>? currentMessages,
    List<Conversation>? searchResults,
    List<Message>? messageSearchResults,
    String? searchQuery,
    String? sourceLanguage,
    String? targetLanguage,
    String? errorMessage,
    bool? isSearching,
    Map<String, int>? statistics,
  }) {
    return ConversationState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation,
      currentMessages: currentMessages ?? this.currentMessages,
      searchResults: searchResults ?? this.searchResults,
      messageSearchResults: messageSearchResults ?? this.messageSearchResults,
      searchQuery: searchQuery,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Copy with null selected conversation
  ConversationState copyWithNullConversation() {
    return ConversationState(
      status: status,
      conversations: conversations,
      selectedConversation: null,
      currentMessages: const [],
      searchResults: searchResults,
      messageSearchResults: messageSearchResults,
      searchQuery: searchQuery,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      errorMessage: errorMessage,
      isSearching: isSearching,
      statistics: statistics,
    );
  }

  @override
  List<Object?> get props => [
        status,
        conversations,
        selectedConversation,
        currentMessages,
        searchResults,
        messageSearchResults,
        searchQuery,
        sourceLanguage,
        targetLanguage,
        errorMessage,
        isSearching,
        statistics,
      ];
}

/// Initial conversation state
class ConversationInitial extends ConversationState {
  const ConversationInitial() : super();
}

// Conversation state convenience getters
extension ConversationStateX on ConversationState {
  bool get isLoading =>
      status == ConversationStatus.loading ||
      status == ConversationStatus.creating ||
      status == ConversationStatus.updating ||
      status == ConversationStatus.deleting ||
      status == ConversationStatus.addingMessage ||
      status == ConversationStatus.translatingMessage ||
      status == ConversationStatus.exporting;

  bool get hasError => status == ConversationStatus.failure;

  bool get hasConversations => conversations.isNotEmpty;

  bool get hasSelectedConversation => selectedConversation != null;

  bool get hasMessages => currentMessages.isNotEmpty;

  bool get hasSearchResults =>
      searchResults.isNotEmpty || messageSearchResults.isNotEmpty;

  bool get canSwapLanguages =>
      sourceLanguage.isNotEmpty &&
      targetLanguage.isNotEmpty &&
      sourceLanguage != targetLanguage;

  /// Get unread conversations count
  int get unreadConversationsCount {
    return conversations.where((conv) => conv.hasUnreadMessages).length;
  }

  /// Get total messages count
  int get totalMessagesCount {
    return conversations.fold(0, (sum, conv) => sum + conv.messageCount);
  }

  /// Get pinned conversations
  List<Conversation> get pinnedConversations {
    return conversations
        .where((conv) => conv.isPinned && !conv.isArchived)
        .toList();
  }

  /// Get recent conversations (not archived, sorted by update time)
  List<Conversation> get recentConversations {
    final recent = conversations.where((conv) => !conv.isArchived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return recent;
  }

  /// Get archived conversations
  List<Conversation> get archivedConversations {
    return conversations.where((conv) => conv.isArchived).toList();
  }

  /// Get conversations by language pair
  List<Conversation> getConversationsByLanguages(
    String sourceLanguage,
    String targetLanguage,
  ) {
    return conversations.where((conv) {
      return (conv.sourceLanguage == sourceLanguage &&
              conv.targetLanguage == targetLanguage) ||
          (conv.sourceLanguage == targetLanguage &&
              conv.targetLanguage == sourceLanguage);
    }).toList();
  }

  /// Check if currently adding message to specific conversation
  bool isAddingMessageTo(String conversationId) {
    return status == ConversationStatus.addingMessage &&
        selectedConversation?.id == conversationId;
  }

  /// Check if currently translating a message
  bool isTranslatingMessage(String messageId) {
    return status == ConversationStatus.translatingMessage &&
        currentMessages.any((msg) => msg.id == messageId && msg.isTranslating);
  }

  /// Get conversation by ID
  Conversation? getConversationById(String id) {
    try {
      return conversations.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get message by ID from current messages
  Message? getMessageById(String id) {
    try {
      return currentMessages.firstWhere((msg) => msg.id == id);
    } catch (e) {
      return null;
    }
  }
}
