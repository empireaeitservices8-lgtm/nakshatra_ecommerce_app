import '../models/order.dart';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getOrders({required String customerId}) async {
    final response = await _apiService.post(
      '/order/view',
      data: {
        'params': {'customer_id': int.tryParse(customerId) ?? 1},
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true) {
      final list = result['data'] as List? ?? [];
      return list.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch orders');
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String customerId,
    required String addressId,
    required String paymentMethod,
    String? cardId,
    String? couponCode,
  }) async {
    final response = await _apiService.post(
      '/order/add',
      data: {
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
          'address_id': int.tryParse(addressId) ?? 0,
          'payment_method': paymentMethod,
          if (cardId != null && cardId.isNotEmpty)
            'card_id': int.tryParse(cardId) ?? 0,
          if (couponCode != null && couponCode.isNotEmpty)
            'coupon_code': couponCode,
        },
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true) {
      return result['data'] ?? result;
    } else {
      throw Exception(result['message'] ?? 'Failed to place order');
    }
  }

  Future<Map<String, dynamic>> getOrderDetail({
    required String customerId,
    required String orderId,
  }) async {
    final response = await _apiService.post(
      '/order/detail',
      data: {
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
          'order_id': orderId,
        },
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true) {
      return result['data'] ?? {};
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch order details');
    }
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String customerId,
    required String code,
  }) async {
    final response = await _apiService.post(
      '/coupon/apply',
      data: {
        'params': {'customer_id': int.tryParse(customerId) ?? 1, 'code': code},
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true) {
      return result['data'] ?? result;
    } else {
      throw Exception(result['message'] ?? 'Failed to validate coupon');
    }
  }

  Future<List<dynamic>> getCoupons({required String customerId}) async {
    final response = await _apiService.post(
      '/coupon/view',
      data: {
        'params': {'customer_id': int.tryParse(customerId) ?? 1},
      },
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true) {
      return result['data'] as List? ?? [];
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch coupons');
    }
  }
}
