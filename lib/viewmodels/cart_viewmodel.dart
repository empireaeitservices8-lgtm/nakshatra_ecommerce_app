import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/view_model.dart';
import '../repositories/cart_repository.dart';
import '../services/navigation_services.dart';

class CartViewModel extends BaseViewModel {
  final CartRepository _repository = CartRepository();

  List<CartItem> _items = [];
  double _subtotal = 0.0;
  double _shipping = 0.0;
  double _total = 0.0;

  int _currentTabIndex = 0;
  bool _isDarkMode = false;

  CartViewModel() : super(name: "CartViewModel");

  List<CartItem> get items => _items;
  double get subtotal => _subtotal;
  double get shipping => _shipping;
  double get total => _total;

  int get currentTabIndex => _currentTabIndex;
  bool get isDarkMode => _isDarkMode;

  int getItemQuantity(String productId) {
    for (final item in _items) {
      if (item.productId == productId) {
        return item.quantity;
      }
    }
    return 0;
  }

  bool isProductInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  void _syncToCartProvider() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.syncItems(_items);
      } catch (e) {
        debugPrint("Failed to sync to CartProvider: $e");
      }
    }
  }

  void _recalculateTotalsOptimistically() {
    double sub = 0.0;
    for (final item in _items) {
      double priceVal = double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      sub += priceVal * item.quantity;
    }
    _subtotal = sub;
    _shipping = 0.0;
    _total = _subtotal + _shipping;
  }

  String _formatError(dynamic e) {
    final errStr = e.toString();
    if (errStr.contains('Exception:')) {
      return errStr.replaceFirst('Exception:', '').trim();
    }
    if (errStr.contains('404')) {
      return "URL not found";
    }
    if (errStr.contains('SocketException') || errStr.contains('DioException') || errStr.contains('HttpException')) {
      return "Network connection issue. Please check your connection and try again.";
    }
    if (errStr.contains('500') || errStr.contains('Internal Server Error')) {
      return "Something went wrong on our end. Please try again later.";
    }
    return errStr;
  }

  Future<void> fetchCart(String customerId) async {
    setBusy(true);
    clearError();

    try {
      final res = await _repository.getCart(customerId: customerId);
      _items = res['items'] as List<CartItem>;
      _subtotal = res['subtotal'] as double;
      _shipping = res['shipping'] as double;
      _total = res['total'] as double;
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
      _syncToCartProvider();
    }
  }

  final Set<String> _pendingCartProductIds = {};
  final Set<String> _pendingCartLineIds = {};

  bool isProductPending(String productId) => _pendingCartProductIds.contains(productId);
  bool isLinePending(String lineId) => _pendingCartLineIds.contains(lineId);

  Future<bool> addToCart(String customerId, String productId, {int quantity = 1, Product? product}) async {
    if (_pendingCartProductIds.contains(productId)) return false;
    _pendingCartProductIds.add(productId);

    setBusy(true);
    clearError();

    // Backup for rollback
    final previousItems = List<CartItem>.from(_items);
    final previousSubtotal = _subtotal;
    final previousShipping = _shipping;
    final previousTotal = _total;

    // Optimistic Update
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final existingItem = _items[index];
      _items[index] = CartItem(
        id: existingItem.id,
        productId: existingItem.productId,
        title: existingItem.title,
        price: existingItem.price,
        imagePath: existingItem.imagePath,
        quantity: existingItem.quantity + quantity,
      );
    } else if (product != null) {
      _items.add(CartItem(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        title: product.title,
        price: product.price,
        imagePath: product.imagePath,
        quantity: quantity,
      ));
    }

    _recalculateTotalsOptimistically();
    notifyListeners();
    _syncToCartProvider();

    try {
      await _repository.addToCart(customerId: customerId, productId: productId, quantity: quantity);
      final res = await _repository.getCart(customerId: customerId);
      _items = res['items'] as List<CartItem>;
      _subtotal = res['subtotal'] as double;
      _shipping = res['shipping'] as double;
      _total = res['total'] as double;
      setBusy(false);
      _syncToCartProvider();
      return true;
    } catch (e) {
      _items = previousItems;
      _subtotal = previousSubtotal;
      _shipping = previousShipping;
      _total = previousTotal;
      setErrorMessage(_formatError(e));
      setBusy(false);
      _syncToCartProvider();
      return false;
    } finally {
      _pendingCartProductIds.remove(productId);
    }
  }

  Future<void> updateQuantity(String customerId, String cartLineId, int quantity) async {
    if (_pendingCartLineIds.contains(cartLineId)) return;
    _pendingCartLineIds.add(cartLineId);

    setBusy(true);
    clearError();

    final previousItems = List<CartItem>.from(_items);
    final previousSubtotal = _subtotal;
    final previousShipping = _shipping;
    final previousTotal = _total;

    final index = _items.indexWhere((item) => item.id == cartLineId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final existingItem = _items[index];
        _items[index] = CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          title: existingItem.title,
          price: existingItem.price,
          imagePath: existingItem.imagePath,
          quantity: quantity,
        );
      }
      _recalculateTotalsOptimistically();
      notifyListeners();
      _syncToCartProvider();
    }

    try {
      if (quantity <= 0) {
        await _repository.removeCartItem(customerId: customerId, cartLineId: cartLineId);
      } else {
        await _repository.updateQuantity(customerId: customerId, cartLineId: cartLineId, quantity: quantity);
      }
      final res = await _repository.getCart(customerId: customerId);
      _items = res['items'] as List<CartItem>;
      _subtotal = res['subtotal'] as double;
      _shipping = res['shipping'] as double;
      _total = res['total'] as double;
    } catch (e) {
      _items = previousItems;
      _subtotal = previousSubtotal;
      _shipping = previousShipping;
      _total = previousTotal;
      setErrorMessage(_formatError(e));
    } finally {
      _pendingCartLineIds.remove(cartLineId);
      setBusy(false);
      _syncToCartProvider();
    }
  }

  Future<void> removeCartItem(String customerId, String cartLineId) async {
    if (_pendingCartLineIds.contains(cartLineId)) return;
    _pendingCartLineIds.add(cartLineId);

    setBusy(true);
    clearError();

    final previousItems = List<CartItem>.from(_items);
    final previousSubtotal = _subtotal;
    final previousShipping = _shipping;
    final previousTotal = _total;

    _items.removeWhere((item) => item.id == cartLineId);
    _recalculateTotalsOptimistically();
    notifyListeners();
    _syncToCartProvider();

    try {
      await _repository.removeCartItem(customerId: customerId, cartLineId: cartLineId);
      final res = await _repository.getCart(customerId: customerId);
      _items = res['items'] as List<CartItem>;
      _subtotal = res['subtotal'] as double;
      _shipping = res['shipping'] as double;
      _total = res['total'] as double;
    } catch (e) {
      _items = previousItems;
      _subtotal = previousSubtotal;
      _shipping = previousShipping;
      _total = previousTotal;
      setErrorMessage(_formatError(e));
    } finally {
      _pendingCartLineIds.remove(cartLineId);
      setBusy(false);
      _syncToCartProvider();
    }
  }

  Future<void> clearCart(String customerId) async {
    setBusy(true);
    clearError();

    try {
      for (final item in _items) {
        await _repository.removeCartItem(customerId: customerId, cartLineId: item.id);
      }
      _items.clear();
      _subtotal = 0.0;
      _shipping = 0.0;
      _total = 0.0;
    } catch (e) {
      setErrorMessage(_formatError(e));
    } finally {
      setBusy(false);
      _syncToCartProvider();
    }
  }
}
