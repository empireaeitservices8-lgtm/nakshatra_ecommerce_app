import '../../services/api_service.dart';
import 'gold_scheme_model.dart';

class GoldSchemeRepository {
  final ApiService _apiService = ApiService();

  Future<GoldScheme?> getSchemeDetails(String customerId) async {
    final response = await _apiService.post('/scheme/details/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) return null;

    if (result['status'] == 200 || result['success'] == true) {
      if (result['data'] == null) return null;
      return GoldScheme.fromJson(result['data']);
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch scheme details');
    }
  }

  Future<bool> makeSchemePayment({
    required String customerId,
    required int schemeId,
    required double amount,
  }) async {
    final response = await _apiService.post('/scheme/join', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'scheme_id': schemeId,
        'amount': amount,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) return false;

    return result['status'] == 200 || result['success'] == true;
  }
}
