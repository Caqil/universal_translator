// lib/core/network/dio_client.dart - Minimal version with @injectable
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';

@LazySingleton()
class DioClient {
  final Dio _dio;
  String? _apiKey;

  DioClient() : _dio = Dio() {
    _initializeDio();
  }

  Dio get dio => _dio;

  void _initializeDio() {
    _dio.options = BaseOptions(
      // Use the API constants for base URL - defaults to your working server
      baseUrl:
          ApiConstants.exampleLibreTranslateUrl, // http://20.51.237.146:5000
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

    // Add basic interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    debugPrint(
        '🌐 DioClient initialized with base URL: ${ApiConstants.exampleLibreTranslateUrl}');
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
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request with API key in body
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
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
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
