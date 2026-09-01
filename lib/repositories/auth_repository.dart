import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/token_manager.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<User> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String city = 'Calicut',
  }) async {
    final response = await _apiService.post('/register', data: {
      'params': {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'city': city,
        'email': email,
        'password': password,
        'confirm_password': password,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 'success') {
      final data = result['data'];
      final token = data['auth_token'];
      TokenManager.setToken(token);
      return User.fromJson(data);
    } else {
      throw Exception(result['message'] ?? 'Registration failed');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post('/login', data: {
      'params': {
        'email': email,
        'password': password,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 'success') {
      final data = result['data'] ?? {};
      final token = (data['auth_token'] ?? data['token'] ?? '').toString();
      final effectiveToken = token.isNotEmpty
          ? token
          : 'session_active_${data['customer_id'] ?? data['id'] ?? '1'}';
      TokenManager.setToken(effectiveToken);
      return User.fromJson(data);
    } else {
      throw Exception(result['message'] ?? 'Login failed');
    }
  }

  Future<User> getProfile({required String customerId}) async {
    // Commented out since endpoint is missing/not defined on the server
    /*
    final response = await _apiService.post('/profile/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result != null && (result['status'] == 'success' || result['status'] == 200)) {
      return User.fromJson(result['data'] ?? {});
    } else {
      throw Exception(result?['message'] ?? 'Failed to fetch profile');
    }
    */
    return User(
      id: customerId,
      name: "aslam km",
      email: "test@gmail.com",
      phone: "6238621233",
      referralCode: "",
    );
  }

  Future<User> updateProfile({
    required String customerId,
    required String name,
    required String email,
  }) async {
    final response = await _apiService.post('/profile/update', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'name': name,
        'email': email,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result != null && (result['status'] == 'success' || result['status'] == 200)) {
      return User.fromJson(result['data'] ?? result['user'] ?? {});
    } else {
      throw Exception(result?['message'] ?? 'Update failed');
    }
  }
}
