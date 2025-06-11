import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

@injectable
class CheckCameraPermission {
  final CameraRepository repository;

  CheckCameraPermission(this.repository);

  Future<Either<CameraFailure, bool>> call() async {
    return await repository.checkCameraPermission();
  }
}
