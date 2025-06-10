import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/speech_result.dart';

/// Abstract repository for speech operations
abstract class SpeechRepository {
  /// Initialize speech recognition
  Future<Either<Failure, bool>> initializeSpeechRecognition();

  /// Initialize text-to-speech
  Future<Either<Failure, bool>> initializeTextToSpeech();

  /// Start listening for speech input
  /// Returns a stream of speech recognition results
  Stream<Either<Failure, SpeechResult>> startListening({
    required String languageCode,
    bool partialResults = true,
  });

  /// Stop listening for speech input
  Future<Either<Failure, void>> stopListening();

  /// Speak text using text-to-speech
  Future<Either<Failure, void>> speakText({
    required String text,
    required String languageCode,
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
  });

  /// Stop text-to-speech
  Future<Either<Failure, void>> stopSpeaking();

  /// Check if speech recognition is available
  Future<Either<Failure, bool>> isSpeechRecognitionAvailable();

  /// Check if text-to-speech is available
  Future<Either<Failure, bool>> isTextToSpeechAvailable();

  /// Get available speech recognition languages
  Future<Either<Failure, List<String>>> getAvailableSpeechLanguages();

  /// Get available text-to-speech languages
  Future<Either<Failure, List<String>>> getAvailableTTSLanguages();

  /// Check microphone permission status
  Future<Either<Failure, bool>> checkMicrophonePermission();

  /// Request microphone permission
  Future<Either<Failure, bool>> requestMicrophonePermission();

  /// Get current speech recognition status
  String get speechStatus;

  /// Check if currently listening
  bool get isListening;

  /// Check if currently speaking
  bool get isSpeaking;
}
