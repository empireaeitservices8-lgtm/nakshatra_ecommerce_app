import 'package:flutter/material.dart';
import '../models/app_error_model.dart';
import '_base.dart';
import 'loading_provider.dart';

enum ViewState { idle, busy, error }

abstract class BaseViewModel extends BaseProvider {
  ViewState _state = ViewState.idle;
  AppError? _appError;

  BaseViewModel({super.name});

  ViewState get state => _state;
  bool get isBusy => _state == ViewState.busy;
  bool get isLoading => isBusy;
  bool get hasError => _state == ViewState.error;
  AppError? get appError => _appError;
  String? get errorMessage => _appError?.message;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setBusy(bool value, {bool global = false, String? message}) {
    _state = value ? ViewState.busy : ViewState.idle;
    if (global) {
      if (value) {
        LoadingService.show(message: message);
      } else {
        LoadingService.hide();
      }
    }
    notifyListeners();
  }

  void setError(AppError error) {
    _appError = error;
    _state = ViewState.error;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _appError = AppError(message: message);
    _state = ViewState.error;
    notifyListeners();
  }

  void clearError() {
    _appError = null;
    _state = ViewState.idle;
    notifyListeners();
  }

  @mustCallSuper
  void init() {}
}

typedef ViewModel = BaseViewModel;
