import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../translation/domain/usecases/translate_text.dart';
import '../../../translation/domain/usecases/get_supported_languages.dart';
import '../../../speech/domain/usecases/start_listening.dart';
import '../../../speech/domain/usecases/stop_listening.dart';
import '../../../speech/domain/usecases/text_to_speech.dart';
import '../../domain/usecases/start_conversation_usecase.dart';
import '../../domain/usecases/save_conversation_usecase.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/entities/conversation_session.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

@injectable
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final TranslateText _translateText;
  final GetSupportedLanguages _getSupportedLanguages;
  final StartListening _startListening;
  final StopListening _stopListening;
  final TextToSpeech _textToSpeech;
  final StartConversationUsecase _startConversationUsecase;
  final SaveConversationUsecase _saveConversationUsecase;
  final Uuid _uuid;

  StreamSubscription? _speechSubscription;
  Timer? _autoStopTimer;

  ConversationBloc(
    this._translateText,
    this._getSupportedLanguages,
    this._startListening,
    this._stopListening,
    this._textToSpeech,
    this._startConversationUsecase,
    this._saveConversationUsecase,
    this._uuid,
  ) : super(const ConversationState()) {
    on<InitializeConversationEvent>(_onInitializeConversation);
    on<StartConversationEvent>(_onStartConversation);
    on<UpdateLanguagesEvent>(_onUpdateLanguages);
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<ProcessVoiceInputEvent>(_onProcessVoiceInput);
    on<PlayMessageAudioEvent>(_onPlayMessageAudio);
    on<ToggleAutoSpeakEvent>(_onToggleAutoSpeak);
    on<SaveConversationEvent>(_onSaveConversation);
    on<EndConversationEvent>(_onEndConversation);
    on<RetryTranslationEvent>(_onRetryTranslation);

    // Internal events for stream handling
    on<_SpeechResultEvent>(_onSpeechResult);
    on<_SpeechErrorEvent>(_onSpeechError);
    on<_ConfidenceUpdateEvent>(_onConfidenceUpdate);
  }

  @override
  Future<void> close() {
    _speechSubscription?.cancel();
    _autoStopTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeConversation(
    InitializeConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Initializing conversation...');

    emit(state.copyWith(status: ConversationStatus.settingUp));

    try {
      // Get supported languages
      final result = await _getSupportedLanguages();

      result.fold(
        (failure) {
          print('🎯 Failed to get supported languages: ${failure.message}');
          emit(state.copyWith(
            status: ConversationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (languages) {
          print('🎯 Got ${languages.length} supported languages');
          emit(state.copyWith(
            status: ConversationStatus.initial,
            supportedLanguages: languages,
            user1Language: 'en',
            user2Language: 'es',
          ));

          // Auto-start conversation with default languages
          add(const StartConversationEvent(
            user1Language: 'en',
            user2Language: 'es',
            user1LanguageName: 'English',
            user2LanguageName: 'Spanish',
          ));
        },
      );
    } catch (e) {
      print('🎯 Initialize conversation error: $e');
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: 'Failed to initialize: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateLanguages(
    UpdateLanguagesEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print(
        '🎯 Updating languages: ${event.user1Language} ↔ ${event.user2Language}');

    emit(state.copyWith(
      user1Language: event.user1Language,
      user2Language: event.user2Language,
    ));

    // Get language names from supported languages
    final user1LanguageName = _getLanguageName(event.user1Language);
    final user2LanguageName = _getLanguageName(event.user2Language);

    // Restart conversation with new languages
    add(StartConversationEvent(
      user1Language: event.user1Language,
      user2Language: event.user2Language,
      user1LanguageName: user1LanguageName,
      user2LanguageName: user2LanguageName,
    ));
  }

  String _getLanguageName(String languageCode) {
    final language = state.supportedLanguages
        .where((lang) => lang.code == languageCode)
        .firstOrNull;
    return language?.name ?? languageCode.toUpperCase();
  }

  Future<void> _onStartConversation(
    StartConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print(
        '🎯 Starting conversation: ${event.user1LanguageName} ↔ ${event.user2LanguageName}');

    if (!emit.isDone) {
      emit(state.copyWith(status: ConversationStatus.settingUp));
    }

    try {
      final result = await _startConversationUsecase(StartConversationParams(
        user1Language: event.user1Language,
        user2Language: event.user2Language,
        user1LanguageName: event.user1LanguageName,
        user2LanguageName: event.user2LanguageName,
      ));

      result.fold(
        (failure) {
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.error,
              errorMessage: failure.message,
            ));
          }
        },
        (session) {
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.ready,
              session: session,
              messages: [],
              errorMessage: null,
            ));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ConversationStatus.error,
          errorMessage: 'Failed to start conversation: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (!state.canStartListening) return;

    print('🎯 Starting listening for User${event.isUser1 ? 1 : 2}');

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.listening,
        isListening: true,
        isUser1Active: event.isUser1,
        errorMessage: null,
      ));
    }

    try {
      final languageCode = event.isUser1
          ? state.session!.user1Language
          : state.session!.user2Language;

      _speechSubscription = _startListening(StartListeningParams(
        languageCode: languageCode,
        partialResults: true,
      )).listen(
        (result) {
          result.fold(
            (failure) {
              print('🎯 Speech error: ${failure.message}');
              add(_SpeechErrorEvent(failure.message));
            },
            (speechResult) {
              print(
                  '🎯 Speech result: ${speechResult.recognizedWords} (confidence: ${speechResult.confidence})');

              add(_ConfidenceUpdateEvent(speechResult.confidence));

              if (speechResult.isFinal &&
                  speechResult.recognizedWords.isNotEmpty) {
                add(_SpeechResultEvent(
                  recognizedText: speechResult.recognizedWords,
                  isUser1: event.isUser1,
                  confidence: speechResult.confidence,
                ));
              }
            },
          );
        },
        onError: (error) {
          print('🎯 Speech stream error: $error');
          add(_SpeechErrorEvent('Speech recognition error: $error'));
        },
        onDone: () {
          print('🎯 Speech stream completed');
          add(const StopListeningEvent());
        },
      );

      _autoStopTimer = Timer(const Duration(seconds: 30), () {
        print('🎯 Auto-stopping listening after 30 seconds');
        add(const StopListeningEvent());
      });
    } catch (e) {
      print('🎯 Error starting listening: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ConversationStatus.error,
          isListening: false,
          errorMessage: 'Failed to start listening: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onSpeechResult(
    _SpeechResultEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Processing speech result: ${event.recognizedText}');

    add(const StopListeningEvent());
    add(ProcessVoiceInputEvent(
      recognizedText: event.recognizedText,
      isUser1: event.isUser1,
      confidence: event.confidence,
    ));
  }

  Future<void> _onSpeechError(
    _SpeechErrorEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Handling speech error: ${event.errorMessage}');

    add(const StopListeningEvent());

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.error,
        errorMessage: event.errorMessage,
      ));
    }
  }

  Future<void> _onConfidenceUpdate(
    _ConfidenceUpdateEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.isListening && !emit.isDone) {
      emit(state.copyWith(currentConfidence: event.confidence));
    }
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Stopping listening');

    await _speechSubscription?.cancel();
    _speechSubscription = null;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    await _stopListening();

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.ready,
        isListening: false,
        currentConfidence: null,
      ));
    }
  }

  Future<void> _onProcessVoiceInput(
    ProcessVoiceInputEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Processing voice input: "${event.recognizedText}"');

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.processing,
        isListening: false,
      ));
    }

    try {
      final sourceLanguage = event.isUser1
          ? state.session!.user1Language
          : state.session!.user2Language;
      final targetLanguage = event.isUser1
          ? state.session!.user2Language
          : state.session!.user1Language;

      final translationResult = await _translateText(TranslateTextParams(
        text: event.recognizedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      ));

      await translationResult.fold(
        (failure) async {
          print('🎯 Translation failed: ${failure.message}');
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.error,
              errorMessage: failure.message,
            ));
          }
        },
        (translation) async {
          print('🎯 Translation successful: "${translation.translatedText}"');

          final message = ConversationMessage(
            id: _uuid.v4(),
            originalText: event.recognizedText,
            translatedText: translation.translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            isUser1: event.isUser1,
            timestamp: DateTime.now(),
            confidence: event.confidence,
            alternatives: translation.alternatives ?? [],
          );

          final updatedMessages = List<ConversationMessage>.from(state.messages)
            ..add(message);

          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.ready,
              messages: updatedMessages,
            ));
          }

          if (state.autoSpeak) {
            add(PlayMessageAudioEvent(message.id));
          }

          add(const SaveConversationEvent());
        },
      );
    } catch (e) {
      print('🎯 Process voice input error: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ConversationStatus.error,
          errorMessage: 'Translation failed: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onPlayMessageAudio(
    PlayMessageAudioEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final message = state.messages.firstWhere((m) => m.id == event.messageId);

    print('🎯 Playing audio: "${message.translatedText}"');

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.speaking,
        isSpeaking: true,
        currentlyPlayingMessageId: event.messageId,
      ));
    }

    try {
      final result = await _textToSpeech(TextToSpeechParams(
        text: message.translatedText,
        languageCode: message.targetLanguage,
        rate: 0.5,
        pitch: 1.0,
        volume: 1.0,
      ));

      result.fold(
        (failure) {
          print('🎯 TTS failed: ${failure.message}');
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.error,
              isSpeaking: false,
              currentlyPlayingMessageId: null,
              errorMessage: 'Speech playback failed: ${failure.message}',
            ));
          }
        },
        (_) {
          print('🎯 TTS completed successfully');
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.ready,
              isSpeaking: false,
              currentlyPlayingMessageId: null,
            ));
          }
        },
      );
    } catch (e) {
      print('🎯 TTS error: $e');
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ConversationStatus.error,
          isSpeaking: false,
          currentlyPlayingMessageId: null,
          errorMessage: 'Speech playback failed: ${e.toString()}',
        ));
      }
    }
  }

  void _onToggleAutoSpeak(
    ToggleAutoSpeakEvent event,
    Emitter<ConversationState> emit,
  ) {
    if (!emit.isDone) {
      emit(state.copyWith(autoSpeak: event.enabled));
    }
  }

  Future<void> _onSaveConversation(
    SaveConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state.session == null) return;

    try {
      final updatedSession = state.session!.copyWith(messages: state.messages);
      final result = await _saveConversationUsecase(updatedSession);

      result.fold(
        (failure) {
          print('🎯 Save conversation failed: ${failure.message}');
        },
        (_) {
          print('🎯 Conversation saved successfully');
        },
      );
    } catch (e) {
      print('🎯 Save conversation error: $e');
    }
  }

  Future<void> _onEndConversation(
    EndConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    print('🎯 Ending conversation');

    await _speechSubscription?.cancel();
    _autoStopTimer?.cancel();
    await _stopListening();

    if (state.hasMessages && state.session != null) {
      final endedSession = state.session!.copyWith(
        endTime: DateTime.now(),
        messages: state.messages,
      );
      await _saveConversationUsecase(endedSession);
    }

    if (!emit.isDone) {
      emit(state.copyWith(
        status: ConversationStatus.ended,
        isListening: false,
        isSpeaking: false,
      ));
    }
  }

  Future<void> _onRetryTranslation(
    RetryTranslationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final message = state.messages.firstWhere((m) => m.id == event.messageId);

    print('🎯 Retrying translation for: "${message.originalText}"');

    if (!emit.isDone) {
      emit(state.copyWith(status: ConversationStatus.processing));
    }

    try {
      final translationResult = await _translateText(TranslateTextParams(
        text: message.originalText,
        sourceLanguage: message.sourceLanguage,
        targetLanguage: message.targetLanguage,
      ));

      translationResult.fold(
        (failure) {
          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.error,
              errorMessage: failure.message,
            ));
          }
        },
        (translation) {
          final updatedMessage = message.copyWith(
            translatedText: translation.translatedText,
            alternatives: translation.alternatives ?? [],
          );

          final updatedMessages = state.messages
              .map((m) => m.id == event.messageId ? updatedMessage : m)
              .toList();

          if (!emit.isDone) {
            emit(state.copyWith(
              status: ConversationStatus.ready,
              messages: updatedMessages,
            ));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          status: ConversationStatus.error,
          errorMessage: 'Retry translation failed: ${e.toString()}',
        ));
      }
    }
  }
}

// Internal events
class _SpeechResultEvent extends ConversationEvent {
  final String recognizedText;
  final bool isUser1;
  final double confidence;

  const _SpeechResultEvent({
    required this.recognizedText,
    required this.isUser1,
    required this.confidence,
  });

  @override
  List<Object> get props => [recognizedText, isUser1, confidence];
}

class _SpeechErrorEvent extends ConversationEvent {
  final String errorMessage;

  const _SpeechErrorEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class _ConfidenceUpdateEvent extends ConversationEvent {
  final double confidence;

  const _ConfidenceUpdateEvent(this.confidence);

  @override
  List<Object> get props => [confidence];
}
