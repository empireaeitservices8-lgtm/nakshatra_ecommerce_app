import '../models/payment_method.dart';
import '../services/api_service.dart';

class PaymentRepository {
  final ApiService _apiService = ApiService();

  Future<PaymentMethodsResult> getPaymentMethods({
    required String customerId,
  }) async {
    final response = await _apiService.post(
      '/payment_methods',
      data: {
        'jsonrpc': '2.0',
        'params': {'customer_id': int.tryParse(customerId) ?? 1},
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 'success' ||
        result['status'] == 200 ||
        result['success'] == true) {
      return PaymentMethodsResult.fromJson(
        result is Map<String, dynamic>
            ? result
            : Map<String, dynamic>.from(result),
      );
    }
    throw Exception(result['message'] ?? 'Failed to fetch payment methods');
  }

  Future<PaymentMethod> saveCard({
    required String customerId,
    required String number,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String holder,
    required String brand,
    required String theme,
  }) async {
    final response = await _apiService.post('/payment/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'number': number,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'cvv': cvv,
        'holder': holder,
        'brand': brand,
        'theme': theme,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      return PaymentMethod.fromJson(result['data'] ?? {});
    } else {
      throw Exception(result['message'] ?? 'Failed to save card');
    }
  }

  Future<void> removePaymentMethod({
    required String customerId,
    required String cardId,
  }) async {
    final response = await _apiService.post('/payment/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'card_id': int.tryParse(cardId) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to remove payment method');
    }
  }
}
