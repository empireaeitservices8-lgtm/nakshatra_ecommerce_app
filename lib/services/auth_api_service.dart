import '../models/auth_models.dart';
import '../utils/urls.dart';
import 'web_api_services.dart';

class AuthApiService {
  final WebAPIService _webAPI = WebAPIService();

  Future<AuthResponse> login(LoginRequest request) {
    return _webAPI.executeAPI<AuthResponse>(
      methodToCall: _webAPI.post(AppUrls.login, data: request.toJson()),
      converter: (data) => AuthResponse.fromJson(data),
    );
  }

  Future<AuthResponse> verifyLogin(String token) {
    return _webAPI.executeAPI<AuthResponse>(
      methodToCall: _webAPI.post(AppUrls.verifyLogin, data: {'token': token}),
      converter: (data) => AuthResponse.fromJson(data),
    );
  }

  Future<bool> requestOtp(RequestOTP request) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(AppUrls.requestOtp, data: request.toJson()),
      converter: (data) => data['status'] == true || data['status'] == 'success' || data['result'] != null,
    );
  }

  Future<AuthResponse> verifyOtp(VerifyOTP request) {
    return _webAPI.executeAPI<AuthResponse>(
      methodToCall: _webAPI.post(AppUrls.verifyOtp, data: request.toJson()),
      converter: (data) => AuthResponse.fromJson(data),
    );
  }

  Future<bool> enableBiometric(bool enabled) {
    return _webAPI.executeAPI<bool>(
      methodToCall: _webAPI.post(AppUrls.enableBiometric, data: {'enabled': enabled}),
      converter: (data) => data['status'] == true || data['status'] == 'success',
    );
  }
}
