import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/start_listening.dart';
import '../../domain/usecases/stop_listening.dart';
import '../../domain/usecases/text_to_speech.dart';
import '../../domain/repositories/speech_repository.dart';
import 'speech_event.dart';
import 'speech_state.dart';

@injectable
class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  final StartListening _startListening;
  final StopListening _stopListening;
  final TextToSpeech _textToSpeech;
  final SpeechRepository _repository;

  StreamSubscription<dynamic>? _speechSubscription;
  DateTime? _sessionStartTime;

  SpeechBloc(
    this._startListening,
    this._stopListening,
    this._textToSpeech,
    this._repository,
  ) : super(const SpeechInitial()) {
    on<InitializeSpeechEvent>(_onInitializeSpeech);
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<SpeakTextEvent>(_onSpeakText);
    on<StopSpeakingEvent>(_onStopSpeaking);
    on<CheckSpeechAvailabilityEvent>(_onCheckSpeechAvailability);
    on<CheckMicrophonePermissionEvent>(_onCheckMicrophonePermission);
    on<RequestMicrophonePermissionEvent>(_onRequestMicrophonePermission);
    on<GetAvailableSpeechLanguagesEvent>(_onGetAvailableSpeechLanguages);
    on<GetAvailableTTSLanguagesEvent>(_onGetAvailableTTSLanguages);
    on<ClearSpeechErrorEvent>(_onClearSpeechError);
    on<ResetSpeechStateEvent>(_onResetSpeechState);
    on<UpdateSpeechSettingsEvent>(_onUpdateSpeechSettings);
  }

  @override
  Future<void> close() {
    _speechSubscription?.cancel();
    return super.close();
  }

  Future<void> _onInitializeSpeech(
    InitializeSpeechEvent event,
    Emitter<SpeechState> emit,
  ) async {
    emit(state.copyWith(
      status: SpeechStatus.initializing,
      errorMessage: null,
    ));

    try {
      // Initialize speech recognition
      final sttResult = await _repository.initializeSpeechRecognition();
      final isSttAvailable = sttResult.fold((l) => false, (r) => r);

      // Initialize text-to-speech
      final ttsResult = await _repository.initializeTextToSpeech();
      final isTtsAvailable = ttsResult.fold((l) => false, (r) => r);

      // Check microphone permission
      final permissionResult = await _repository.checkMicrophonePermission();
      final hasPermission = permissionResult.fold((l) => false, (r) => r);

      // Get available languages
      final speechLanguagesResult =
          await _repository.getAvailableSpeechLanguages();
      final speechLanguages =
          speechLanguagesResult.fold((l) => <String>[], (r) => r);

      final ttsLanguagesResult = await _repository.getAvailableTTSLanguages();
      final ttsLanguages = ttsLanguagesResult.fold((l) => <String>[], (r) => r);

      emit(state.copyWith(
        status: SpeechStatus.ready,
        isSpeechRecognitionAvailable: isSttAvailable,
        isTextToSpeechAvailable: isTtsAvailable,
        hasMicrophonePermission: hasPermission,
        availableSpeechLanguages: speechLanguages,
        availableTTSLanguages: ttsLanguages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to initialize speech services: ${e.toString()}',
      ));
    }
  }

  Future<void> _onStartListening(
    StartListeningEvent event,
    Emitter<SpeechState> emit,
  ) async {
    if (!state.canStartListening) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Cannot start listening in current state',
      ));
      return;
    }

    emit(state.copyWith(
      status: SpeechStatus.listening,
      languageCode: event.languageCode,
      partialResults: event.partialResults,
      recognizedText: '',
      confidence: 0.0,
      currentResult: null,
      errorMessage: null,
    ));

    _sessionStartTime = DateTime.now();

    try {
      await _speechSubscription?.cancel();

      _speechSubscription = _startListening(StartListeningParams(
        languageCode: event.languageCode,
        partialResults: event.partialResults,
      )).listen(
        (result) {
          result.fold(
            (failure) {
              if (!isClosed) {
                add(const StopListeningEvent());
                emit(state.copyWith(
                  status: SpeechStatus.error,
                  errorMessage: failure.message,
                ));
              }
            },
            (speechResult) {
              if (!isClosed) {
                final sessionDuration = _sessionStartTime != null
                    ? DateTime.now().difference(_sessionStartTime!)
                    : null;

                emit(state.copyWith(
                  status: speechResult.isFinal
                      ? SpeechStatus.completed
                      : SpeechStatus.listening,
                  currentResult: speechResult,
                  recognizedText: speechResult.recognizedWords,
                  confidence: speechResult.confidence,
                  sessionDuration: sessionDuration,
                ));

                if (speechResult.isFinal) {
                  _speechSubscription?.cancel();
                  _sessionStartTime = null;
                }
              }
            },
          );
        },
        onError: (error) {
          if (!isClosed) {
            add(const StopListeningEvent());
            emit(state.copyWith(
              status: SpeechStatus.error,
              errorMessage: error.toString(),
            ));
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to start listening: ${e.toString()}',
      ));
    }
  }

  Future<void> _onStopListening(
    StopListeningEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      await _speechSubscription?.cancel();
      _speechSubscription = null;

      final result = await _stopListening();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) {
          final sessionDuration = _sessionStartTime != null
              ? DateTime.now().difference(_sessionStartTime!)
              : null;

          emit(state.copyWith(
            status: state.hasRecognizedText
                ? SpeechStatus.completed
                : SpeechStatus.ready,
            sessionDuration: sessionDuration,
          ));

          _sessionStartTime = null;
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to stop listening: ${e.toString()}',
      ));
    }
  }
