import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:camera/camera.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

@injectable
class CaptureImageUseCase implements UseCase<String, CameraController> {
  final CameraRepository _repository;

  CaptureImageUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(CameraController params) async {
    return await _repository.captureImage(params);
  }
}
