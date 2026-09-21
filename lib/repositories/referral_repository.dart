import '../models/referral.dart';
import '../services/api_service.dart';

class ReferralRepository {
  final ApiService _apiService = ApiService();

  Future<ReferralInfo> getReferralInfo({required String customerId}) async {
    final response = await _apiService.post(
      '/referral/info',
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
        },
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true ||
        result['referral_code'] != null) {
      return ReferralInfo.fromJson(
        result is Map<String, dynamic> ? result : Map<String, dynamic>.from(result),
      );
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch referral details');
    }
  }

  Future<Map<String, dynamic>> inviteFriend({
    required String customerId,
    required String friendEmail,
    required String friendPhone,
  }) async {
    final response = await _apiService.post(
      '/referral/invite',
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
          'friend_email': friendEmail,
          'friend_phone': friendPhone,
        },
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true ||
        result['invite_id'] != null) {
      return result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result);
    } else {
      throw Exception(result['message'] ?? 'Failed to send referral invitation');
    }
  }

  Future<void> addReferral({
    required String customerId,
    required String referralCode,
  }) async {
    final response = await _apiService.post('/referral/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'referral_code': referralCode,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to add referral');
    }
  }
}
