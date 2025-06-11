// lib/features/camera/domain/usecases/initialize_camera.dart
import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

@injectable
class InitializeCamera {
  final CameraRepository repository;

  InitializeCamera(this.repository);

  Future<Either<CameraFailure, CameraController>> call(
    CameraDescription camera,
  ) async {
    return await repository.initializeCamera(camera);
  }
}
