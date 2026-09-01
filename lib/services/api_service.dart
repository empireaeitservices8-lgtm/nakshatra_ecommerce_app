import 'dart:async';
import 'package:dio/dio.dart';
import 'web_api_services.dart';

/// Backward-compatible wrapper delegating to centralized WebAPIService
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final WebAPIService _webAPIService = WebAPIService();

  factory ApiService() => _instance;

  ApiService._internal();

  Dio get dio => _webAPIService.dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _webAPIService.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _webAPIService.post(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _webAPIService.put(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _webAPIService.delete(path, data: data, queryParameters: queryParameters, options: options);

  /// Expose executeAPI directly
  Future<T> executeAPI<T>({
    required Future<Response<dynamic>> methodToCall,
    required FutureOr<T> Function(Map<dynamic, dynamic> value) converter,
    Function(dynamic msg)? onError,
    Function(T value)? onSuccess,
  }) =>
      _webAPIService.executeAPI<T>(
        methodToCall: methodToCall,
        converter: converter,
        onError: onError != null ? (err) => onError(err.message) : null,
        onSuccess: onSuccess,
      );
}
