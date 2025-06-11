import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/language.dart';
import '../repositories/translation_repository.dart';

/// Use case for getting supported languages
@injectable
class GetSupportedLanguages implements NoParamsUseCase<List<Language>> {
  final TranslationRepository _repository;

  GetSupportedLanguages(this._repository);

  @override
  Future<Either<Failure, List<Language>>> call() async {
    return await _repository.getSupportedLanguages();
  }
}