Future<void> _onSpeakText(
  SpeakTextEvent event,
  Emitter<SpeechState> emit,
) async {
  if (!state.canSpeak) {
    emit(state.copyWith(
      status: SpeechStatus.error,
      errorMessage: 'Cannot speak text in current state',
    ));
    return;
  }

  // Validate input text
  if (event.text.trim().isEmpty) {
    emit(state.copyWith(
      status: SpeechStatus.error,
      errorMessage: 'Cannot speak empty text',
    ));
    return;
  }

  // Set initial speaking state
  emit(state.copyWith(
    status: SpeechStatus.speaking,
    currentSpeechText: event.text,
    languageCode: event.languageCode,
    speechRate: event.rate,
    speechPitch: event.pitch,
    speechVolume: event.volume,
    errorMessage: null,
  ));

  try {
    final result = await _textToSpeech(TextToSpeechParams(
      text: event.text,
      languageCode: event.languageCode,
      rate: event.rate,
      pitch: event.pitch,
      volume: event.volume,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: SpeechStatus.error,
          errorMessage: failure.message,
          currentSpeechText: null,
        ));
      },
      (_) {
        // TTS started successfully, monitor for completion
        _monitorTTSCompletion(emit);
      },
    );
  } catch (e) {
    emit(state.copyWith(
      status: SpeechStatus.error,
      errorMessage: 'Failed to speak text: ${e.toString()}',
      currentSpeechText: null,
    ));
  }
}

/// Monitor TTS completion using periodic checks
void _monitorTTSCompletion(Emitter<SpeechState> emit) {
  Timer.periodic(const Duration(milliseconds: 200), (timer) {
    if (isClosed) {
      timer.cancel();
      return;
    }

    try {
      // Check if TTS is still speaking via repository getter
      final isSpeaking = _repository.isSpeaking;
      
      if (!isSpeaking && state.status == SpeechStatus.speaking) {
        // TTS has completed
        timer.cancel();
        emit(state.copyWith(
          status: SpeechStatus.ready,
          currentSpeechText: null,
        ));
      }
    } catch (e) {
      // Error occurred, assume completed
      timer.cancel();
      if (state.status == SpeechStatus.speaking) {
        emit(state.copyWith(
          status: SpeechStatus.ready,
          currentSpeechText: null,
        ));
      }
    }
  });

  // Safety timeout to prevent infinite monitoring (5 minutes)
  Timer(const Duration(minutes: 5), () {
    if (state.status == SpeechStatus.speaking) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Text-to-speech timed out',
        currentSpeechText: null,
      ));
    }
  });
}

  Future<void> _onStopSpeaking(
    StopSpeakingEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final result = await _repository.stopSpeaking();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) {
          emit(state.copyWith(
            status: SpeechStatus.ready,
            currentSpeechText: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to stop speaking: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckSpeechAvailability(
    CheckSpeechAvailabilityEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final sttResult = await _repository.isSpeechRecognitionAvailable();
      final isSttAvailable = sttResult.fold((l) => false, (r) => r);

      final ttsResult = await _repository.isTextToSpeechAvailable();
      final isTtsAvailable = ttsResult.fold((l) => false, (r) => r);

      emit(state.copyWith(
        isSpeechRecognitionAvailable: isSttAvailable,
        isTextToSpeechAvailable: isTtsAvailable,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to check speech availability: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckMicrophonePermission(
    CheckMicrophonePermissionEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final result = await _repository.checkMicrophonePermission();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (hasPermission) {
          emit(state.copyWith(
            hasMicrophonePermission: hasPermission,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to check microphone permission: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRequestMicrophonePermission(
    RequestMicrophonePermissionEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final result = await _repository.requestMicrophonePermission();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (hasPermission) {
          emit(state.copyWith(
            hasMicrophonePermission: hasPermission,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage:
            'Failed to request microphone permission: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGetAvailableSpeechLanguages(
    GetAvailableSpeechLanguagesEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final result = await _repository.getAvailableSpeechLanguages();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (languages) {
          emit(state.copyWith(
            availableSpeechLanguages: languages,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage:
            'Failed to get available speech languages: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGetAvailableTTSLanguages(
    GetAvailableTTSLanguagesEvent event,
    Emitter<SpeechState> emit,
  ) async {
    try {
      final result = await _repository.getAvailableTTSLanguages();
      result.fold(
        (failure) {
          emit(state.copyWith(
            status: SpeechStatus.error,
            errorMessage: failure.message,
          ));
        },
        (languages) {
          emit(state.copyWith(
            availableTTSLanguages: languages,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: SpeechStatus.error,
        errorMessage: 'Failed to get available TTS languages: ${e.toString()}',
      ));
    }
  }

  void _onClearSpeechError(
    ClearSpeechErrorEvent event,
    Emitter<SpeechState> emit,
  ) {
    emit(state.copyWith(
      status: SpeechStatus.ready,
      errorMessage: null,
    ));
  }

  void _onResetSpeechState(
    ResetSpeechStateEvent event,
    Emitter<SpeechState> emit,
  ) {
    _speechSubscription?.cancel();
    _speechSubscription = null;
    _sessionStartTime = null;

    emit(const SpeechInitial());
  }

  void _onUpdateSpeechSettings(
    UpdateSpeechSettingsEvent event,
    Emitter<SpeechState> emit,
  ) {
    emit(state.copyWith(
      speechRate: event.rate ?? state.speechRate,
      speechPitch: event.pitch ?? state.speechPitch,
      speechVolume: event.volume ?? state.speechVolume,
      partialResults: event.partialResults ?? state.partialResults,
    ));
  }
}
