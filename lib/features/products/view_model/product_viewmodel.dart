import 'package:flutter/material.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/product_repository.dart';

class ProductViewModel extends BaseViewModel {
  final ProductRepository _repository = ProductRepository();

  List<Category> _categories = [];
  List<Product> _products = [];
  Product? _currentProduct;

  List<Product> _searchResults = [];
  List<Product> _categoryProducts = [];
  List<Product> _latestProducts = [];
  List<Product> _recommendationProducts = [];

  ProductViewModel() : super(name: "ProductViewModel");

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  List<Product> get searchResults => _searchResults;
  List<Product> get categoryProducts => _categoryProducts;
  List<Product> get latestProducts => _latestProducts;
  List<Product> get recommendationProducts => _recommendationProducts;

  Future<void> fetchCategories() async {
    setBusy(true);
    clearError();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
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
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchProductDetail(String id) async {
    setBusy(true);
    clearError();

    try {
      _currentProduct = await _repository.getProductDetail(id);
    } catch (e) {
      setErrorMessage(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> searchProducts(String query) async {
    setBusy(true);
    clearError();

    try {
      final res = await _repository.getProducts(search: query);
      _searchResults = res['products'] as List<Product>;
    } catch (e) {
      setErrorMessage(e.toString());
      _searchResults = [];
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchCategoryProducts({
    required int categoryId,
    required String customerId,
  }) async {
    setBusy(true);
    clearError();

    try {
      _categoryProducts = await _repository.getCategoryProducts(
        categoryId: categoryId,
        customerId: customerId,
      );
    } catch (e) {
      setErrorMessage(e.toString());
      _categoryProducts = [];
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchLatestProducts({
    required String customerId,
    String branchName = 'vytilla',
    int limit = 5,
  }) async {
    setBusy(true);
    clearError();

    try {
      _latestProducts = await _repository.getLatestModels(
        customerId: customerId,
        branchName: branchName,
        limit: limit,
      );
    } catch (e) {
      setErrorMessage(e.toString());
      _latestProducts = [];
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchRecommendationProducts({
    required String customerId,
    String branchName = 'vytilla',
    int limit = 5,
  }) async {
    setBusy(true);
    clearError();

    try {
      _recommendationProducts = await _repository.getRecommendations(
        customerId: customerId,
        branchName: branchName,
        limit: limit,
      );
    } catch (e) {
      setErrorMessage(e.toString());
      _recommendationProducts = [];
    } finally {
      setBusy(false);
    }
  }
}
