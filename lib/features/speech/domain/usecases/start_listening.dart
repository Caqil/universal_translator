import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/language_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/speech_result.dart';
import '../repositories/speech_repository.dart';

class StartListening
    implements StreamUseCase<SpeechResult, StartListeningParams> {
  final SpeechRepository _repository;

  StartListening(this._repository);

  @override
  Stream<Either<Failure, SpeechResult>> call(
      StartListeningParams params) async* {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation.isLeft()) {
      yield validation.fold(
        (failure) => Left(failure),
        (r) => throw Exception(),
      );
      return;
    }

    // Check if speech recognition is available
    final availabilityResult = await _repository.isSpeechRecognitionAvailable();
    if (availabilityResult.isLeft()) {
      yield Left(availabilityResult.fold((l) => l, (r) => throw Exception()));
      return;
    }

    final isAvailable = availabilityResult.fold((l) => false, (r) => r);
    if (!isAvailable) {
      yield Left(SpeechFailure.notAvailable());
      return;
    }

    // Check microphone permission
    final permissionResult = await _repository.checkMicrophonePermission();
    if (permissionResult.isLeft()) {
      yield Left(permissionResult.fold((l) => l, (r) => throw Exception()));
      return;
    }

    final hasPermission = permissionResult.fold((l) => false, (r) => r);
    if (!hasPermission) {
      // Request permission
      final requestResult = await _repository.requestMicrophonePermission();
      if (requestResult.isLeft()) {
        yield Left(requestResult.fold((l) => l, (r) => throw Exception()));
        return;
      }

      final permissionGranted = requestResult.fold((l) => false, (r) => r);
      if (!permissionGranted) {
        yield Left(PermissionFailure.denied('microphone'));
        return;
      }
    }

    // Start listening and yield results
    yield* _repository.startListening(
      languageCode: params.languageCode,
      partialResults: params.partialResults,
    );
  }

  Either<Failure, void> _validateParams(StartListeningParams params) {
    // Validate language code
    final languageValidation = Validators.languageCode(params.languageCode);
    if (!languageValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'languageCode',
          languageValidation.errorMessage!,
        ),
      ));
    }

    // Check if language supports speech-to-text
    if (params.languageCode != 'auto' &&
        !LanguageConstants.supportsSpeechToText(params.languageCode)) {
      return Left(ValidationFailure.invalidInput(
        'languageCode',
        'Language "${params.languageCode}" does not support speech recognition',
      ));
    }

    return const Right(null);
  }
}

/// Parameters for start listening use case
class StartListeningParams extends Equatable {
  /// Language code for speech recognition
  final String languageCode;

  /// Whether to return partial results during recognition
  final bool partialResults;

  const StartListeningParams({
    required this.languageCode,
    this.partialResults = true,
  });

  @override
  List<Object?> get props => [languageCode, partialResults];
}
