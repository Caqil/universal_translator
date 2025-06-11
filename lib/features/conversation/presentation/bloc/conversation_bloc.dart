// lib/features/conversation/presentation/bloc/conversation_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/message.dart';
import '../../domain/usecases/add_message.dart';
import '../../domain/usecases/start_conversation.dart';
import '../../domain/usecases/translate_message.dart';
import '../../domain/repositories/conversation_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

@injectable
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _repository;
  final StartConversation _startConversation;
  final AddMessage _addMessage;
  final TranslateMessage _translateMessage;

  ConversationBloc(
    this._repository,
    this._startConversation,
    this._addMessage,
    this._translateMessage,
  ) : super(const ConversationInitial()) {
    on<LoadConversationsEvent>(_onLoadConversations);
    on<LoadConversationEvent>(_onLoadConversation);
    on<StartConversationEvent>(_onStartConversation);
    on<UpdateConversationEvent>(_onUpdateConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<ToggleArchiveConversationEvent>(_onToggleArchiveConversation);
    on<TogglePinConversationEvent>(_onTogglePinConversation);
    on<AddMessageEvent>(_onAddMessage);
    on<TranslateMessageEvent>(_onTranslateMessage);
    on<UpdateMessageEvent>(_onUpdateMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
    on<MarkConversationAsReadEvent>(_onMarkConversationAsRead);
    on<ToggleMessageFavoriteEvent>(_onToggleMessageFavorite);
    on<SearchConversationsEvent>(_onSearchConversations);
    on<SearchMessagesEvent>(_onSearchMessages);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadRecentConversationsEvent>(_onLoadRecentConversations);
    on<ExportConversationEvent>(_onExportConversation);
    on<SelectConversationEvent>(_onSelectConversation);
    on<SetConversationLanguagesEvent>(_onSetConversationLanguages);
    on<SwapConversationLanguagesEvent>(_onSwapConversationLanguages);
  }

  Future<void> _onLoadConversations(
    LoadConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (!event.forceRefresh && state.hasConversations) {
      return;
    }

    emit(state.copyWith(status: ConversationStatus.loading));

    final result = await _repository.getConversations(
      includeArchived: event.includeArchived,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (conversations) => emit(state.copyWith(
        status: ConversationStatus.loaded,
        conversations: conversations,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadConversation(
    LoadConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.loading));

    final result = await _repository.getConversationById(event.conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (conversation) {
        if (conversation != null) {
          emit(state.copyWith(
            status: ConversationStatus.loaded,
            selectedConversation: conversation,
            currentMessages: conversation.messages,
            errorMessage: null,
          ));
        } else {
          emit(state.copyWith(
            status: ConversationStatus.failure,
            errorMessage: 'Conversation not found',
          ));
        }
      },
    );
  }

  Future<void> _onStartConversation(
    StartConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.creating));

    final result = await _startConversation(StartConversationParams(
      title: event.title,
      sourceLanguage: event.sourceLanguage,
      targetLanguage: event.targetLanguage,
      participantName: event.participantName,
      category: event.category,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (conversation) {
        final updatedConversations = [conversation, ...state.conversations];
        emit(state.copyWith(
          status: ConversationStatus.created,
          conversations: updatedConversations,
          selectedConversation: conversation,
          currentMessages: conversation.messages,
          sourceLanguage: event.sourceLanguage,
          targetLanguage: event.targetLanguage,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onUpdateConversation(
    UpdateConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.updating));

    final result = await _repository.updateConversation(
      event.conversationId,
      event.conversation,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedConversation) {
        final updatedConversations = state.conversations
            .map((conv) =>
                conv.id == event.conversationId ? updatedConversation : conv)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.updated,
          conversations: updatedConversations,
          selectedConversation:
              state.selectedConversation?.id == event.conversationId
                  ? updatedConversation
                  : state.selectedConversation,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.deleting));

    final result = await _repository.deleteConversation(event.conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedConversations = state.conversations
            .where((conv) => conv.id != event.conversationId)
            .toList();

        ConversationState newState = state.copyWith(
          status: ConversationStatus.deleted,
          conversations: updatedConversations,
          errorMessage: null,
        );

        // Clear selected conversation if it was deleted
        if (state.selectedConversation?.id == event.conversationId) {
          newState = newState.copyWithNullConversation();
        }

        emit(newState);
      },
    );
  }

  Future<void> _onToggleArchiveConversation(
    ToggleArchiveConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.updating));

    final result =
        await _repository.toggleArchiveConversation(event.conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedConversation) {
        final updatedConversations = state.conversations
            .map((conv) =>
                conv.id == event.conversationId ? updatedConversation : conv)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.updated,
          conversations: updatedConversations,
          selectedConversation:
              state.selectedConversation?.id == event.conversationId
                  ? updatedConversation
                  : state.selectedConversation,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onTogglePinConversation(
    TogglePinConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.updating));

    final result =
        await _repository.togglePinConversation(event.conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedConversation) {
        final updatedConversations = state.conversations
            .map((conv) =>
                conv.id == event.conversationId ? updatedConversation : conv)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.updated,
          conversations: updatedConversations,
          selectedConversation:
              state.selectedConversation?.id == event.conversationId
                  ? updatedConversation
                  : state.selectedConversation,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onAddMessage(
    AddMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.addingMessage));

    final result = await _addMessage(AddMessageParams(
      conversationId: event.conversationId,
      originalText: event.originalText,
      originalLanguage: event.originalLanguage,
      type: event.type,
      sender: event.sender,
      translatedText: event.translatedText,
      translatedLanguage: event.translatedLanguage,
      voiceFilePath: event.voiceFilePath,
      voiceDuration: event.voiceDuration,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (message) {
        // Update current messages if we're viewing this conversation
        List<Message> updatedMessages = state.currentMessages;
        if (state.selectedConversation?.id == event.conversationId) {
          updatedMessages = [...state.currentMessages, message];
        }

        emit(state.copyWith(
          status: ConversationStatus.messageAdded,
          currentMessages: updatedMessages,
          errorMessage: null,
        ));

        // Reload conversations to update message counts and timestamps
        add(const LoadConversationsEvent(forceRefresh: true));
      },
    );
  }

  Future<void> _onTranslateMessage(
    TranslateMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.translatingMessage));

    final result = await _translateMessage(TranslateMessageParams(
      messageId: event.messageId,
      targetLanguage: event.targetLanguage,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedMessage) {
        final updatedMessages = state.currentMessages
            .map((msg) => msg.id == event.messageId ? updatedMessage : msg)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.messageTranslated,
          currentMessages: updatedMessages,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onUpdateMessage(
    UpdateMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.updating));

    final result =
        await _repository.updateMessage(event.messageId, event.message);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedMessage) {
        final updatedMessages = state.currentMessages
            .map((msg) => msg.id == event.messageId ? updatedMessage : msg)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.updated,
          currentMessages: updatedMessages,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.deleting));

    final result = await _repository.deleteMessage(event.messageId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedMessages = state.currentMessages
            .where((msg) => msg.id != event.messageId)
            .toList();

        emit(state.copyWith(
          status: ConversationStatus.deleted,
          currentMessages: updatedMessages,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final result = await _repository.markMessageAsRead(event.messageId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedMessage) {
        final updatedMessages = state.currentMessages
            .map((msg) => msg.id == event.messageId ? updatedMessage : msg)
            .toList();

        emit(state.copyWith(
          currentMessages: updatedMessages,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onMarkConversationAsRead(
    MarkConversationAsReadEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final result =
        await _repository.markConversationAsRead(event.conversationId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        // Mark all current messages as read
        final updatedMessages = state.currentMessages
            .map((msg) => msg.copyWith(isRead: true))
            .toList();

        emit(state.copyWith(
          currentMessages: updatedMessages,
          errorMessage: null,
        ));

        // Reload conversations to update unread counts
        add(const LoadConversationsEvent(forceRefresh: true));
      },
    );
  }

  Future<void> _onToggleMessageFavorite(
    ToggleMessageFavoriteEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final result = await _repository.toggleMessageFavorite(event.messageId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (updatedMessage) {
        final updatedMessages = state.currentMessages
            .map((msg) => msg.id == event.messageId ? updatedMessage : msg)
            .toList();

        emit(state.copyWith(
          currentMessages: updatedMessages,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onSearchConversations(
    SearchConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
        searchResults: [],
        searchQuery: null,
        isSearching: false,
      ));
      return;
    }

    emit(state.copyWith(
      status: ConversationStatus.searching,
      isSearching: true,
      searchQuery: event.query,
    ));

    final result = await _repository.searchConversations(event.query);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
        isSearching: false,
      )),
      (searchResults) => emit(state.copyWith(
        status: ConversationStatus.searchResults,
        searchResults: searchResults,
        isSearching: false,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSearchMessages(
    SearchMessagesEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
        messageSearchResults: [],
        searchQuery: null,
        isSearching: false,
      ));
      return;
    }

    emit(state.copyWith(
      status: ConversationStatus.searching,
      isSearching: true,
      searchQuery: event.query,
    ));

    final result = await _repository.searchMessages(
      event.query,
      conversationId: event.conversationId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
        isSearching: false,
      )),
      (searchResults) => emit(state.copyWith(
        status: ConversationStatus.searchResults,
        messageSearchResults: searchResults,
        isSearching: false,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(
      searchResults: [],
      messageSearchResults: [],
      searchQuery: null,
      isSearching: false,
      status: ConversationStatus.loaded,
    ));
  }

  Future<void> _onLoadRecentConversations(
    LoadRecentConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.loading));

    final result = await _repository.getRecentConversations(limit: event.limit);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (conversations) => emit(state.copyWith(
        status: ConversationStatus.loaded,
        conversations: conversations,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onExportConversation(
    ExportConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(status: ConversationStatus.exporting));

    final result = await _repository.exportConversation(
      event.conversationId,
      includeTranslations: event.includeTranslations,
      includeTimestamps: event.includeTimestamps,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ConversationStatus.failure,
        errorMessage: failure.message,
      )),
      (exportData) => emit(state.copyWith(
        status: ConversationStatus.exported,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onSelectConversation(
    SelectConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (event.conversationId == null) {
      emit(state.copyWithNullConversation());
      return;
    }

    final conversation = state.getConversationById(event.conversationId!);
    if (conversation != null) {
      emit(state.copyWith(
        selectedConversation: conversation,
        currentMessages: conversation.messages,
        sourceLanguage: conversation.sourceLanguage,
        targetLanguage: conversation.targetLanguage,
      ));
    }
  }

  Future<void> _onSetConversationLanguages(
    SetConversationLanguagesEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(
      sourceLanguage: event.sourceLanguage,
      targetLanguage: event.targetLanguage,
    ));
  }

  Future<void> _onSwapConversationLanguages(
    SwapConversationLanguagesEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.canSwapLanguages) {
      emit(state.copyWith(
        sourceLanguage: state.targetLanguage,
        targetLanguage: state.sourceLanguage,
      ));
    }
  }
}
