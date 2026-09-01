import 'package:flutter/foundation.dart';
import '../models/app_error_model.dart';
import '../utils/exceptions.dart';

mixin MixinProgressProvider on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void startProgress() => isLoading = true;
  void stopProgress() => isLoading = false;
}

mixin MixinAPIProvider {
  void handleAPIException(
    APIException ex, {
    void Function(AppError msg)? onShowError,
  }) {
    debugPrint("API Error caught: ${ex.message} [${ex.enumProperty}]");
    final appError = AppError(
      message: ex.message,
      originalError: ex,
    );
    onShowError?.call(appError);
  }
}
