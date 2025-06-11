import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

@injectable
class SaveImage {
  final CameraRepository repository;

  SaveImage(this.repository);

  Future<Either<CameraFailure, String>> call(String imagePath) async {
    return await repository.saveImageToGallery(imagePath);
  }
}
