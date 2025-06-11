import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

@injectable
class RequestCameraPermission {
  final CameraRepository repository;

  RequestCameraPermission(this.repository);

  Future<Either<CameraFailure, bool>> call() async {
    return await repository.requestCameraPermission();
  }
}
