import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/language_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/speech_repository.dart';

/// Use case for text-to-speech
@injectable
class TextToSpeech implements UseCase<void, TextToSpeechParams> {
  final SpeechRepository _repository;

  TextToSpeech(this._repository);

  @override
  Future<Either<Failure, void>> call(TextToSpeechParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation.isLeft()) {
      return validation.fold(
        (failure) => Left(failure),
        (r) => throw Exception(),
      );
    }

    // Check if text-to-speech is available
    final availabilityResult = await _repository.isTextToSpeechAvailable();
    if (availabilityResult.isLeft()) {
      return Left(availabilityResult.fold((l) => l, (r) => throw Exception()));
    }

    final isAvailable = availabilityResult.fold((l) => false, (r) => r);
    if (!isAvailable) {
      return Left(SpeechFailure(
        message: 'Text-to-speech is not available on this device',
        code: 'TTS_NOT_AVAILABLE',
      ));
    }

    // Perform text-to-speech
    return await _repository.speakText(
      text: params.text,
      languageCode: params.languageCode,
      rate: params.rate,
      pitch: params.pitch,
      volume: params.volume,
    );
  }

  Either<Failure, void> _validateParams(TextToSpeechParams params) {
    // Validate text
    final textValidation = Validators.requiredString(params.text, 'Text');
    if (!textValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'text',
          textValidation.errorMessage!,
        ),
      ));
    }

    // Validate text length
    final lengthValidation = Validators.stringLength(
      params.text,
      maxLength: 4000, // TTS usually has limits on text length
      fieldName: 'Text',
    );
    if (!lengthValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'text',
          lengthValidation.errorMessage!,
        ),
      ));
    }

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

    // Check if language supports text-to-speech
    if (!LanguageConstants.supportsTextToSpeech(params.languageCode)) {
      return Left(ValidationFailure.invalidInput(
        'languageCode',
        'Language "${params.languageCode}" does not support text-to-speech',
      ));
    }

    // Validate rate
    final rateValidation = Validators.numericRange(
      params.rate,
      min: 0.1,
      max: 2.0,
      fieldName: 'Speech rate',
    );
    if (!rateValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'rate',
          rateValidation.errorMessage!,
        ),
      ));
    }

    // Validate pitch
    final pitchValidation = Validators.numericRange(
      params.pitch,
      min: 0.5,
      max: 2.0,
      fieldName: 'Speech pitch',
    );
    if (!pitchValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'pitch',
          pitchValidation.errorMessage!,
        ),
      ));
    }

    // Validate volume
    final volumeValidation = Validators.numericRange(
      params.volume,
      min: 0.0,
      max: 1.0,
      fieldName: 'Speech volume',
    );
    if (!volumeValidation.isValid) {
      return Left(ValidationFailure.fromException(
        ValidationException.invalidInput(
          'volume',
          volumeValidation.errorMessage!,
        ),
      ));
    }

    return const Right(null);
  }
}

/// Parameters for text-to-speech use case
class TextToSpeechParams extends Equatable {
  /// Text to be spoken
  final String text;

  /// Language code for speech synthesis
  final String languageCode;

  /// Speech rate (0.1 to 2.0, default 0.5)
  final double rate;

  /// Speech pitch (0.5 to 2.0, default 1.0)
  final double pitch;

  /// Speech volume (0.0 to 1.0, default 1.0)
  final double volume;

  const TextToSpeechParams({
    required this.text,
    required this.languageCode,
    this.rate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  @override
  List<Object?> get props => [text, languageCode, rate, pitch, volume];
}
