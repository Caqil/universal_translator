import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/translation_repository.dart';

/// Use case for detecting language of text
@injectable
class DetectLanguage implements UseCase<String, DetectLanguageParams> {
  final TranslationRepository _repository;

  DetectLanguage(this._repository);

  @override
  Future<Either<Failure, String>> call(DetectLanguageParams params) async {
    // Validate input
    final validation = _validateParams(params);
    if (validation.isLeft()) {
      return validation.fold(
          (failure) => Left(failure), (r) => throw Exception());
    }

    return await _repository.detectLanguage(params.text);
  }

  Either<Failure, void> _validateParams(DetectLanguageParams params) {
    final textValidation = Validators.requiredString(params.text, 'Text');
    if (!textValidation.isValid) {
      return Left(ValidationFailure.fromException(
          ValidationException.invalidInput(
              'text', textValidation.errorMessage!)));
    }

    final lengthValidation = Validators.stringLength(
      params.text,
      minLength: 1,
      maxLength: 1000, // Limit for language detection
      fieldName: 'Text',
    );
    if (!lengthValidation.isValid) {
      return Left(ValidationFailure.fromException(
          ValidationException.invalidInput(
              'text', lengthValidation.errorMessage!)));
    }

    return const Right(null);
  }
}

/// Parameters for detect language use case
class DetectLanguageParams extends Equatable {
  final String text;

  const DetectLanguageParams({required this.text});

  @override
  List<Object?> get props => [text];
}
