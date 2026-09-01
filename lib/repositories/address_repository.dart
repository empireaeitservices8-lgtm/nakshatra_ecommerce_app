import '../models/address.dart';
import '../services/api_service.dart';

class AddressRepository {
  final ApiService _apiService = ApiService();

  Future<List<Address>> getAddresses({required String customerId}) async {
    final response = await _apiService.post('/address/view', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      final list = result['data'] as List? ?? [];
      return list.map((item) => Address.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch addresses');
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
        'label': label,
        'name': name,
        'phone': phone,
        'address': address,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      return Address.fromJson(result['data'] ?? {});
    } else {
      throw Exception(result['message'] ?? 'Failed to save address');
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
        'label': label,
        'name': name,
        'phone': phone,
        'address': address,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] == 200 || result['status'] == 'success' || result['success'] == true) {
      return Address.fromJson(result['data'] ?? {});
    } else {
      throw Exception(result['message'] ?? 'Failed to update address');
    }
  }

  Future<void> deleteAddress({required String customerId, required String id}) async {
    final response = await _apiService.post('/address/remove', data: {
      'params': {
        'customer_id': int.tryParse(customerId) ?? 1,
        'address_id': int.tryParse(id) ?? 0,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) throw Exception('Invalid server response');

    if (result['status'] != 200 && result['status'] != 'success' && result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to delete address');
    }
  }
}
