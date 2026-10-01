import '../helpers/request_deduplicator.dart';
import '../helpers/url_helpers.dart';
import '../models/branch.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/token_manager.dart';
import '../helpers/sp_helper.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final RequestDeduplicator _deduplicator = RequestDeduplicator();

  Future<List<Branch>> getBranches() async {
    return _deduplicator.run('branches', () async {
      final response = await _apiService.post(
        '/branches',
        data: {'params': {}},
      );

      final resData = response.data;
      final result = resData['result'];
      if (result == null) {
        throw Exception('Invalid server response');
      }

      if (result['status'] == 'success' ||
          result['status'] == 200 ||
          result['success'] == true) {
        final list = (result['data'] ?? result['branches']) as List? ?? [];
        return list
            .map((item) => Branch.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch branches');
      }
    });
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    String city = 'Calicut',
    int? branchId,
  }) async {
    final Map<String, dynamic> params = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'city': city,
      'email': email,
      'password': password,
      'confirm_password': password,
    };
    if (branchId != null) {
      params['branch_id'] = branchId;
    }

    final response = await _apiService.post(
      '/register',
      data: {'params': params},
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 'success') {
      final data = (result['data'] is Map)
          ? result['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final token =
          (data['auth_token'] ?? data['token'] ?? data['access_token'] ?? '')
              .toString();
      if (token.isNotEmpty) {
        TokenManager.setToken(token);
        await SPHelper.saveToken(token);
      }
      return User.fromJson(data);
    } else {
      throw Exception(result['message'] ?? 'Registration failed');
    }
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _apiService.post(
      '/login',
      data: {
        'params': {'email': email, 'password': password},
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 'success') {
      final data = (result['data'] is Map)
          ? result['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      final token =
          (data['auth_token'] ?? data['token'] ?? data['access_token'] ?? '')
              .toString();
      final effectiveToken = token.isNotEmpty
          ? token
          : 'session_active_${data['customer_id'] ?? data['id'] ?? '1'}';
      TokenManager.setToken(effectiveToken);
      await SPHelper.saveToken(effectiveToken);
      return User.fromJson(data);
    } else {
      throw Exception(result['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> sendOtp({required String phone}) async {
    final response = await _apiService.post(
      UrlHelpers.sendOtp,
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {'phone': phone},
        'id': 1,
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) {
      final error = resData is Map ? resData['error'] : null;
      throw Exception(
        error is Map
            ? error['message'] ?? 'Failed to send OTP'
            : 'Failed to send OTP',
      );
    }

    if (result is Map &&
        (result['status'] == 'success' ||
            result['status'] == 200 ||
            result['success'] == true)) {
      return Map<String, dynamic>.from(result);
    } else {
      final msg = result is Map ? result['message'] : 'Failed to send OTP';
      throw Exception(msg ?? 'Failed to send OTP');
    }
  }

  Future<User> verifyOtp({required String phone, required String otp}) async {
    final response = await _apiService.post(
      UrlHelpers.verifyOtp,
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {'phone': phone, 'otp': otp},
        'id': 1,
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) {
      final error = resData is Map ? resData['error'] : null;
      throw Exception(
        error is Map ? error['message'] ?? 'Invalid OTP' : 'Invalid OTP',
      );
    }

    if (result is Map &&
        (result['status'] == 'success' ||
            result['status'] == 200 ||
            result['success'] == true)) {
      final Map<String, dynamic> data = (result['data'] is Map)
          ? Map<String, dynamic>.from(result['data'] as Map)
          : Map<String, dynamic>.from(result);

      if (!data.containsKey('branch_id') && result.containsKey('branch_id')) {
        data['branch_id'] = result['branch_id'];
      }
      if (!data.containsKey('branch_name') && result.containsKey('branch')) {
        data['branch_name'] = result['branch'];
      }

      final token =
          (data['auth_token'] ?? data['token'] ?? data['access_token'] ?? '')
              .toString();
      final effectiveToken = token.isNotEmpty
          ? token
          : 'session_active_${data['customer_id'] ?? data['id'] ?? '1'}';
      TokenManager.setToken(effectiveToken);
      await SPHelper.saveToken(effectiveToken);
      final user = User.fromJson(data);
      await SPHelper.saveUser(user);
      return user;
    } else {
      final msg = result is Map ? result['message'] : 'Invalid OTP';
      throw Exception(msg ?? 'Invalid OTP');
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
    final response = await _apiService.post(
      '/profile/update',
      data: {
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
          'name': name,
          'email': email,
        },
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result != null &&
        (result['status'] == 'success' || result['status'] == 200)) {
      return User.fromJson(result['data'] ?? result['user'] ?? {});
    } else {
      throw Exception(result?['message'] ?? 'Update failed');
    }
  }

  Future<Map<String, dynamic>> deleteCustomer({int? customerId}) async {
    final effectiveCustomerId =
        customerId ?? int.tryParse(SPHelper.getUser()?.id ?? '1') ?? 1;

    final response = await _apiService.post(
      UrlHelpers.deleteCustomer,
      data: {
        'params': {'customer_id': effectiveCustomerId},
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : {};

    if (result is Map &&
        (result['status'] == 'success' ||
            result['status'] == 200 ||
            result['success'] == true)) {
      TokenManager.clear();
      await SPHelper.clear();
      return Map<String, dynamic>.from(result);
    } else {
      final msg = result is Map
          ? (result['message'] ?? 'Failed to delete account')
          : 'Failed to delete account';
      throw Exception(msg);
    }
  }
}
