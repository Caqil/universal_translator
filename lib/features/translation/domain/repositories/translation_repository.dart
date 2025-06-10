import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/language.dart';
import '../entities/translation.dart';

/// Abstract repository for translation operations
abstract class TranslationRepository {
  /// Translate text from source to target language
  Future<Either<Failure, Translation>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Detect language of given text
  Future<Either<Failure, String>> detectLanguage(String text);

  /// Get supported languages
  Future<Either<Failure, List<Language>>> getSupportedLanguages();

  /// Get translation history
  Future<Either<Failure, List<Translation>>> getTranslationHistory({
    int? limit,
    int? offset,
  });

  /// Search translations
  Future<Either<Failure, List<Translation>>> searchTranslations(String query);

  /// Delete a translation
  Future<Either<Failure, void>> deleteTranslation(String id);

  /// Clear translation history
  Future<Either<Failure, void>> clearTranslationHistory();

  /// Toggle favorite status of a translation
  Future<Either<Failure, Translation>> toggleFavorite(String translationId);

  /// Get recent languages used
  Future<Either<Failure, List<String>>> getRecentLanguages();

  /// Get translation alternatives
  Future<Either<Failure, List<String>>> getTranslationAlternatives({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    int alternatives = 3,
  });
}
