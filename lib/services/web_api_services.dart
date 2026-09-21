import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../screens/login_screen.dart';
import '../helpers/toast_helper.dart';
import '../helpers/url_helpers.dart';
import '../helpers/sp_helper.dart';
import '../models/app_error_model.dart';
import '../providers/_mixins.dart';
import '../providers/loading_provider.dart';
import '../utils/extensions.dart';
import '_mixins_api.dart';
import 'api_logger.dart';
import 'token_manager.dart';

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

    // Global Network Progress / Loading Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra['silent'] != true) {
            LoadingService.show(message: options.extra['loadingMessage'] as String?);
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.requestOptions.extra['silent'] != true) {
            LoadingService.hide();
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (error.requestOptions.extra['silent'] != true) {
            LoadingService.hide();
          }
          return handler.next(error);
        },
      ),
    );

    // Dynamic Auth Token Interceptor + Global Unauthenticated / 404 Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = SPHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          bool isUnauthenticated = statusCode == 401 || statusCode == 403;
          if (!isUnauthenticated && responseData is Map) {
            final msg = (responseData['message'] ?? responseData['error'] ?? '').toString().toLowerCase();
            if (msg.contains('unauthenticated') ||
                msg.contains('unauthorized') ||
                msg.contains('session expired') ||
                msg.contains('invalid token')) {
              isUnauthenticated = true;
            }
          }

          if (isUnauthenticated) {
            TokenManager.clear();
            final context = AppConfig.navKey.currentContext;
            if (context != null) {
              ToastHelper.showErrorToast(context, 'Session expired or unauthenticated. Please log in.');
              AppConfig.navKey.currentState?.pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            }
          } else if (statusCode == 404) {
            final context = AppConfig.navKey.currentContext;
            if (context != null) {
              ToastHelper.showErrorToast(context, 'Resource not found (404)');
            }
          }

          return handler.next(error);
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
