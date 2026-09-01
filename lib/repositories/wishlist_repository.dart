import '../models/product.dart';
import '../services/api_service.dart';

class WishlistRepository {
  final ApiService _apiService = ApiService();

  Future<List<Product>> getWishlist({required String customerId}) async {
    final response = await _apiService.post('/wishlist/view', data: {
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
      final list = result['data'] as List? ?? [];
      return list.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch wishlist');
    }
  }

  Future<void> addToWishlist({required String customerId, required String productId}) async {
    final response = await _apiService.post('/wishlist/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'product_id': int.tryParse(productId) ?? 0,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist({required String customerId, required String productId}) async {
    final response = await _apiService.post('/wishlist/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'product_id': int.tryParse(productId) ?? 0,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to remove from wishlist');
    }
  }
}
