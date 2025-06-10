import 'package:equatable/equatable.dart';

/// Base class for all speech events
abstract class SpeechEvent extends Equatable {
  const SpeechEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize speech services
class InitializeSpeechEvent extends SpeechEvent {
  const InitializeSpeechEvent();
}

/// Event to start listening for speech input
class StartListeningEvent extends SpeechEvent {
  final String languageCode;
  final bool partialResults;

  const StartListeningEvent({
    required this.languageCode,
    this.partialResults = true,
  });

  @override
  List<Object?> get props => [languageCode, partialResults];
}

/// Event to stop listening for speech input
class StopListeningEvent extends SpeechEvent {
  const StopListeningEvent();
}

/// Event to speak text using text-to-speech
class SpeakTextEvent extends SpeechEvent {
  final String text;
  final String languageCode;
  final double rate;
  final double pitch;
  final double volume;

  const SpeakTextEvent({
    required this.text,
    required this.languageCode,
    this.rate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  @override
  List<Object?> get props => [text, languageCode, rate, pitch, volume];
}

/// Event to stop text-to-speech
class StopSpeakingEvent extends SpeechEvent {
  const StopSpeakingEvent();
}

/// Event to check speech services availability
class CheckSpeechAvailabilityEvent extends SpeechEvent {
  const CheckSpeechAvailabilityEvent();
}

/// Event to check microphone permission
class CheckMicrophonePermissionEvent extends SpeechEvent {
  const CheckMicrophonePermissionEvent();
}

/// Event to request microphone permission
class RequestMicrophonePermissionEvent extends SpeechEvent {
  const RequestMicrophonePermissionEvent();
}

/// Event to get available speech languages
class GetAvailableSpeechLanguagesEvent extends SpeechEvent {
  const GetAvailableSpeechLanguagesEvent();
}

/// Event to get available TTS languages
class GetAvailableTTSLanguagesEvent extends SpeechEvent {
  const GetAvailableTTSLanguagesEvent();
}

/// Event to clear speech error
class ClearSpeechErrorEvent extends SpeechEvent {
  const ClearSpeechErrorEvent();
}

/// Event to reset speech state
class ResetSpeechStateEvent extends SpeechEvent {
  const ResetSpeechStateEvent();
}

/// Event to update speech settings
class UpdateSpeechSettingsEvent extends SpeechEvent {
  final double? rate;
  final double? pitch;
  final double? volume;
  final bool? partialResults;

  const UpdateSpeechSettingsEvent({
    this.rate,
    this.pitch,
    this.volume,
    this.partialResults,
  });

  @override
  List<Object?> get props => [rate, pitch, volume, partialResults];
}
