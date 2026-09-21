import 'dart:async';
import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  static final LoadingProvider _instance = LoadingProvider._internal();
  factory LoadingProvider() => _instance;
  LoadingProvider._internal();

  int _activeCount = 0;
  String? _message;

  bool get isLoading => _activeCount > 0;
  String? get message => _message;

  void show({String? message}) {
    _activeCount++;
    _message = message;
    notifyListeners();
  }

  void hide() {
    if (_activeCount > 0) {
      _activeCount--;
      if (_activeCount == 0) {
        _message = null;
      }
      notifyListeners();
    }
  }

  void reset() {
    _activeCount = 0;
    _message = null;
    notifyListeners();
  }
}

/// Convenience static helper to show/hide loading anywhere in the app
class LoadingService {
  static LoadingProvider get _provider => LoadingProvider();

  static bool get isLoading => _provider.isLoading;
  static String? get message => _provider.message;

  static void show({String? message}) {
    _provider.show(message: message);
  }

  static void hide() {
    _provider.hide();
  }

  static void reset() {
    _provider.reset();
  }

  /// Automatically wraps an async task with loading indicator
  static Future<T> wrap<T>(
    Future<T> Function() asyncAction, {
    String? message,
  }) async {
    show(message: message);
    try {
      return await asyncAction();
    } finally {
      hide();
    }
  }
}
