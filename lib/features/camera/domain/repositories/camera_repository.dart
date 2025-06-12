// lib/features/camera/domain/repositories/camera_repository.dart
import 'package:dartz/dartz.dart';
import 'package:camera/camera.dart';

import '../../../../core/error/failures.dart';
import '../entities/translation_result.dart';

abstract class CameraRepository {
  Future<Either<Failure, CameraController>> initializeCamera();
  Future<Either<Failure, String>> captureImage(CameraController controller);
  Future<Either<Failure, String?>> selectImageFromGallery();
  Future<Either<Failure, TranslationResult>> processImageForTranslation({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
  });
}
