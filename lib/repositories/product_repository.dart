import '../models/category.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../models/dashboard_product.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.post('/categories', data: {
        'params': {},
      });
      
      final resData = response.data;
      final result = resData['result'];
      if (result != null) {
        if (result['status'] == 200 || result['success'] == true || result['status'] == 'success') {
          final list = (result['categories'] ?? result['data']) as List? ?? [];
          if (list.isNotEmpty) {
            return list.map((item) => Category.fromJson(item)).toList();
          }
        }
      }
    } catch (e) {
      // Fallback gracefully on API errors
    }

    return [
      Category(id: '1', name: 'Chains', imageUrl: 'assets/images/necklace.png'),
      Category(id: '2', name: 'Earrings', imageUrl: 'assets/images/earring.png'),
      Category(id: '3', name: 'Bangles', imageUrl: 'assets/images/bangle.png'),
      Category(id: '4', name: 'Bracelets', imageUrl: 'assets/images/bracelet.png'),
      Category(id: '5', name: 'Rings', imageUrl: 'assets/images/ring.png'),
    ];
  }

  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? gender,
    String? search,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    final response = await _apiService.post('/branch_products', data: {
      'params': {
        'branch_name': 'Calicut',
      }
    });
    
    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 200 || result['success'] == true || result['status'] == 'success') {
      final list = result['data'] as List? ?? [];
      final products = list.map((item) => Product.fromJson(item)).toList();
      
      // Filter locally for compatibility with category/gender filters in UI
      var filtered = products;
      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (gender != null && gender.isNotEmpty) {
        filtered = filtered.where((p) => p.gender.toLowerCase() == gender.toLowerCase()).toList();
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        filtered = filtered.where((p) => p.title.toLowerCase().contains(query) || p.subtitle.toLowerCase().contains(query)).toList();
      }

      return {
        'products': filtered,
        'pagination': null,
      };
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch branch products');
    }
  }

  Future<Product> getProductDetail(String id) async {
    final response = await _apiService.post('/product_detail', data: {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'product_id': int.tryParse(id) ?? 0,
        'customer_id': 1,
        'branch_name': 'VYTTILA',
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result != null && (result['status'] == 200 || result['success'] == true || result['status'] == 'success')) {
      final productJson = result['product'] ?? result['data'];
      if (productJson != null) {
        final productDetail = ProductDetail.fromJson(productJson);
        return productDetail.toProduct();
      }
    }
    throw Exception('Failed to load product detail');
  }

  Future<List<Product>> getCategoryProducts({
    required int categoryId,
    required String customerId,
  }) async {
    final response = await _apiService.post('/category_products', data: {
      'params': {
        'category_id': categoryId,
        'customer_id': int.tryParse(customerId) ?? 1,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 200 || result['success'] == true || result['status'] == 'success') {
      final list = result['products'] as List? ?? [];
      return list.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch category products');
    }
  }

  Future<List<Product>> getLatestModels({
    int limit = 5,
    required String customerId,
    String branchName = 'vytilla',
  }) async {
    final response = await _apiService.post('/latest_models', data: {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'limit': limit,
        'customer_id': int.tryParse(customerId) ?? 1,
        'branch_name': branchName,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result != null && (result['status'] == 200 || result['success'] == true || result['status'] == 'success')) {
      final list = (result['products'] ?? result['data']) as List? ?? [];
      return list.map((item) => DashboardProduct.fromJson(item).toProduct()).toList();
    }
    return [];
  }

  Future<List<Product>> getRecommendations({
    int limit = 5,
    required String customerId,
    String branchName = 'vytilla',
  }) async {
    final response = await _apiService.post('/recommendation', data: {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'limit': limit,
        'customer_id': int.tryParse(customerId) ?? 1,
        'branch_name': branchName,
      }
    });

    final resData = response.data;
    final result = resData['result'];
    if (result != null && (result['status'] == 200 || result['success'] == true || result['status'] == 'success')) {
      final list = (result['products'] ?? result['data']) as List? ?? [];
      return list.map((item) => DashboardProduct.fromJson(item).toProduct()).toList();
    }
    return [];
  }
}
