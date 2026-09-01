enum EnumAPIExceptions {
  unknown,
  networkFailure,
  connectionTimeout,
  httpStatusError,
  invalidToken,
  dataSuccessFalse,
  apiResultEmpty,
  invalidResultType,
}

class APIException implements Exception {
  final EnumAPIExceptions enumProperty;
  final String message;
  final dynamic data;
  final List<dynamic>? otherData;

  APIException({
    required this.enumProperty,
    required this.message,
    this.data,
    this.otherData,
  });

  @override
  String toString() => 'APIException: $message ($enumProperty)';
}
