import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/speech_result.dart';
import '../../domain/repositories/speech_repository.dart';
import '../datasources/speech_datasource.dart';

class SpeechRepositoryImpl implements SpeechRepository {
  final SpeechDataSource _dataSource;

  SpeechRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, bool>> initializeSpeechRecognition() async {
    try {
      final result = await _dataSource.initializeSpeechToText();
      return Right(result);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } on PermissionException catch (e) {
      return Left(PermissionFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to initialize speech recognition: ${e.toString()}',
        code: 'INIT_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> initializeTextToSpeech() async {
    try {
      final result = await _dataSource.initializeTextToSpeech();
      return Right(result);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to initialize text-to-speech: ${e.toString()}',
        code: 'TTS_INIT_FAILED',
      ));
    }
  }

  @override
  Stream<Either<Failure, SpeechResult>> startListening({
    required String languageCode,
    bool partialResults = true,
  }) async* {
    try {
      // Check if speech recognition is available
      final isAvailable = await _dataSource.isSpeechRecognitionAvailable();
      if (!isAvailable) {
        yield Left(SpeechFailure.notAvailable());
        return;
      }

      // Check microphone permission
      final hasPermission = await _dataSource.checkMicrophonePermission();
      if (!hasPermission) {
        final permissionGranted =
            await _dataSource.requestMicrophonePermission();
        if (!permissionGranted) {
          yield Left(PermissionFailure.denied('microphone'));
          return;
        }
      }

      // Stream controller for results
      late StreamController<Either<Failure, SpeechResult>> streamController;
      streamController = StreamController<Either<Failure, SpeechResult>>();

      // Start listening
      await _dataSource.startListening(
        languageCode: languageCode,
        partialResults: partialResults,
        onResult: (speechResultModel) {
          final speechResult = speechResultModel.toEntity();
          streamController.add(Right(speechResult));

          // Close stream on final result
          if (speechResult.isFinal) {
            streamController.close();
          }
        },
        onError: (error) {
          final failure = SpeechFailure(
            message: error,
            code: 'SPEECH_ERROR',
          );
          streamController.add(Left(failure));
          streamController.close();
        },
      );

      // Yield results from stream
      await for (final result in streamController.stream) {
        yield result;
      }
    } on SpeechException catch (e) {
      yield Left(SpeechFailure.fromException(e));
    } on PermissionException catch (e) {
      yield Left(PermissionFailure.fromException(e));
    } catch (e) {
      yield Left(SpeechFailure(
        message: 'Failed to start listening: ${e.toString()}',
        code: 'START_LISTENING_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await _dataSource.stopListening();
      return const Right(null);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to stop listening: ${e.toString()}',
        code: 'STOP_LISTENING_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> speakText({
    required String text,
    required String languageCode,
    double rate = 0.5,
    double pitch = 1.0,
    double volume = 1.0,
  }) async {
    try {
      // Check if text-to-speech is available
      final isAvailable = await _dataSource.isTextToSpeechAvailable();
      if (!isAvailable) {
        return Left(SpeechFailure(
          message: 'Text-to-speech is not available',
          code: 'TTS_NOT_AVAILABLE',
        ));
      }

      await _dataSource.speakText(
        text: text,
        languageCode: languageCode,
        rate: rate,
        pitch: pitch,
        volume: volume,
      );

      return const Right(null);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to speak text: ${e.toString()}',
        code: 'SPEAK_TEXT_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> stopSpeaking() async {
    try {
      await _dataSource.stopSpeaking();
      return const Right(null);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to stop speaking: ${e.toString()}',
        code: 'STOP_SPEAKING_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isSpeechRecognitionAvailable() async {
    try {
      final result = await _dataSource.isSpeechRecognitionAvailable();
      return Right(result);
    } catch (e) {
      return Left(SpeechFailure(
        message:
            'Failed to check speech recognition availability: ${e.toString()}',
        code: 'CHECK_AVAILABILITY_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isTextToSpeechAvailable() async {
    try {
      final result = await _dataSource.isTextToSpeechAvailable();
      return Right(result);
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to check text-to-speech availability: ${e.toString()}',
        code: 'CHECK_TTS_AVAILABILITY_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableSpeechLanguages() async {
    try {
      final languages = await _dataSource.getAvailableSpeechLanguages();
      return Right(languages);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to get available speech languages: ${e.toString()}',
        code: 'GET_SPEECH_LANGUAGES_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableTTSLanguages() async {
    try {
      final languages = await _dataSource.getAvailableTTSLanguages();
      return Right(languages);
    } on SpeechException catch (e) {
      return Left(SpeechFailure.fromException(e));
    } catch (e) {
      return Left(SpeechFailure(
        message: 'Failed to get available TTS languages: ${e.toString()}',
        code: 'GET_TTS_LANGUAGES_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> checkMicrophonePermission() async {
    try {
      final result = await _dataSource.checkMicrophonePermission();
      return Right(result);
    } on PermissionException catch (e) {
      return Left(PermissionFailure.fromException(e));
    } catch (e) {
      return Left(PermissionFailure(
        message: 'Failed to check microphone permission: ${e.toString()}',
        permission: 'microphone',
        code: 'CHECK_PERMISSION_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> requestMicrophonePermission() async {
    try {
      final result = await _dataSource.requestMicrophonePermission();
      return Right(result);
    } on PermissionException catch (e) {
      return Left(PermissionFailure.fromException(e));
    } catch (e) {
      return Left(PermissionFailure(
        message: 'Failed to request microphone permission: ${e.toString()}',
        permission: 'microphone',
        code: 'REQUEST_PERMISSION_FAILED',
      ));
    }
  }

  @override
  String get speechStatus => _dataSource.speechStatus;

  @override
  bool get isListening => _dataSource.isListening;

  @override
  bool get isSpeaking => _dataSource.isSpeaking;
}
