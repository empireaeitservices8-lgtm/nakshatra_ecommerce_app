import '../models/referral.dart';
import '../services/api_service.dart';

class ReferralRepository {
  final ApiService _apiService = ApiService();

  Future<ReferralInfo> getReferralInfo({required String customerId}) async {
    final response = await _apiService.post('/referral/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      return ReferralInfo.fromJson(result['data'] ?? {});
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch referral details');
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
