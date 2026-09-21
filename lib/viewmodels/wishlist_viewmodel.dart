import '../models/product.dart';
import '../providers/view_model.dart';
import '../repositories/wishlist_repository.dart';

class WishlistViewModel extends BaseViewModel {
  final WishlistRepository _repository = WishlistRepository();
  List<Product> _items = [];

  WishlistViewModel() : super(name: "WishlistViewModel");

  List<Product> get items => _items;

  String _formatError(dynamic e) {
    final errStr = e.toString();
    if (errStr.contains('404')) {
      return "URL not found";
    }
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

  final Set<String> _pendingWishlistIds = {};

  bool isItemPending(String productId) => _pendingWishlistIds.contains(productId);

  Future<bool> addToWishlist(String customerId, Product product) async {
    if (_pendingWishlistIds.contains(product.id)) return false;
    _pendingWishlistIds.add(product.id);

    final previousItems = List<Product>.from(_items);

    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);
      notifyListeners();
    }

    try {
      await _repository.addToWishlist(customerId: customerId, productId: product.id);
      return true;
    } catch (e) {
      _items = previousItems;
      setErrorMessage(_formatError(e));
      notifyListeners();
      return false;
    } finally {
      _pendingWishlistIds.remove(product.id);
    }
  }

  Future<bool> removeFromWishlist(String customerId, String productId) async {
    if (_pendingWishlistIds.contains(productId)) return false;
    _pendingWishlistIds.add(productId);

    final previousItems = List<Product>.from(_items);
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();

    try {
      await _repository.removeFromWishlist(customerId: customerId, productId: productId);
      return true;
    } catch (e) {
      _items = previousItems;
      setErrorMessage(_formatError(e));
      notifyListeners();
      return false;
    } finally {
      _pendingWishlistIds.remove(productId);
    }
  }

  bool isWishlisted(String productId) {
    return _items.any((item) => item.id == productId);
  }
}
