import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_repository.dart';

/// Use case for stopping speech recognition
@injectable
class StopListening implements NoParamsUseCase<void> {
  final SpeechRepository _repository;

  StopListening(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await _repository.stopListening();
  }
}
