import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/translation_result.dart';
import '../repositories/camera_repository.dart';

class ProcessImageForTranslationParams extends Equatable {
  final String imagePath;
  final String sourceLanguage;
  final String targetLanguage;

  const ProcessImageForTranslationParams({
    required this.imagePath,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [imagePath, sourceLanguage, targetLanguage];
}

@injectable
class ProcessImageForTranslationUseCase
    implements UseCase<TranslationResult, ProcessImageForTranslationParams> {
  final CameraRepository _repository;

  ProcessImageForTranslationUseCase(this._repository);

  @override
  Future<Either<Failure, TranslationResult>> call(
    ProcessImageForTranslationParams params,
  ) async {
    return await _repository.processImageForTranslation(
      imagePath: params.imagePath,
      sourceLanguage: params.sourceLanguage,
      targetLanguage: params.targetLanguage,
    );
  }
}
