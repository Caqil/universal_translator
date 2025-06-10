import 'package:equatable/equatable.dart';
import 'exceptions.dart';

/// Base failure class for domain layer error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic data;

  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Failure representing server-related errors
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
    super.data,
  });

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(
      message: exception.message,
      code: exception.code,
      statusCode: exception.statusCode,
      data: exception.data,
    );
  }

  @override
  List<Object?> get props => [message, code, data, statusCode];

  @override
  String toString() =>
      'ServerFailure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Failure representing network connectivity errors
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: exception.code,
      data: exception.data,
    );
  }

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
      message: 'No internet connection available',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
      message: 'Request timeout. Please try again',
      code: 'TIMEOUT',
    );
  }

  @override
  String toString() => 'NetworkFailure: $message';
}

/// Failure representing cache/local storage errors
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory CacheFailure.fromException(CacheException exception) {
    return CacheFailure(
      message: exception.message,
      code: exception.code,
      data: exception.data,
    );
  }

  factory CacheFailure.notFound() {
    return const CacheFailure(
      message: 'Requested data not found in local storage',
      code: 'CACHE_NOT_FOUND',
    );
  }

  @override
  String toString() => 'CacheFailure: $message';
}

/// Failure representing validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
    super.data,
  });

  factory ValidationFailure.fromException(ValidationException exception) {
    return ValidationFailure(
      message: exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
      data: exception.data,
    );
  }

  factory ValidationFailure.invalidInput(String field, String error) {
    return ValidationFailure(
      message: 'Validation failed for $field: $error',
      code: 'VALIDATION_ERROR',
      fieldErrors: {
        field: [error]
      },
    );
  }

  @override
  List<Object?> get props => [message, code, data, fieldErrors];

  @override
  String toString() => 'ValidationFailure: $message';
}

/// Failure representing permission errors
class PermissionFailure extends Failure {
  final String permission;

  const PermissionFailure({
    required super.message,
    required this.permission,
    super.code,
    super.data,
  });

  factory PermissionFailure.fromException(PermissionException exception) {
    return PermissionFailure(
      message: exception.message,
      code: exception.code,
      permission: exception.permission,
      data: exception.data,
    );
  }

  factory PermissionFailure.denied(String permission) {
    return PermissionFailure(
      message: '$permission permission is required',
      permission: permission,
      code: 'PERMISSION_DENIED',
    );
  }

  @override
  List<Object?> get props => [message, code, data, permission];

  @override
  String toString() => 'PermissionFailure: $message (Permission: $permission)';
}

/// Failure representing speech recognition errors
class SpeechFailure extends Failure {
  const SpeechFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory SpeechFailure.fromException(SpeechException exception) {
    return SpeechFailure(
      message: exception.message,
      code: exception.code,
      data: exception.data,
    );
  }

  factory SpeechFailure.notAvailable() {
    return const SpeechFailure(
      message: 'Speech recognition is not available',
      code: 'SPEECH_NOT_AVAILABLE',
    );
  }

  @override
  String toString() => 'SpeechFailure: $message';
}

/// Failure representing camera errors
class CameraFailure extends Failure {
  const CameraFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory CameraFailure.fromException(CameraException exception) {
    return CameraFailure(
      message: exception.message,
      code: exception.code,
      data: exception.data,
    );
  }

  factory CameraFailure.notAvailable() {
    return const CameraFailure(
      message: 'Camera is not available',
      code: 'CAMERA_NOT_AVAILABLE',
    );
  }

  @override
  String toString() => 'CameraFailure: $message';
}

/// Failure representing OCR errors
class OcrFailure extends Failure {
  const OcrFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory OcrFailure.fromException(OcrException exception) {
    return OcrFailure(
      message: exception.message,
      code: exception.code,
      data: exception.data,
    );
  }

  factory OcrFailure.noTextFound() {
    return const OcrFailure(
      message: 'No text found in the image',
      code: 'OCR_NO_TEXT_FOUND',
    );
  }

  @override
  String toString() => 'OcrFailure: $message';
}

/// Failure representing translation-specific errors
class TranslationFailure extends Failure {
  final String? sourceLanguage;
  final String? targetLanguage;

  const TranslationFailure({
    required super.message,
    super.code,
    this.sourceLanguage,
    this.targetLanguage,
    super.data,
  });

  factory TranslationFailure.fromException(TranslationException exception) {
    return TranslationFailure(
      message: exception.message,
      code: exception.code,
      sourceLanguage: exception.sourceLanguage,
      targetLanguage: exception.targetLanguage,
      data: exception.data,
    );
  }

  factory TranslationFailure.languageNotSupported(String language) {
    return TranslationFailure(
      message: 'Language "$language" is not supported',
      code: 'LANGUAGE_NOT_SUPPORTED',
      sourceLanguage: language,
    );
  }

  factory TranslationFailure.emptyText() {
    return const TranslationFailure(
      message: 'No text provided for translation',
      code: 'EMPTY_TEXT',
    );
  }

  @override
  List<Object?> get props =>
      [message, code, data, sourceLanguage, targetLanguage];

  @override
  String toString() => 'TranslationFailure: $message';
}

/// Utility class to convert exceptions to failures
class FailureConverter {
  static Failure fromException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure.fromException(exception);
    } else if (exception is NetworkException) {
      return NetworkFailure.fromException(exception);
    } else if (exception is CacheException) {
      return CacheFailure.fromException(exception);
    } else if (exception is ValidationException) {
      return ValidationFailure.fromException(exception);
    } else if (exception is PermissionException) {
      return PermissionFailure.fromException(exception);
    } else if (exception is SpeechException) {
      return SpeechFailure.fromException(exception);
    } else if (exception is CameraException) {
      return CameraFailure.fromException(exception);
    } else if (exception is OcrException) {
      return OcrFailure.fromException(exception);
    } else if (exception is TranslationException) {
      return TranslationFailure.fromException(exception);
    } else {
      return ServerFailure(
        message: exception.toString(),
        code: 'UNKNOWN_ERROR',
      );
    }
  }
}
