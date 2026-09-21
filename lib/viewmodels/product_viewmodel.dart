import 'package:dio/dio.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/view_model.dart';
import '../repositories/product_repository.dart';

class ProductViewModel extends BaseViewModel {
  final ProductRepository _repository = ProductRepository();

  List<Category> _categories = [];
  List<Product> _products = [];
  Product? _currentProduct;
  final Map<String, Product> _productDetailCache = {};

  List<Product> _searchResults = [];
  List<Product> _categoryProducts = [];
  List<Product> _latestProducts = [];
  List<Product> _recommendationProducts = [];

  bool _isLoadingCategories = false;
  bool _isLoadingLatest = false;
  bool _isLoadingRecommendations = false;
  bool _isLoadingCategoryProducts = false;
  bool _isSearching = false;
  bool _isLoadingDetail = false;
  int _searchToken = 0;

  ProductViewModel() : super(name: "ProductViewModel");

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  List<Product> get searchResults => _searchResults;
  List<Product> get categoryProducts => _categoryProducts;
  List<Product> get latestProducts => _latestProducts;
  List<Product> get recommendationProducts => _recommendationProducts;

  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingLatest => _isLoadingLatest;
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  bool get isLoadingCategoryProducts => _isLoadingCategoryProducts;
  bool get isSearching => _isSearching;
  bool get isLoadingDetail => _isLoadingDetail;

  String _formatError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return "URL not found";
      } else if (statusCode == 401 || statusCode == 403) {
        return "Unauthorized access. Please log in again.";
      } else if (statusCode != null && statusCode >= 500) {
        return "Server error occurred. Please try again later.";
      }
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
      return e.message ?? "An error occurred";
    }
    final errStr = e.toString();
    if (errStr.contains('404')) {
      return "URL not found";
    }
    return errStr;
  }

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (_categories.isNotEmpty && !forceRefresh) return;
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({
    String? category,
    String? gender,
    String? search,
    int page = 1,
    int limit = 100,
    String? sort,
  }) async {
    setBusy(true);
    clearError();

    try {
      final res = await _repository.getProducts(
        category: category,
        gender: gender,
        search: search,
        page: page,
        limit: limit,
        sort: sort,
      );
      _products = res['products'] as List<Product>;
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchProductDetail(
    String id, {
    String? customerId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${id}_${customerId ?? "1"}';
    if (_productDetailCache.containsKey(cacheKey) && !forceRefresh) {
      _currentProduct = _productDetailCache[cacheKey];
      notifyListeners();
      return;
    }

    _isLoadingDetail = true;
    notifyListeners();
    clearError();

    try {
      final detail = await _repository.getProductDetail(
        id,
        customerId: customerId,
      );
      _currentProduct = detail;
      _productDetailCache[cacheKey] = detail;
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query, {int? branchId}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearchResults();
      return;
    }

    final currentToken = ++_searchToken;
    _isSearching = true;
    notifyListeners();
    clearError();

    try {
      final products = await _repository.searchProducts(
        query: trimmed,
        branchId: branchId,
      );
      if (currentToken == _searchToken) {
        _searchResults = products;
      }
    } catch (e) {
      if (currentToken == _searchToken) {
        setErrorMessage(_formatError(e));
        _searchResults = [];
      }
    } finally {
      if (currentToken == _searchToken) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  Future<void> fetchCategoryProducts({
    required int categoryId,
    required String customerId,
  }) async {
    _isLoadingCategoryProducts = true;
    setBusy(true);
    clearError();

    try {
      _categoryProducts = await _repository.getCategoryProducts(
        categoryId: categoryId,
        customerId: customerId,
      );
    } catch (e) {
      setErrorMessage(_formatError(e));
      _categoryProducts = [];
    } finally {
      _isLoadingCategoryProducts = false;
      setBusy(false);
    }
  }

  Future<void> fetchLatestProducts({
    required String customerId,
    int limit = 5,
  }) async {
    _isLoadingLatest = true;
    notifyListeners();

    try {
      _latestProducts = await _repository.getLatestModels(
        customerId: customerId,
        limit: limit,
      );
    } catch (e) {
      setErrorMessage(_formatError(e));
      _latestProducts = [];
    } finally {
      _isLoadingLatest = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendationProducts({
    required String customerId,
    int limit = 5,
  }) async {
    _isLoadingRecommendations = true;
    notifyListeners();

    try {
      _recommendationProducts = await _repository.getRecommendations(
        customerId: customerId,
        limit: limit,
      );
    } catch (e) {
      setErrorMessage(_formatError(e));
      _recommendationProducts = [];
    } finally {
      _isLoadingRecommendations = false;
      notifyListeners();
    }
  }
}
