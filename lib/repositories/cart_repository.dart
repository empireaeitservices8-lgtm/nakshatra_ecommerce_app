import '../helpers/request_deduplicator.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartRepository {
  final ApiService _apiService = ApiService();
  final RequestDeduplicator _deduplicator = RequestDeduplicator();

  Future<Map<String, dynamic>> getCart({required String customerId}) async {
    return _deduplicator.run('cart_$customerId', () async {
      final response = await _apiService.post('/cart/view', data: {
        'params': {
          'customer_id': int.tryParse(customerId) ?? 1,
        }
      });
      
      final resData = response.data;
      final result = resData['result'];
      if (result == null) {
        throw Exception('Invalid server response');
      }

      if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
        final cart = result['cart'] as Map<String, dynamic>?;
        
        final list = (cart != null ? cart['items'] : result['data']) as List?;
        final items = list != null
            ? list.map((item) => CartItem.fromJson(item)).toList()
            : <CartItem>[];
        
        double totalAmount = 0.0;
        if (cart != null && cart['total_amount'] != null) {
          final rawTotal = cart['total_amount'];
          if (rawTotal is num) {
            totalAmount = rawTotal.toDouble();
          } else {
            totalAmount = double.tryParse(rawTotal.toString()) ?? 0.0;
          }
        } else if (result['total_amount'] != null) {
          final rawTotal = result['total_amount'];
          if (rawTotal is num) {
            totalAmount = rawTotal.toDouble();
          } else {
            totalAmount = double.tryParse(rawTotal.toString()) ?? 0.0;
          }
        }

        return {
          'items': items,
          'subtotal': totalAmount,
          'shipping': 0.0,
          'total': totalAmount,
        };
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch cart');
      }
    });
  }

  Future<int> addToCart({
    required String customerId,
    required String productId,
    int quantity = 1,
  }) async {
    final response = await _apiService.post('/cart/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'product_id': int.tryParse(productId) ?? 0,
        'quantity': quantity,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      return 1;
    } else {
      throw Exception(result['message'] ?? 'Failed to add item to cart');
    }
  }

  Future<void> updateQuantity({
    required String customerId,
    required String cartLineId,
    required int quantity,
  }) async {
    final response = await _apiService.post('/cart/update', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'cart_line_id': int.tryParse(cartLineId) ?? 0,
        'quantity': quantity.toDouble(),
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to update quantity');
    }
  }

  Future<void> removeCartItem({
    required String customerId,
    required String cartLineId,
  }) async {
    final response = await _apiService.post('/cart/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'cart_line_id': int.tryParse(cartLineId) ?? 0,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to remove item');
    }
  }
}
