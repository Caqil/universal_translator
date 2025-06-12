import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/download_status.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/ml_kit_translation_datasource.dart';
import '../datasources/translation_local_datasource.dart';
import '../datasources/translation_remote_datasource.dart';
import '../models/translation_mode_model.dart';

/// Implementation of translation repository
@LazySingleton(as: TranslationRepository)
class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource _remoteDataSource;
  final TranslationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final MLKitTranslationDataSource _mlKitDataSource;
  TranslationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._mlKitDataSource,
  );
  @override
  Future<Either<Failure, Translation>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    TranslationMode mode = TranslationMode.auto,
  }) async {
    try {
      switch (mode) {
        case TranslationMode.offline:
          return await _translateOffline(text, sourceLanguage, targetLanguage);

        case TranslationMode.online:
          return await _translateOnline(text, sourceLanguage, targetLanguage);

        case TranslationMode.auto:
          // Try offline first if models are available, then online
          final isConnected = await _networkInfo.isConnected;
          final hasOfflineModels = await _mlKitDataSource
                  .isLanguageModelDownloaded(sourceLanguage) &&
              await _mlKitDataSource.isLanguageModelDownloaded(targetLanguage);

          if (hasOfflineModels) {
            final offlineResult =
                await _translateOffline(text, sourceLanguage, targetLanguage);
            if (offlineResult.isRight()) return offlineResult;
          }

          if (isConnected) {
            return await _translateOnline(text, sourceLanguage, targetLanguage);
          } else {
            return Left(NetworkFailure.noConnection());
          }
      }
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error occurred during translation',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  Future<Either<Failure, Translation>> _translateOffline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final translationModel = await _mlKitDataSource.translateTextOffline(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      // Cache the translation
      await _localDataSource.cacheTranslation(translationModel);

      return Right(translationModel.toEntity());
    } on TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } catch (e) {
      return Left(TranslationFailure(
        message: 'Offline translation failed: ${e.toString()}',
        code: 'OFFLINE_TRANSLATION_ERROR',
      ));
    }
  }

  Future<Either<Failure, Translation>> _translateOnline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
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
    }
  }

  @override
  Future<Either<Failure, DownloadStatus>> downloadLanguageModel(
      String languageCode) async {
    try {
      final downloadStatus =
          await _mlKitDataSource.downloadLanguageModel(languageCode);
      return Right(downloadStatus.toEntity());
    } on TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } catch (e) {
      return Left(TranslationFailure(
        message: 'Download failed: ${e.toString()}',
        code: 'DOWNLOAD_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLanguageModel(String languageCode) async {
    try {
      final success = await _mlKitDataSource.deleteLanguageModel(languageCode);
      return Right(success);
    } on TranslationException catch (e) {
      return Left(TranslationFailure.fromException(e));
    } catch (e) {
      return Left(TranslationFailure(
        message: 'Delete failed: ${e.toString()}',
        code: 'DELETE_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<DownloadStatus>>> getDownloadedLanguages() async {
    try {
      final downloadedModels = await _mlKitDataSource.getDownloadedLanguages();
      final entities =
          downloadedModels.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(TranslationFailure(
        message: 'Failed to get downloaded languages: ${e.toString()}',
        code: 'GET_DOWNLOADED_ERROR',
      ));
    }
  }

  @override
  Stream<Either<Failure, DownloadStatus>> getDownloadProgress(
      String languageCode) {
    try {
      return _mlKitDataSource
          .getDownloadProgress(languageCode)
          .map((status) => Right<Failure, DownloadStatus>(status.toEntity()))
          .handleError((error) => Left<Failure, DownloadStatus>(
                TranslationFailure(
                  message: 'Download progress error: ${error.toString()}',
                  code: 'DOWNLOAD_PROGRESS_ERROR',
                ),
              ));
    } catch (e) {
      return Stream.value(Left(TranslationFailure(
        message: 'Failed to get download progress: ${e.toString()}',
        code: 'DOWNLOAD_PROGRESS_ERROR',
      )));
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
    } on CacheException {
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
