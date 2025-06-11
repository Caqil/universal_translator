import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/speech_repository.dart';

class StopListening implements NoParamsUseCase<void> {
  final SpeechRepository _repository;

  StopListening(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await _repository.stopListening();
  }
}
