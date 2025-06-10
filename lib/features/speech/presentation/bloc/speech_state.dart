import 'package:equatable/equatable.dart';

import '../../domain/entities/speech_result.dart';

/// Speech recognition status enum
enum SpeechStatus {
  initial,
  initializing,
  ready,
  listening,
  processing,
  completed,
  speaking,
  error,
}

/// Speech state
class SpeechState extends Equatable {
  /// Current speech status
  final SpeechStatus status;

  /// Whether speech recognition is available
  final bool isSpeechRecognitionAvailable;

  /// Whether text-to-speech is available
  final bool isTextToSpeechAvailable;

  /// Whether microphone permission is granted
  final bool hasMicrophonePermission;

  /// Current speech recognition result
  final SpeechResult? currentResult;

  /// Latest recognized text
  final String recognizedText;

  /// Recognition confidence score
  final double confidence;

  /// Current language code being used
  final String languageCode;

  /// Available speech recognition languages
  final List<String> availableSpeechLanguages;

  /// Available text-to-speech languages
  final List<String> availableTTSLanguages;

  /// Whether partial results are enabled
  final bool partialResults;

  /// Speech rate for TTS (0.1 to 2.0)
  final double speechRate;

  /// Speech pitch for TTS (0.5 to 2.0)
  final double speechPitch;

  /// Speech volume for TTS (0.0 to 1.0)
  final double speechVolume;

  /// Current error message
  final String? errorMessage;

  /// Text currently being spoken
  final String? currentSpeechText;

  /// Duration of current speech session
  final Duration? sessionDuration;

  const SpeechState({
    this.status = SpeechStatus.initial,
    this.isSpeechRecognitionAvailable = false,
    this.isTextToSpeechAvailable = false,
    this.hasMicrophonePermission = false,
    this.currentResult,
    this.recognizedText = '',
    this.confidence = 0.0,
    this.languageCode = 'en',
    this.availableSpeechLanguages = const [],
    this.availableTTSLanguages = const [],
    this.partialResults = true,
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.speechVolume = 1.0,
    this.errorMessage,
    this.currentSpeechText,
    this.sessionDuration,
  });

  /// Copy with new values
  SpeechState copyWith({
    SpeechStatus? status,
    bool? isSpeechRecognitionAvailable,
    bool? isTextToSpeechAvailable,
    bool? hasMicrophonePermission,
    SpeechResult? currentResult,
    String? recognizedText,
    double? confidence,
    String? languageCode,
    List<String>? availableSpeechLanguages,
    List<String>? availableTTSLanguages,
    bool? partialResults,
    double? speechRate,
    double? speechPitch,
    double? speechVolume,
    String? errorMessage,
    String? currentSpeechText,
    Duration? sessionDuration,
  }) {
    return SpeechState(
      status: status ?? this.status,
      isSpeechRecognitionAvailable:
          isSpeechRecognitionAvailable ?? this.isSpeechRecognitionAvailable,
      isTextToSpeechAvailable:
          isTextToSpeechAvailable ?? this.isTextToSpeechAvailable,
      hasMicrophonePermission:
          hasMicrophonePermission ?? this.hasMicrophonePermission,
      currentResult: currentResult ?? this.currentResult,
      recognizedText: recognizedText ?? this.recognizedText,
      confidence: confidence ?? this.confidence,
      languageCode: languageCode ?? this.languageCode,
      availableSpeechLanguages:
          availableSpeechLanguages ?? this.availableSpeechLanguages,
      availableTTSLanguages:
          availableTTSLanguages ?? this.availableTTSLanguages,
      partialResults: partialResults ?? this.partialResults,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      speechVolume: speechVolume ?? this.speechVolume,
      errorMessage: errorMessage,
      currentSpeechText: currentSpeechText,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isSpeechRecognitionAvailable,
        isTextToSpeechAvailable,
        hasMicrophonePermission,
        currentResult,
        recognizedText,
        confidence,
        languageCode,
        availableSpeechLanguages,
        availableTTSLanguages,
        partialResults,
        speechRate,
        speechPitch,
        speechVolume,
        errorMessage,
        currentSpeechText,
        sessionDuration,
      ];
}

/// Initial speech state
class SpeechInitial extends SpeechState {
  const SpeechInitial() : super();
}

/// Speech state convenience getters
extension SpeechStateX on SpeechState {
  /// Whether speech services are being initialized
  bool get isInitializing => status == SpeechStatus.initializing;

  /// Whether currently listening for speech
  bool get isListening => status == SpeechStatus.listening;

  /// Whether currently speaking text
  bool get isSpeaking => status == SpeechStatus.speaking;

  /// Whether speech processing is in progress
  bool get isProcessing => status == SpeechStatus.processing;

  /// Whether speech services are ready to use
  bool get isReady => status == SpeechStatus.ready;

  /// Whether there's an error
  bool get hasError => status == SpeechStatus.error;

  /// Whether speech session is completed
  bool get isCompleted => status == SpeechStatus.completed;

  /// Whether speech services are available
  bool get isAvailable =>
      isSpeechRecognitionAvailable || isTextToSpeechAvailable;

  /// Whether can start listening
  bool get canStartListening =>
      isReady &&
      isSpeechRecognitionAvailable &&
      hasMicrophonePermission &&
      !isListening &&
      !isSpeaking;

  /// Whether can stop listening
  bool get canStopListening => isListening;

  /// Whether can speak text
  bool get canSpeak =>
      isReady && isTextToSpeechAvailable && !isSpeaking && !isListening;

  /// Whether can stop speaking
  bool get canStopSpeaking => isSpeaking;

  /// Whether has recognized text
  bool get hasRecognizedText => recognizedText.isNotEmpty;

  /// Whether recognition has high confidence
  bool get hasHighConfidence => confidence >= 0.8;

  /// Whether recognition has medium confidence
  bool get hasMediumConfidence => confidence >= 0.5 && confidence < 0.8;

  /// Whether recognition has low confidence
  bool get hasLowConfidence => confidence < 0.5;

  /// Get confidence as percentage
  int get confidencePercentage => (confidence * 100).round();

  /// Get confidence level description
  String get confidenceLevel {
    if (hasHighConfidence) return 'High';
    if (hasMediumConfidence) return 'Medium';
    return 'Low';
  }

  /// Get formatted session duration
  String? get formattedSessionDuration {
    if (sessionDuration == null) return null;

    final seconds = sessionDuration!.inSeconds;
    final minutes = sessionDuration!.inMinutes;

    if (minutes > 0) {
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Check if language supports speech recognition
  bool supportsSTT(String languageCode) {
    return availableSpeechLanguages.contains(languageCode) ||
        availableSpeechLanguages.any((lang) => lang.startsWith(languageCode));
  }

  /// Check if language supports text-to-speech
  bool supportsTTS(String languageCode) {
    return availableTTSLanguages.contains(languageCode) ||
        availableTTSLanguages.any((lang) => lang.startsWith(languageCode));
  }
}
