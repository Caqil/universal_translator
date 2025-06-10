// lib/core/error/exceptions.dart
import '../constants/api_constants.dart';

/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when there's a server error
class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? response;

  const ServerException({
    required String message,
    String? code,
    this.statusCode,
    this.response,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory ServerException.fromResponse({
    required int statusCode,
    required Map<String, dynamic> response,
  }) {
    String message = 'Server error occurred';
    String? code;

    // Extract error message and code from response
    if (response.containsKey('error')) {
      final error = response['error'];
      if (error is String) {
        message = error;
      } else if (error is Map<String, dynamic>) {
        message = error['message'] ?? message;
        code = error['code'];
      }
    } else if (response.containsKey('message')) {
      message = response['message'];
    }

    // Map status codes to specific error codes
    switch (statusCode) {
      case ApiConstants.statusCodeBadRequest:
        code ??= ApiConstants.errorCodeInvalidRequest;
        break;
      case ApiConstants.statusCodeUnauthorized:
        code ??= ApiConstants.errorCodeInvalidApiKey;
        break;
      case ApiConstants.statusCodeTooManyRequests:
        code ??= ApiConstants.errorCodeRateLimitExceeded;
        break;
      case ApiConstants.statusCodeServiceUnavailable:
        code ??= ApiConstants.errorCodeServiceUnavailable;
        break;
    }

    return ServerException(
      message: message,
      code: code,
      statusCode: statusCode,
      response: response,
    );
  }

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  final String? originalError;

  const NetworkException({
    required String message,
    String? code,
    this.originalError,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection available',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timeout. Please try again',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.connectionError(String error) {
    return NetworkException(
      message: 'Connection error occurred',
      code: 'CONNECTION_ERROR',
      originalError: error,
    );
  }

  @override
  String toString() => 'NetworkException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Exception thrown when there's a cache/local storage error
class CacheException extends AppException {
  final String? operation;

  const CacheException({
    required String message,
    String? code,
    this.operation,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory CacheException.readError([String? details]) {
    return CacheException(
      message: 'Failed to read from local storage${details != null ? ': $details' : ''}',
      code: 'CACHE_READ_ERROR',
      operation: 'read',
    );
  }

  factory CacheException.writeError([String? details]) {
    return CacheException(
      message: 'Failed to write to local storage${details != null ? ': $details' : ''}',
      code: 'CACHE_WRITE_ERROR',
      operation: 'write',
    );
  }

  factory CacheException.deleteError([String? details]) {
    return CacheException(
      message: 'Failed to delete from local storage${details != null ? ': $details' : ''}',
      code: 'CACHE_DELETE_ERROR',
      operation: 'delete',
    );
  }

  factory CacheException.notFound() {
    return const CacheException(
      message: 'Requested data not found in cache',
      code: 'CACHE_NOT_FOUND',
      operation: 'read',
    );
  }

  @override
  String toString() => 'CacheException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// Exception thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory ValidationException.invalidInput(String field, String error) {
    return ValidationException(
      message: 'Validation failed for $field: $error',
      code: 'VALIDATION_ERROR',
      fieldErrors: {field: [error]},
    );
  }

  factory ValidationException.multipleErrors(Map<String, List<String>> errors) {
    final messages = errors.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('; ');
    
    return ValidationException(
      message: 'Validation failed: $messages',
      code: 'VALIDATION_ERROR',
      fieldErrors: errors,
    );
  }

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when there's a permission error
class PermissionException extends AppException {
  final String permission;

  const PermissionException({
    required String message,
    required this.permission,
    String? code,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory PermissionException.denied(String permission) {
    return PermissionException(
      message: '$permission permission is required',
      permission: permission,
      code: 'PERMISSION_DENIED',
    );
  }

  factory PermissionException.permanentlyDenied(String permission) {
    return PermissionException(
      message: '$permission permission is permanently denied. Please enable it in settings',
      permission: permission,
      code: 'PERMISSION_PERMANENTLY_DENIED',
    );
  }

  @override
  String toString() => 'PermissionException: $message (Permission: $permission)';
}

/// Exception thrown when there's a speech recognition error
class SpeechException extends AppException {
  final String? recognitionError;

  const SpeechException({
    required String message,
    String? code,
    this.recognitionError,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory SpeechException.notAvailable() {
    return const SpeechException(
      message: 'Speech recognition is not available on this device',
      code: 'SPEECH_NOT_AVAILABLE',
    );
  }

  factory SpeechException.notListening() {
    return const SpeechException(
      message: 'Speech recognition is not currently listening',
      code: 'SPEECH_NOT_LISTENING',
    );
  }

  factory SpeechException.recognitionFailed(String error) {
    return SpeechException(
      message: 'Speech recognition failed',
      code: 'SPEECH_RECOGNITION_FAILED',
      recognitionError: error,
    );
  }

  @override
  String toString() => 'SpeechException: $message${recognitionError != null ? ' ($recognitionError)' : ''}';
}

/// Exception thrown when there's a camera error
class CameraException extends AppException {
  final String? cameraError;

  const CameraException({
    required String message,
    String? code,
    this.cameraError,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory CameraException.notAvailable() {
    return const CameraException(
      message: 'Camera is not available on this device',
      code: 'CAMERA_NOT_AVAILABLE',
    );
  }

  factory CameraException.initializationFailed(String error) {
    return CameraException(
      message: 'Failed to initialize camera',
      code: 'CAMERA_INITIALIZATION_FAILED',
      cameraError: error,
    );
  }

  factory CameraException.captureFailed(String error) {
    return CameraException(
      message: 'Failed to capture image',
      code: 'CAMERA_CAPTURE_FAILED',
      cameraError: error,
    );
  }

  @override
  String toString() => 'CameraException: $message${cameraError != null ? ' ($cameraError)' : ''}';
}

/// Exception thrown when there's an OCR error
class OcrException extends AppException {
  final String? ocrError;

  const OcrException({
    required String message,
    String? code,
    this.ocrError,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory OcrException.processingFailed(String error) {
    return OcrException(
      message: 'Failed to process image for text recognition',
      code: 'OCR_PROCESSING_FAILED',
      ocrError: error,
    );
  }

  factory OcrException.noTextFound() {
    return const OcrException(
      message: 'No text found in the image',
      code: 'OCR_NO_TEXT_FOUND',
    );
  }

  factory OcrException.unsupportedFormat() {
    return const OcrException(
      message: 'Unsupported image format for text recognition',
      code: 'OCR_UNSUPPORTED_FORMAT',
    );
  }

  @override
  String toString() => 'OcrException: $message${ocrError != null ? ' ($ocrError)' : ''}';
}

/// Exception thrown when there's a translation-specific error
class TranslationException extends AppException {
  final String? sourceLanguage;
  final String? targetLanguage;

  const TranslationException({
    required String message,
    String? code,
    this.sourceLanguage,
    this.targetLanguage,
    dynamic data,
  }) : super(message: message, code: code, data: data);

  factory TranslationException.languageNotSupported(String language) {
    return TranslationException(
      message: 'Language "$language" is not supported',
      code: ApiConstants.errorCodeLanguageNotSupported,
      sourceLanguage: language,
    );
  }

  factory TranslationException.textTooLong(int maxLength) {
    return TranslationException(
      message: 'Text is too long. Maximum length is $maxLength characters',
      code: ApiConstants.errorCodeTextTooLong,
    );
  }

  factory TranslationException.emptyText() {
    return const TranslationException(
      message: 'No text provided for translation',
      code: 'EMPTY_TEXT',
    );
  }

  factory TranslationException.sameLanguage() {
    return const TranslationException(
      message: 'Source and target languages are the same',
      code: 'SAME_LANGUAGE',
    );
  }

  @override
  String toString() => 'TranslationException: $message';
}
