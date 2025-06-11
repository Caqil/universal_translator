// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  final Dio _dio;
  String? _apiKey;

  DioClient() : _dio = Dio() {
    _initializeDio();
  }

  Dio get dio => _dio;

  void _initializeDio() {
    _dio.options = BaseOptions(
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _NetworkInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  /// Update base URL for LibreTranslate API
  void updateBaseUrl(String baseUrl) {
    final cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    _dio.options.baseUrl = cleanUrl;
  }

  /// Update API key for authentication
  void updateApiKey(String? apiKey) {
    _apiKey = apiKey;
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request with API key in body
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // Add API key to request body if available
      if (data is Map<String, dynamic> &&
          _apiKey != null &&
          _apiKey!.isNotEmpty) {
        data['api_key'] = _apiKey!;
      }

      return await _dio.post<T>(
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

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
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

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException(
            message: 'Connection timeout',
            code: 'TIMEOUT',
          );
        case DioExceptionType.connectionError:
          return NetworkException(
            message: 'No internet connection',
            code: 'NO_CONNECTION',
          );
        case DioExceptionType.badResponse:
          return ServerException(
            message: error.response?.data['message'] ?? 'Server error',
            code: 'SERVER_ERROR_${error.response?.statusCode}',
          );
        default:
          return NetworkException(
            message: error.message ?? 'Unknown network error',
            code: 'UNKNOWN_NETWORK_ERROR',
          );
      }
    }
    return Exception('Unknown error: $error');
  }
}

// Simple interceptors
class _NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
