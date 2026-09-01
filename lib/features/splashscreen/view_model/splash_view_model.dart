import 'package:flutter/material.dart';
import '../../../helpers/sp_helper.dart';
import '../../../providers/view_model.dart';
import '../../../services/token_manager.dart';

class SplashViewModel extends BaseViewModel {
  SplashViewModel() : super(name: "SplashViewModel");

  Future<String> checkSession() async {
    setBusy(true);
    await Future.delayed(const Duration(seconds: 2));

    final token = SPHelper.getToken();
    if (token != null && token.isNotEmpty) {
      TokenManager.setToken(token);
      setBusy(false);
      return '/home';
    } else {
      setBusy(false);
      return '/login';
    }
  }
}
