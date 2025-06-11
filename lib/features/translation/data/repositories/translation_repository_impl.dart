import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_local_datasource.dart';
import '../datasources/translation_remote_datasource.dart';

/// Implementation of translation repository
@LazySingleton(as: TranslationRepository)
class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource _remoteDataSource;
  final TranslationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TranslationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, Translation>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      // Perform translation
      final translationModel = await _remoteDataSource.translateText(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      // Cache the translation
      await _localDataSource.cacheTranslation(translationModel);

      return Right(translationModel.toEntity());
    } on TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on CacheException catch (e) {
      // Don't fail the translation if caching fails
      print('Warning: Failed to cache translation: ${e.message}');

      try {
        // Try to get the translation without caching
        final translationModel = await _remoteDataSource.translateText(
          text: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        return Right(translationModel.toEntity());
      } catch (e) {
        return Left(CacheFailure.fromException(e as CacheException));
      }
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error occurred during translation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> detectLanguage(String text) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      final detectedLanguage = await _remoteDataSource.detectLanguage(text);
      return Right(detectedLanguage);
    } on TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error occurred during language detection',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Language>>> getSupportedLanguages() async {
    try {
      // Try to get cached languages first
      final cachedLanguages = await _localDataSource.getCachedLanguages();
      if (cachedLanguages.isNotEmpty) {
        return Right(cachedLanguages.map((model) => model.toEntity()).toList());
      }

      // Check network connectivity for fresh data
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      // Get fresh languages from API
      final languages = await _remoteDataSource.getSupportedLanguages();

      // Cache the languages
      await _localDataSource.cacheLanguages(languages);

      return Right(languages.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on CacheException catch (e) {
      // If caching fails, still return the data
      try {
        if (await _networkInfo.isConnected) {
          final languages = await _remoteDataSource.getSupportedLanguages();
          return Right(languages.map((model) => model.toEntity()).toList());
        } else {
          return Left(NetworkFailure.noConnection());
        }
      } catch (e) {
        return Left(CacheFailure.fromException(e as CacheException));
      }
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error occurred while getting supported languages',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Translation>>> getTranslationHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final translations = await _localDataSource.getTranslationHistory(
        limit: limit,
        offset: offset,
      );
      return Right(translations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting translation history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Translation>>> searchTranslations(
      String query) async {
    try {
      final translations = await _localDataSource.searchTranslations(query);
      return Right(translations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while searching translations',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTranslation(String id) async {
    try {
      await _localDataSource.deleteTranslation(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while deleting translation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearTranslationHistory() async {
    try {
      await _localDataSource.clearAllTranslations();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while clearing translation history',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Translation>> toggleFavorite(
      String translationId) async {
    try {
      final translation =
          await _localDataSource.getCachedTranslation(translationId);
      if (translation == null) {
        return Left(CacheFailure.notFound());
      }

      final updatedTranslation = translation.copyWith(
        isFavorite: !translation.isFavorite,
      );

      await _localDataSource.cacheTranslation(updatedTranslation);
      return Right(updatedTranslation.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while toggling favorite',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecentLanguages() async {
    try {
      final recentLanguages = await _localDataSource.getRecentLanguages();
      return Right(recentLanguages);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Unexpected error occurred while getting recent languages',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTranslationAlternatives({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    int alternatives = 3,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      final alternativesList =
          await _remoteDataSource.getTranslationAlternatives(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        alternatives: alternatives,
      );

      return Right(alternativesList);
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(ServerFailure(
        message:
            'Unexpected error occurred while getting translation alternatives',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }
}
