// lib/features/conversation/presentation/bloc/conversation_event.dart
import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();
}

class StartConversationEvent extends ConversationEvent {
  final String user1Language;
  final String user2Language;
  final String user1LanguageName;
  final String user2LanguageName;

  const StartConversationEvent({
    required this.user1Language,
    required this.user2Language,
    required this.user1LanguageName,
    required this.user2LanguageName,
  });

  @override
  List<Object> get props =>
      [user1Language, user2Language, user1LanguageName, user2LanguageName];
}

class StartListeningEvent extends ConversationEvent {
  final bool isUser1; // which user is speaking

  const StartListeningEvent({required this.isUser1});

  @override
  List<Object> get props => [isUser1];
}

class StopListeningEvent extends ConversationEvent {
  const StopListeningEvent();

  @override
  List<Object> get props => [];
}

class ProcessVoiceInputEvent extends ConversationEvent {
  final String recognizedText;
  final bool isUser1;
  final double confidence;

  const ProcessVoiceInputEvent({
    required this.recognizedText,
    required this.isUser1,
    required this.confidence,
  });

  @override
  List<Object> get props => [recognizedText, isUser1, confidence];
}

class PlayMessageAudioEvent extends ConversationEvent {
  final String messageId;

  const PlayMessageAudioEvent(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ToggleAutoSpeakEvent extends ConversationEvent {
  final bool enabled;

  const ToggleAutoSpeakEvent(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class SaveConversationEvent extends ConversationEvent {
  const SaveConversationEvent();

  @override
  List<Object> get props => [];
}

class EndConversationEvent extends ConversationEvent {
  const EndConversationEvent();

  @override
  List<Object> get props => [];
}

class RetryTranslationEvent extends ConversationEvent {
  final String messageId;

  const RetryTranslationEvent(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class InitializeConversationEvent extends ConversationEvent {
  const InitializeConversationEvent();

  @override
  List<Object> get props => [];
}

class UpdateLanguagesEvent extends ConversationEvent {
  final String user1Language;
  final String user2Language;

  const UpdateLanguagesEvent({
    required this.user1Language,
    required this.user2Language,
  });

  @override
  List<Object> get props => [user1Language, user2Language];
}
