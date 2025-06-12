import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:camera/camera.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

@injectable
class InitializeCameraUseCase implements UseCase<CameraController, NoParams> {
  final CameraRepository _repository;

  InitializeCameraUseCase(this._repository);

  @override
  Future<Either<Failure, CameraController>> call(NoParams params) async {
    return await _repository.initializeCamera();
  }
}
