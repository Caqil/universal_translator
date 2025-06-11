import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/translation.dart';
import '../repositories/translation_repository.dart';

class TranslateText implements UseCase<Translation, TranslateTextParams> {
  final TranslationRepository _repository;

  TranslateText(this._repository);

  @override
  Future<Either<Failure, Translation>> call(TranslateTextParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation.isLeft()) {
      return validation.fold(
          (failure) => Left(failure), (r) => throw Exception());
    }

    return await _repository.translateText(
      text: params.text,
      sourceLanguage: params.sourceLanguage,
      targetLanguage: params.targetLanguage,
    );
  }

  Either<Failure, void> _validateParams(TranslateTextParams params) {
    // Validate text
    final textValidation = Validators.translationText(params.text);
    if (!textValidation.isValid) {
      return Left(ValidationFailure.fromException(
          ValidationException.invalidInput(
              'text', textValidation.errorMessage!)));
    }

    // Validate source language
    final sourceLanguageValidation =
        Validators.languageCode(params.sourceLanguage);
    if (!sourceLanguageValidation.isValid) {
      return Left(ValidationFailure.fromException(
          ValidationException.invalidInput(
              'sourceLanguage', sourceLanguageValidation.errorMessage!)));
    }

    // Validate target language
    final targetLanguageValidation =
        Validators.languageCode(params.targetLanguage);
    if (!targetLanguageValidation.isValid) {
      return Left(ValidationFailure.fromException(
          ValidationException.invalidInput(
              'targetLanguage', targetLanguageValidation.errorMessage!)));
    }

    // Check if source and target are the same (excluding auto-detect)
    if (params.sourceLanguage == params.targetLanguage &&
        params.sourceLanguage != LanguageConstants.autoDetectCode) {
      return Left(ValidationFailure.invalidInput(
        'languages',
        'Source and target languages cannot be the same',
      ));
    }

    return const Right(null);
  }
}

/// Parameters for translate text use case
class TranslateTextParams extends Equatable {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslateTextParams({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [text, sourceLanguage, targetLanguage];
}
