import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

@injectable
class GetAvailableCameras {
  final CameraRepository repository;

  GetAvailableCameras(this.repository);

  Future<Either<CameraFailure, List<CameraDescription>>> call() async {
    return await repository.getAvailableCameras();
  }
}
