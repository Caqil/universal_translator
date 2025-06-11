import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/ocr_result.dart';
import '../repositories/camera_repository.dart';

@injectable
class ProcessOcr {
  final CameraRepository repository;

  ProcessOcr(this.repository);

  Future<Either<OcrFailure, OcrResult>> call(String imagePath) async {
    return await repository.processImageForOcr(imagePath);
  }
}
