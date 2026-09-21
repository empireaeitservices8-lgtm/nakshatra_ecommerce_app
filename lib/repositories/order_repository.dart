import '../models/order.dart';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService _apiService = ApiService();

  Future<List<Order>> getOrders({required String customerId}) async {
    final response = await _apiService.post(
      '/orders',
      data: {
        'params': {'customer_id': int.tryParse(customerId) ?? 1},
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true ||
        result['data'] != null) {
      final list = (result['data'] as List?) ?? (result['orders'] as List?) ?? [];
      return list.map((item) => Order.fromJson(item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item))).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch orders');
    }
  }

  Future<Map<String, dynamic>> checkout({
    required String customerId,
    String paymentMethod = 'cash',
    required String shippingAddress,
    required String shippingCity,
    required String shippingPhone,
    String? notes,
  }) async {
    final response = await _apiService.post(
      '/checkout',
      data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
          'payment_method': paymentMethod.toLowerCase() == 'cod' ||
                  paymentMethod.toLowerCase() == 'cash on delivery' ||
                  paymentMethod.toLowerCase() == 'cash'
              ? 'cash'
              : 'cash',
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity.isNotEmpty ? shippingCity : 'Calicut',
          'shipping_phone': shippingPhone,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        'id': 1,
      },
    );

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 'error' ||
        result['status'] == 400 ||
        result['status'] == 500) {
      throw Exception(result['message'] ?? 'Checkout failed');
    }

    if (result['status'] == 200 ||
        result['status'] == 'success' ||
        result['success'] == true ||
        result['order_id'] != null ||
        result['data'] != null) {
      return result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result);
    } else {
      if (result['message'] != null && result['status'] == null) {
        return result is Map<String, dynamic>
            ? result
            : Map<String, dynamic>.from(result);
      }
      return result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result);
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String customerId,
    required String addressId,
    required String paymentMethod,
    String? shippingAddress,
    String? shippingCity,
    String? shippingPhone,
    String? notes,
    String? cardId,
    String? couponCode,
  }) async {
    return checkout(
      customerId: customerId,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress ?? '',
      shippingCity: shippingCity ?? 'Calicut',
      shippingPhone: shippingPhone ?? '',
      notes: notes,
    );
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
