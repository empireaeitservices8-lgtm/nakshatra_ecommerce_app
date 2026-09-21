import '../models/address.dart';
import '../services/api_service.dart';

class AddressRepository {
  final ApiService _apiService = ApiService();

  String _normalizeType(String type) {
    final lower = type.toLowerCase().trim();
    if (lower == 'home' || lower == 'work' || lower == 'other') {
      return lower;
    }
    return 'home';
  }

  Future<List<Address>> getAddresses({required String customerId}) async {
    final effectiveId = int.tryParse(customerId) ?? 1;
    dynamic resData;

    try {
      final response = await _apiService.post(
        '/addresses',
        data: {
          'params': {
            'customer_id': effectiveId,
          },
        },
      );
      resData = response.data;
    } catch (_) {
      final response = await _apiService.get(
        '/addresses',
        queryParameters: {
          'customer_id': effectiveId,
        },
      );
      resData = response.data;
    }

    if (resData == null) throw Exception('Invalid server response');

    final dataMap = resData is Map ? (resData['result'] is Map ? resData['result'] : resData) : {};
    if (dataMap['status'] == 'success' ||
        dataMap['status'] == 200 ||
        dataMap['success'] == true ||
        dataMap['addresses'] != null ||
        dataMap['data'] != null) {
      final list = (dataMap['addresses'] as List?) ?? (dataMap['data'] as List?) ?? [];
      return list.map((item) => Address.fromJson(item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item))).toList();
    } else {
      throw Exception(dataMap['message'] ?? dataMap['error'] ?? 'Failed to fetch addresses');
    }
  }

  Future<Address> saveAddress({
    required String customerId,
    required String label,
    required String name,
    required String phone,
    required String address,
  }) async {
    final response = await _apiService.post('/address/add', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'type': _normalizeType(label),
        'recipient_name': name,
        'phone': phone,
        'address_details': address,
      }
    });

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result is Map && (result['status'] == 200 || result['status'] == 'success' || result['success'] == true)) {
      final data = (result['data'] is Map) ? result['data'] as Map<String, dynamic> : Map<String, dynamic>.from(result);
      return Address.fromJson(data);
    } else {
      final msg = result is Map ? (result['message'] ?? result['error']) : 'Failed to save address';
      throw Exception(msg?.toString() ?? 'Failed to save address');
    }
  }

  Future<Address> updateAddress({
    required String customerId,
    required String addressId,
    required String label,
    required String name,
    required String phone,
    required String address,
  }) async {
    final response = await _apiService.post('/address/update', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'address_id': int.tryParse(addressId) ?? 0,
        'type': _normalizeType(label),
        'recipient_name': name,
        'phone': phone,
        'address_details': address,
      }
    });

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result is Map && (result['status'] == 200 || result['status'] == 'success' || result['success'] == true)) {
      final data = (result['data'] is Map) ? result['data'] as Map<String, dynamic> : Map<String, dynamic>.from(result);
      return Address.fromJson(data);
    } else {
      final msg = result is Map ? (result['message'] ?? result['error']) : 'Failed to update address';
      throw Exception(msg?.toString() ?? 'Failed to update address');
    }
  }

  Future<void> deleteAddress({required String customerId, required String id}) async {
    final response = await _apiService.post('/address/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'address_id': int.tryParse(id) ?? 0,
        'id': int.tryParse(id) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData is Map ? (resData['result'] ?? resData) : null;
    if (result == null) throw Exception('Invalid server response');

    if (result is Map && (result['status'] == 200 || result['status'] == 'success' || result['success'] == true)) {
      return;
    } else {
      final msg = result is Map ? (result['message'] ?? result['error']) : 'Failed to delete address';
      throw Exception(msg?.toString() ?? 'Failed to delete address');
    }
  }
}
