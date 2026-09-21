import '../helpers/request_deduplicator.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../models/dashboard_product.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();
  final RequestDeduplicator _deduplicator = RequestDeduplicator();

  Future<List<Category>> getCategories() async {
    return _deduplicator.run('categories', () async {
      try {
        final response = await _apiService.post(
          '/categories',
          data: {'params': {}},
        );

        final resData = response.data;
        final result = resData['result'];
        if (result != null) {
          if (result['status'] == 200 ||
              result['success'] == true ||
              result['status'] == 'success') {
            final list =
                (result['categories'] ?? result['data']) as List? ?? [];
            if (list.isNotEmpty) {
              return list.map((item) => Category.fromJson(item)).toList();
            }
          }
        }
      } catch (e) {
        // Fallback gracefully on API errors
      }

      return [
        Category(
          id: '1',
          name: 'Chains',
          imageUrl: 'assets/images/necklace.png',
        ),
        Category(
          id: '2',
          name: 'Earrings',
          imageUrl: 'assets/images/earring.png',
        ),
        Category(
          id: '3',
          name: 'Bangles',
          imageUrl: 'assets/images/bangle.png',
        ),
        Category(
          id: '4',
          name: 'Bracelets',
          imageUrl: 'assets/images/bracelet.png',
        ),
        Category(id: '5', name: 'Rings', imageUrl: 'assets/images/ring.png'),
      ];
    });
  }

  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? gender,
    String? search,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    final response = await _apiService.post(
      '/branch_products',
      data: {'params': {}},
    );

    final resData = response.data;
    final result = resData['result'];
    if (result == null) {
      throw Exception('Invalid server response');
    }

    if (result['status'] == 200 ||
        result['success'] == true ||
        result['status'] == 'success') {
      final list = result['data'] as List? ?? [];
      final products = list.map((item) => Product.fromJson(item)).toList();

      // Filter locally for compatibility with category/gender filters in UI
      var filtered = products;
      if (category != null && category.isNotEmpty) {
        filtered = filtered
            .where((p) => p.category.toLowerCase() == category.toLowerCase())
            .toList();
      }
      if (gender != null && gender.isNotEmpty) {
        filtered = filtered
            .where((p) => p.gender.toLowerCase() == gender.toLowerCase())
            .toList();
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        filtered = filtered
            .where(
              (p) =>
                  p.title.toLowerCase().contains(query) ||
                  p.subtitle.toLowerCase().contains(query),
            )
            .toList();
      }

      return {'products': filtered, 'pagination': null};
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch branch products');
    }
  }

  Future<Product> getProductDetail(String id, {String? customerId}) async {
    final parsedCustomerId = int.tryParse(customerId ?? '1') ?? 1;
    final parsedProductId = int.tryParse(id) ?? 0;

    return _deduplicator.run(
      'product_detail_${parsedProductId}_$parsedCustomerId',
      () async {
        final response = await _apiService.post(
          '/product_detail',
          data: {
            'jsonrpc': '2.0',
            'method': 'call',
            'params': {
              'product_id': parsedProductId,
              'customer_id': parsedCustomerId,
            },
          },
        );

        final resData = response.data;
        final result = resData['result'];
        if (result != null &&
            (result['status'] == 200 ||
                result['status'] == 'success' ||
                result['success'] == true)) {
          final productJson = result['product'] ?? result['data'];
          if (productJson != null) {
            final productDetail = ProductDetail.fromJson(productJson);
            return productDetail.toProduct();
          }
        }
        throw Exception('Failed to load product detail');
      },
    );
  }

  Future<List<Product>> getCategoryProducts({
    required int categoryId,
    required String customerId,
  }) async {
    return _deduplicator.run(
      'category_products_${categoryId}_$customerId',
      () async {
        final response = await _apiService.post(
          '/category_products',
          data: {
            'params': {
              'category_id': categoryId,
              'customer_id': int.tryParse(customerId) ?? 1,
            },
          },
        );

        final resData = response.data;
        final result = resData['result'];
        if (result == null) {
          throw Exception('Invalid server response');
        }

        if (result['status'] == 200 ||
            result['success'] == true ||
            result['status'] == 'success') {
          final list = result['products'] as List? ?? [];
          return list.map((item) => Product.fromJson(item)).toList();
        } else {
          throw Exception(
            result['message'] ?? 'Failed to fetch category products',
          );
        }
      },
    );
  }

  Future<List<Product>> getLatestModels({
    int limit = 5,
    required String customerId,
  }) async {
    return _deduplicator.run('latest_models_${limit}_$customerId', () async {
      final response = await _apiService.post(
        '/latest_models',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'limit': limit,
            'customer_id': int.tryParse(customerId) ?? 1,
          },
        },
      );

      final resData = response.data;
      final result = resData['result'];
      if (result != null &&
          (result['status'] == 200 ||
              result['success'] == true ||
              result['status'] == 'success')) {
        final list = (result['products'] ?? result['data']) as List? ?? [];
        return list
            .map((item) => DashboardProduct.fromJson(item).toProduct())
            .toList();
      }
      return [];
    });
  }

  Future<List<Product>> getRecommendations({
    int limit = 5,
    required String customerId,
  }) async {
    return _deduplicator.run('recommendations_${limit}_$customerId', () async {
      final response = await _apiService.post(
        '/recommendations',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'limit': limit,
            'customer_id': int.tryParse(customerId) ?? 1,
          },
        },
      );

      final resData = response.data;
      final result = resData['result'];
      if (result != null &&
          (result['status'] == 200 ||
              result['success'] == true ||
              result['status'] == 'success')) {
        final list = (result['products'] ?? result['data']) as List? ?? [];
        return list
            .map((item) => DashboardProduct.fromJson(item).toProduct())
            .toList();
      }
      return [];
    });
  }

  Future<List<Product>> searchProducts({
    required String query,
    int? branchId,
  }) async {
    return _deduplicator.run('search_${query}_$branchId', () async {
      final response = await _apiService.post(
        '/products/search',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'query': query, 'branch_id': ?branchId},
        },
      );

      final resData = response.data;
      final result = resData['result'];
      if (result != null &&
          (result['status'] == 200 ||
              result['status'] == 'success' ||
              result['success'] == true)) {
        final list = (result['data'] ?? result['products']) as List? ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    });
  }
}
