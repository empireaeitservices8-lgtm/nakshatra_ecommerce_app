import 'package:flutter/material.dart';
import '../../../helpers/sp_helper.dart';
import '../../../models/auth_models.dart';
import '../../../models/user.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/auth_api_service.dart';
import '../../../services/token_manager.dart';
import '../../../utils/sp_keys.dart';

class AuthViewModel extends ViewModel {
  final AuthRepository _repository = AuthRepository();
  final AuthApiService _authApiService = AuthApiService();
  User? _currentUser;
  AuthResponse? _authResponse;

  AuthViewModel() : super(name: "AuthViewModel") {
    _restoreSession();
  }

  void _restoreSession() {
    final token = SPHelper.getToken();
    final user = SPHelper.getUser();
    if (token != null && token.isNotEmpty) {
      TokenManager.setToken(token);
      _currentUser = user;
      Future.microtask(() => loadProfile());
    }
  }

  User? get currentUser => _currentUser;
  AuthResponse? get authResponse => _authResponse;
  bool get isAuthenticated => TokenManager.hasToken;

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> loginWithCredentials(String username, String password) async {
    setBusy(true);
    clearError();

    try {
      final req = LoginRequest(username: username, password: password);
      _authResponse = await _authApiService.login(req);
      if (_authResponse != null && _authResponse!.token.isNotEmpty) {
        TokenManager.setToken(_authResponse!.token);
        await SpHelper.saveString(keyToken, _authResponse!.token);
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> requestOtp(String phone) async {
    setBusy(true);
    clearError();

    try {
      final success = await _authApiService.requestOtp(RequestOTP(phone: phone));
      setBusy(false);
      return success;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    setBusy(true);
    clearError();

    try {
      _authResponse = await _authApiService.verifyOtp(VerifyOTP(phone: phone, otp: otp));
      if (_authResponse != null && _authResponse!.token.isNotEmpty) {
        TokenManager.setToken(_authResponse!.token);
        await SpHelper.saveString(keyToken, _authResponse!.token);
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    setBusy(true);
    clearError();

    try {
      _currentUser = await _repository.login(email: email, password: password);
      if (_currentUser != null) {
        await SPHelper.saveUser(_currentUser!);
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String city = 'Calicut',
  }) async {
    setBusy(true);
    clearError();

    try {
      _currentUser = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        city: city,
      );
      if (_currentUser != null) {
        await SPHelper.saveUser(_currentUser!);
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  Future<void> loadProfile() async {
    setBusy(true);
    clearError();

    try {
      final customerId = _currentUser?.id ?? '1';
      _currentUser = await _repository.getProfile(customerId: customerId);
      if (_currentUser != null) {
        await SPHelper.saveUser(_currentUser!);
      }
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    setBusy(true);
    clearError();

    try {
      final customerId = _currentUser?.id ?? '1';
      _currentUser = await _repository.updateProfile(
        customerId: customerId,
        name: name,
        email: email,
      );
      if (_currentUser != null) {
        await SPHelper.saveUser(_currentUser!);
      }
      setBusy(false);
      return true;
    } catch (e) {
      setErrorMessage(e.toString());
      setBusy(false);
      return false;
    }
  }

  void logout() {
    TokenManager.clear();
    _currentUser = null;
    _authResponse = null;
    clearError();
    notifyListeners();
  }
}
