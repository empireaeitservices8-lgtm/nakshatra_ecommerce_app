class AppError {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AppError(statusCode: $statusCode, message: $message)';
}
