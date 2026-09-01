import '../models/review.dart';
import '../services/api_service.dart';

class ReviewRepository {
  final ApiService _apiService = ApiService();

  Future<List<Review>> getReviews({required String customerId, String? productId}) async {
    final response = await _apiService.post('/review/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        if (productId != null) 'product_id': int.tryParse(productId) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      final list = result['data'] as List? ?? [];
      return list.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch reviews');
    }
  }

  Future<void> writeReview({
    required String customerId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final response = await _apiService.post('/review/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'product_id': int.tryParse(productId) ?? 0,
        'rating': rating,
        'comment': comment,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to submit review');
    }
  }

  Future<void> deleteReview({
    required String customerId,
    required String reviewId,
  }) async {
    final response = await _apiService.post('/review/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'review_id': int.tryParse(reviewId) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to delete review');
    }
  }
}
