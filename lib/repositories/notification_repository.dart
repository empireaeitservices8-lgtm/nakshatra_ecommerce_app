import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<List<AppNotification>> getNotifications({required String customerId}) async {
    final response = await _apiService.post('/notification/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      final list = result['data'] as List? ?? [];
      return list.map((item) => AppNotification.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch notifications');
    }
  }

  Future<void> markAsRead({required String customerId, required String id}) async {
    final response = await _apiService.post('/notification/read', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'notification_id': int.tryParse(id) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to mark notification as read');
    }
  }
}
