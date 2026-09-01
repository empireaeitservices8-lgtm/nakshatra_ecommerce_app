import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../providers/view_model.dart';
import '../../../repositories/wishlist_repository.dart';

class WishlistViewModel extends BaseViewModel {
  final WishlistRepository _repository = WishlistRepository();
  List<Product> _items = [];

  WishlistViewModel() : super(name: "WishlistViewModel");

  List<Product> get items => _items;

  String _formatError(dynamic e) {
    final errStr = e.toString();
    if (errStr.contains('SocketException') || errStr.contains('DioException') || errStr.contains('HttpException')) {
      return "Network connection issue. Please check your connection and try again.";
    }
    return "Something went wrong. Please try again.";
  }

  Future<void> fetchWishlist(String customerId) async {
    setBusy(true);
    clearError();

    try {
      _items = await _repository.getWishlist(customerId: customerId);
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
    }
  }

  Future<void> addToWishlist(String customerId, Product product) async {
    setBusy(true);
    clearError();

    final previousItems = List<Product>.from(_items);

    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);
      notifyListeners();
    }

    try {
      await _repository.addToWishlist(customerId: customerId, productId: product.id);
    } catch (e) {
      _items = previousItems;
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
    }
  }

  Future<void> removeFromWishlist(String customerId, String productId) async {
    setBusy(true);
    clearError();

    final previousItems = List<Product>.from(_items);
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();

    try {
      await _repository.removeFromWishlist(customerId: customerId, productId: productId);
    } catch (e) {
      _items = previousItems;
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
    }
  }

  bool isWishlisted(String productId) {
    return _items.any((item) => item.id == productId);
  }
}
