import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../helpers/url_helpers.dart';
import '../helpers/sp_helper.dart';
import '../models/app_error_model.dart';
import '../providers/_mixins.dart';
import '../utils/extensions.dart';
import '_mixins_api.dart';
import 'api_logger.dart';

class WebAPIService with WebAPIMixin, MixinAPIProvider {
  static final WebAPIService _instance = WebAPIService._internal();
  late final Dio _dio;

  factory WebAPIService() => _instance;

  Dio get dio => _dio;

  WebAPIService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: UrlHelpers.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    // Dynamic Auth Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = SPHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Request/Response Logger
    if (kDebugMode) {
      _dio.interceptors.add(ApiLoggerInterceptor());
    }
  }

  /// Core generic API execution pipeline
  Future<T> executeAPI<T>({
    required Future<Response<dynamic>> methodToCall,
    required FutureOr<T> Function(Map<dynamic, dynamic> value) converter,
    Function(AppError msg)? onError,
    Function(T value)? onSuccess,
    Function? functionToRefresh,
  }) {
    return methodToCall
        .then(validateResStatusData)
        .then(converter)
        .then((value) {
          onSuccess?.call(value);
          return value;
        })
        .catchError((ex) {
          if (ex is DioException) {
            onDioError(ex, 'executeAPI', apiFunction: functionToRefresh);
          }
          throw ex;
        })
        .handleAPIException(
          handleAPIException: handleAPIException,
          onShowError: (msg) {
            onError?.call(msg);
          },
        );
  }

  // Convenience HTTP helpers
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
}
