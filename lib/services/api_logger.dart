import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class ApiLoggerInterceptor extends Interceptor {
  static const _startTimeKey = 'request_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final requestLogs = <String>[];
    requestLogs.add('========== API REQUEST ==========');
    requestLogs.add('METHOD : ${options.method}');
    requestLogs.add('URL    : ${options.uri}');
    
    // Mask headers
    final maskedHeaders = <String, dynamic>{};
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        final valStr = value.toString();
        if (valStr.startsWith('Bearer ')) {
          maskedHeaders[key] = 'Bearer ********';
        } else {
          maskedHeaders[key] = '********';
        }
      } else {
        maskedHeaders[key] = value;
      }
    });
    requestLogs.add('\nHEADERS:');
    requestLogs.add(const JsonEncoder.withIndent('  ').convert(maskedHeaders));

    // Mask query params
    final maskedQueryParams = _maskSensitive(options.queryParameters);
    requestLogs.add('\nQUERY:');
    requestLogs.add(const JsonEncoder.withIndent('  ').convert(maskedQueryParams));

    // Mask body
    if (options.data != null) {
      requestLogs.add('\nBODY:');
      final maskedBody = _maskSensitive(options.data);
      if (maskedBody is Map || maskedBody is List) {
        requestLogs.add(const JsonEncoder.withIndent('  ').convert(maskedBody));
      } else {
        requestLogs.add(maskedBody.toString());
      }
    }
    requestLogs.add('==================================');
    
    developer.log(requestLogs.join('\n'), name: 'API');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final startTime = response.requestOptions.extra[_startTimeKey] as int? ?? endTime;
    final duration = endTime - startTime;

    final responseLogs = <String>[];
    responseLogs.add('========== API RESPONSE =========');
    responseLogs.add('STATUS : ${response.statusCode}');
    responseLogs.add('METHOD : ${response.requestOptions.method}');
    responseLogs.add('URL    : ${response.requestOptions.uri}');
    responseLogs.add('TIME   : $duration ms');

    if (response.data != null) {
      responseLogs.add('\nBODY:');
      final maskedBody = _maskSensitive(response.data);
      if (maskedBody is Map || maskedBody is List) {
        responseLogs.add(const JsonEncoder.withIndent('  ').convert(maskedBody));
      } else {
        responseLogs.add(maskedBody.toString());
      }
    }
    responseLogs.add('==================================');

    developer.log(responseLogs.join('\n'), name: 'API');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final startTime = err.requestOptions.extra[_startTimeKey] as int? ?? endTime;
    final duration = endTime - startTime;

    final errorLogs = <String>[];
    errorLogs.add('========== API ERROR ============');
    errorLogs.add('STATUS : ${err.response?.statusCode ?? 'N/A'}');
    errorLogs.add('METHOD : ${err.requestOptions.method}');
    errorLogs.add('URL    : ${err.requestOptions.uri}');
    errorLogs.add('TIME   : $duration ms');
    errorLogs.add('\nERROR:');
    errorLogs.add(err.message ?? err.toString());

    if (err.response?.data != null) {
      errorLogs.add('\nBODY:');
      final maskedBody = _maskSensitive(err.response!.data);
      if (maskedBody is Map || maskedBody is List) {
        errorLogs.add(const JsonEncoder.withIndent('  ').convert(maskedBody));
      } else {
        errorLogs.add(maskedBody.toString());
      }
    }
    errorLogs.add('==================================');

    developer.log(errorLogs.join('\n'), name: 'API');
    super.onError(err, handler);
  }

  dynamic _maskSensitive(dynamic data) {
    if (data is Map) {
      final masked = <String, dynamic>{};
      data.forEach((key, value) {
        final lowerKey = key.toLowerCase();
        if (lowerKey.contains('password') ||
            lowerKey.contains('token') ||
            lowerKey.contains('otp') ||
            lowerKey.contains('cvv') ||
            lowerKey.contains('card_number') ||
            lowerKey.contains('number') ||
            lowerKey.contains('secret') ||
            lowerKey.contains('key')) {
          if (lowerKey.contains('otp') || lowerKey.contains('cvv')) {
            masked[key] = '****';
          } else {
            masked[key] = '********';
          }
        } else {
          masked[key] = _maskSensitive(value);
        }
      });
      return masked;
    } else if (data is List) {
      return data.map((item) => _maskSensitive(item)).toList();
    }
    return data;
  }
}
