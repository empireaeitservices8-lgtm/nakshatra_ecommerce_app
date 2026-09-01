import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../config/app_config.dart';
import '../helpers/sp_helper.dart';
import '../utils/connection_failed_screen.dart';
import '../utils/exceptions.dart';

mixin WebAPIMixin {
  /// Returns the token from Shared Preference / SPHelper
  Future<String?> getTokenFromSharedPref() async {
    return SPHelper.getToken();
  }

  /// Handle Dio errors and translate to APIException
  void onDioError(DioException error, String apiName, {Function? apiFunction}) {
    String? msg;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        msg = "The connection has timed out. Please try again.";
        throw APIException(
          enumProperty: EnumAPIExceptions.connectionTimeout,
          message: msg,
        );

      case DioExceptionType.connectionError:
        msg = "No internet connection detected.";
        if (AppConfig.navKey.currentContext != null) {
          Navigator.of(AppConfig.navKey.currentContext!).pushNamed(
            ConnectionFailedScreen.routeName,
            arguments: apiFunction,
          );
        }
        throw APIException(
          enumProperty: EnumAPIExceptions.networkFailure,
          message: msg,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          throw APIException(
            enumProperty: EnumAPIExceptions.invalidToken,
            message: 'Session expired. Please log in again.',
            data: error.response,
          );
        }

        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw APIException(
            enumProperty: EnumAPIExceptions.dataSuccessFalse,
            message: data['message'].toString(),
            data: error.response,
          );
        }
        msg = error.message ?? "Server error occurred";
        break;

      case DioExceptionType.cancel:
        msg = "The request was cancelled.";
        break;

      case DioExceptionType.unknown:
      default:
        msg = error.message ?? "An unexpected network error occurred.";
        break;
    }

    throw APIException(
      enumProperty: EnumAPIExceptions.httpStatusError,
      message: msg,
      otherData: [error.response?.data],
    );
  }

  /// Validates standard response data map
  Future<Map<dynamic, dynamic>> validateResStatusData(Response<dynamic> response) async {
    if (response.data == null) {
      throw APIException(
        enumProperty: EnumAPIExceptions.apiResultEmpty,
        message: "The response is empty from server",
      );
    }

    if (response.data is! Map) {
      throw APIException(
        enumProperty: EnumAPIExceptions.invalidResultType,
        message: "Invalid result type from API response",
      );
    }

    final Map data = response.data;
    if (data.containsKey("status")) {
      final status = data["status"].toString();
      if (status == "500" || status == "error") {
        final msg = data["message"]?.toString() ?? "Server returned an error status";
        throw APIException(
          enumProperty: EnumAPIExceptions.dataSuccessFalse,
          message: msg,
          data: data,
        );
      }
    }

    return data;
  }
}
