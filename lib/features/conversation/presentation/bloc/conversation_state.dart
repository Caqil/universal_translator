// lib/features/conversation/presentation/bloc/conversation_state.dart
import 'package:equatable/equatable.dart';
import '../../../translation/domain/entities/language.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/entities/conversation_session.dart';

enum ConversationStatus {
  initial,
  settingUp,
  ready,
  listening,
  processing,
  speaking,
  error,
  ended
}

class ConversationState extends Equatable {
  final ConversationStatus status;
  final ConversationSession? session;
  final List<ConversationMessage> messages;
  final bool isListening;
  final bool isUser1Active; // which user is currently active
  final bool isSpeaking;
  final bool autoSpeak;
  final String? errorMessage;
  final double? currentConfidence;
  final String? currentlyPlayingMessageId;
  final List<Language> supportedLanguages;
  final String user1Language;
  final String user2Language;
  const ConversationState({
    this.status = ConversationStatus.initial,
    this.session,
    this.messages = const [],
    this.isListening = false,
    this.isUser1Active = true,
    this.isSpeaking = false,
    this.autoSpeak = true,
    this.errorMessage,
    this.currentConfidence,
    this.currentlyPlayingMessageId,
    this.supportedLanguages = const [],
    this.user1Language = 'en',
    this.user2Language = 'es',
  });

  // Computed properties
  bool get canStartListening =>
      status == ConversationStatus.ready && !isListening && !isSpeaking;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasError => errorMessage != null;
  bool get isActive => session != null && status != ConversationStatus.ended;

  ConversationState copyWith({
    ConversationStatus? status,
    ConversationSession? session,
    List<ConversationMessage>? messages,
    bool? isListening,
    bool? isUser1Active,
    bool? isSpeaking,
    bool? autoSpeak,
    String? errorMessage,
    double? currentConfidence,
    String? currentlyPlayingMessageId,
    List<Language>? supportedLanguages,
    String? user1Language,
    String? user2Language,
  }) {
    return ConversationState(
      status: status ?? this.status,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isUser1Active: isUser1Active ?? this.isUser1Active,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      errorMessage: errorMessage,
      currentConfidence: currentConfidence ?? this.currentConfidence,
      currentlyPlayingMessageId: currentlyPlayingMessageId,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      user1Language: user1Language ?? this.user1Language,
      user2Language: user2Language ?? this.user2Language,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        messages,
        isListening,
        isUser1Active,
        isSpeaking,
        autoSpeak,
        errorMessage,
        currentConfidence,
        currentlyPlayingMessageId,
        supportedLanguages,
        user1Language,
        user2Language
      ];
}
