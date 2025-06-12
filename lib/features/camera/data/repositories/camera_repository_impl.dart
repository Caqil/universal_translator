import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:camera/camera.dart';

import '../../../../core/error/exceptions.dart' as ex;
import '../../../../core/error/failures.dart';
import '../../../translation/domain/repositories/translation_repository.dart';
import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_datasource.dart';
import '../datasources/ocr_datasource.dart';

@LazySingleton(as: CameraRepository)
class CameraRepositoryImpl implements CameraRepository {
  final CameraDataSource _cameraDataSource;
  final OcrDataSource _ocrDataSource;
  final TranslationRepository _translationRepository;

  CameraRepositoryImpl(
    this._cameraDataSource,
    this._ocrDataSource,
    this._translationRepository,
  );

  @override
  Future<Either<Failure, CameraController>> initializeCamera() async {
    try {
      final controller = await _cameraDataSource.initializeCamera();
      return Right(controller);
    } on ex.CameraException catch (e) {
      return Left(CameraFailure.fromException(e));
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> captureImage(
      CameraController controller) async {
    try {
      final imagePath = await _cameraDataSource.captureImage(controller);
      return Right(imagePath);
    } on ex.CameraException catch (e) {
      return Left(CameraFailure.fromException(e));
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> selectImageFromGallery() async {
    try {
      final imagePath = await _cameraDataSource.selectImageFromGallery();
      return Right(imagePath);
    } on ex.CameraException catch (e) {
      return Left(CameraFailure.fromException(e));
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TranslationResult>> processImageForTranslation({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Step 1: Extract text from image using OCR
      final recognizedTexts =
          await _ocrDataSource.recognizeTextFromImage(imagePath);

      if (recognizedTexts.isEmpty) {
        return Left(OcrFailure.noTextFound());
      }

      // Step 2: Translate the extracted texts
      final translatedTexts = <String>[];

      for (final text in recognizedTexts) {
        final translationResult = await _translationRepository.translateText(
          text: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );

        translationResult.fold(
          (failure) =>
              translatedTexts.add('Translation failed: ${failure.message}'),
          (translation) => translatedTexts.add(translation.translatedText),
        );
      }

      final result = TranslationResult(
        recognizedTexts: recognizedTexts,
        translatedTexts: translatedTexts,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.95, // You can implement confidence calculation
      );

      return Right(result);
    } on ex.OcrException catch (e) {
      return Left(OcrFailure.fromException(e));
    } on ex.TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }
}
