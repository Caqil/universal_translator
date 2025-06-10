import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'network_info.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  DioClient(this._networkInfo) : _dio = Dio() {
    _initializeDio();
  }

  Dio get dio => _dio;

  void _initializeDio() {
    // Base configuration
    _dio.options = BaseOptions(
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        ApiConstants.contentTypeHeader: ApiConstants.applicationJsonValue,
        ApiConstants.acceptHeader: ApiConstants.applicationJsonValue,
        ApiConstants.userAgentHeader: ApiConstants.userAgentValue,
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _NetworkInterceptor(_networkInfo),
      _LoggingInterceptor(),
      _RetryInterceptor(_dio),
      _ErrorInterceptor(),
    ]);
  }

  /// Update base URL for LibreTranslate API
  void updateBaseUrl(String baseUrl) {
    final apiUrl = baseUrl.endsWith('/api/v1') ? baseUrl : '$baseUrl/api/v1';
    _dio.options.baseUrl = apiUrl;
  }

  /// Update API key for authentication
  void updateApiKey(String? apiKey) {
    if (apiKey != null && apiKey.isNotEmpty) {
      _dio.options.headers[ApiConstants.authorizationHeader] = 'Bearer $apiKey';
    } else {
      _dio.options.headers.remove(ApiConstants.authorizationHeader);
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and convert Dio errors to custom exceptions
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException.timeout();

        case DioExceptionType.connectionError:
          return NetworkException.connectionError(
              error.message ?? 'Connection error');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          final responseData = error.response?.data;

          if (responseData is Map<String, dynamic>) {
            return ServerException.fromResponse(
              statusCode: statusCode,
              response: responseData,
            );
          } else {
            return ServerException(
              message: 'Server error occurred',
              statusCode: statusCode,
            );
          }

        case DioExceptionType.cancel:
          return const NetworkException(
            message: 'Request was cancelled',
            code: 'REQUEST_CANCELLED',
          );

        case DioExceptionType.unknown:
        default:
          return NetworkException.connectionError(
            error.message ?? 'Unknown network error',
          );
      }
    }

    return ServerException(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Network connectivity interceptor
class _NetworkInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;

  _NetworkInterceptor(this._networkInfo);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!await _networkInfo.isConnected) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
      return;
    }
    handler.next(options);
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📝 Headers: ${options.headers}');
    if (options.data != null) {
      print('📦 Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('🔍 Query: ${options.queryParameters}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📄 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('💥 Message: ${err.message}');
    if (err.response?.data != null) {
      print('📄 Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

/// Retry interceptor for handling transient errors
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // Only retry for specific status codes and if we haven't exceeded max attempts
    if (statusCode != null &&
        ApiConstants.retryStatusCodes.contains(statusCode) &&
        _shouldRetry(err.requestOptions)) {
      try {
        print('🔄 Retrying request to ${err.requestOptions.path}');

        // Wait before retrying
        await Future.delayed(ApiConstants.retryDelay);

        // Increment retry count
        _incrementRetryCount(err.requestOptions);

        // Retry the request
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with original error
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(RequestOptions options) {
    final retryCount = _getRetryCount(options);
    return retryCount < ApiConstants.maxRetryAttempts;
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['retry_count'] as int? ?? 0;
  }

  void _incrementRetryCount(RequestOptions options) {
    final currentCount = _getRetryCount(options);
    options.extra['retry_count'] = currentCount + 1;
  }
}

/// Error interceptor for consistent error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add custom error handling logic here if needed
    // For now, just pass through the error
    handler.next(err);
  }
}
