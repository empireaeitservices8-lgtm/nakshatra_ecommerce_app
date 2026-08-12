import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  // Original cart properties
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // API Integration properties
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  int? _customerId;
  int? get customerId => _customerId;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userPhone;
  String? get userPhone => _userPhone;

  String? _userCity;
  String? get userCity => _userCity;

  List<Product> _products = [];
  List<Product> get products => _products;

  List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  // Selected Odoo branch (mapped from location picker)
  String _selectedBranch = 'vytilla';
  String get selectedBranch => _selectedBranch;

  // Keeps track of the raw cart item maps from Odoo (key: product_id, value: cart line data)
  final Map<int, Map<String, dynamic>> _rawCartLines = {};

  CartProvider() {
    _loadSessionAndData();
  }

  // Initial load
  Future<void> _loadSessionAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (_isLoggedIn) {
      _customerId = prefs.getInt('customerId');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _userPhone = prefs.getString('userPhone');
      _userCity = prefs.getString('userCity');
    }
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    // Fetch products and sync cart/wishlist
    await fetchProducts();
    if (_isLoggedIn && _customerId != null) {
      await fetchCart();
      await fetchWishlist();
    }
    notifyListeners();
  }

  // Location / Branch update
  void updateLocation(String locationLabel) {
    // Map location selections to Odoo branch names
    final lower = locationLabel.toLowerCase();
    if (lower.contains('calicut')) {
      _selectedBranch = 'Calicut';
    } else {
      _selectedBranch = 'vytilla';
    }
    fetchProducts();
  }

  // Fetch products from Odoo branch
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.getProducts(branchName: _selectedBranch);
    if (response['status'] == 'success' && response['products'] != null) {
      final List<dynamic> prodList = response['products'];
      _products = prodList.map((json) => Product.fromJson(json)).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Fetch cart items from Odoo
  Future<void> fetchCart() async {
    if (!_isLoggedIn || _customerId == null) return;

    final response = await ApiService.viewCart(customerId: _customerId!);
    if (response['status'] == 'success' && response['cart'] != null) {
      _items.clear();
      _rawCartLines.clear();

      final List<dynamic> cartItems = response['cart']['items'] ?? [];
      for (var item in cartItems) {
        final int productId = item['product_id'];
        final int qty = item['quantity'] ?? 1;
        _rawCartLines[productId] = item;

        // Add to items list multiple times based on quantity (backwards compatibility)
        String imgUrl = item['image_url'] ?? '';
        if (imgUrl.startsWith('/')) {
          imgUrl = '${ApiService.baseUrl}$imgUrl';
        }

        for (int i = 0; i < qty; i++) {
          _items.add(CartItem(
            id: productId.toString(),
            title: item['product_name'] ?? '',
            price: '₹${item['price'] ?? 0.0}',
            imagePath: imgUrl,
          ));
        }
      }
      notifyListeners();
    }
  }

  // Fetch wishlist from Odoo
  Future<void> fetchWishlist() async {
    if (!_isLoggedIn || _customerId == null) return;

    final response = await ApiService.viewWishlist(customerId: _customerId!);
    if (response['status'] == 'success' && response['data'] != null) {
      final List<dynamic> list = response['data'];
      _wishlist = list.map((json) {
        // Map wishlist details to Product
        final int prodId = json['product_id'];
        String imgUrl = json['image_url'] ?? '';
        if (imgUrl.startsWith('/')) {
          imgUrl = '${ApiService.baseUrl}$imgUrl';
        }
        
        return Product(
          id: prodId.toString(),
          title: json['product_name'] ?? '',
          subtitle: 'Pure Gold Item',
          price: '₹${json['price'] ?? 0.0}',
          imagePath: imgUrl,
          category: 'Necklaces',
          gender: 'Womens',
        );
      }).toList();
      notifyListeners();
    }
  }

  // Authentication Actions
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.login(email: email, password: password);
    if (response['status'] == 'success' && response['data'] != null) {
      final data = response['data'];
      _customerId = data['customer_id'];
      _userName = data['name'];
      _userEmail = data['email'];
      _userPhone = data['phone'];
      _userCity = data['city'];
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('customerId', _customerId!);
      await prefs.setString('userName', _userName ?? '');
      await prefs.setString('userEmail', _userEmail ?? '');
      await prefs.setString('userPhone', _userPhone ?? '');
      await prefs.setString('userCity', _userCity ?? '');

      await fetchCart();
      await fetchWishlist();
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    _isLoading = false;
    notifyListeners();
    return response;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _customerId = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userCity = null;
    _items.clear();
    _rawCartLines.clear();
    _wishlist.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('customerId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    await prefs.remove('userCity');
    
    notifyListeners();
  }

  // Original UI Theme Setters
  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
      notifyListeners();
    }
  }

  // Cart operations
  Future<void> addToCart(CartItem item) async {
    final int prodId = int.tryParse(item.id) ?? 0;
    
    if (_isLoggedIn && _customerId != null && prodId > 0) {
      // Check if product is already in cart, increment quantity if so
      final existingLine = _rawCartLines[prodId];
      if (existingLine != null) {
        final int lineId = existingLine['cart_line_id'];
        final int currentQty = existingLine['quantity'] ?? 1;
        await ApiService.updateCartQuantity(
          customerId: _customerId!,
          cartLineId: lineId,
          quantity: currentQty + 1,
        );
      } else {
        await ApiService.addToCart(
          customerId: _customerId!,
          productId: prodId,
          quantity: 1,
        );
      }
      await fetchCart();
    } else {
      // Local fallback for guest users
      _items.add(item);
      notifyListeners();
    }
  }

  Future<void> removeSingleItem(String id) async {
    final int prodId = int.tryParse(id) ?? 0;

    if (_isLoggedIn && _customerId != null && prodId > 0) {
      final existingLine = _rawCartLines[prodId];
      if (existingLine != null) {
        final int lineId = existingLine['cart_line_id'];
        final int currentQty = existingLine['quantity'] ?? 1;

        if (currentQty > 1) {
          await ApiService.updateCartQuantity(
            customerId: _customerId!,
            cartLineId: lineId,
            quantity: currentQty - 1,
          );
        } else {
          await ApiService.removeFromCart(
            customerId: _customerId!,
            cartLineId: lineId,
          );
        }
        await fetchCart();
      }
    } else {
      // Local fallback for guest users
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items.removeAt(index);
        notifyListeners();
      }
    }
  }

  Future<void> removeItem(String id) async {
    final int prodId = int.tryParse(id) ?? 0;

    if (_isLoggedIn && _customerId != null && prodId > 0) {
      final existingLine = _rawCartLines[prodId];
      if (existingLine != null) {
        final int lineId = existingLine['cart_line_id'];
        await ApiService.removeFromCart(
          customerId: _customerId!,
          cartLineId: lineId,
        );
        await fetchCart();
      }
    } else {
      // Local fallback
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (_isLoggedIn && _customerId != null) {
      // Clear all items one by one in Odoo
      for (var line in _rawCartLines.values) {
        final int lineId = line['cart_line_id'];
        await ApiService.removeFromCart(customerId: _customerId!, cartLineId: lineId);
      }
      await fetchCart();
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  // Wishlist operations
  Future<void> toggleWishlist(Product product) async {
    final int prodId = int.tryParse(product.id) ?? 0;
    if (!_isLoggedIn || _customerId == null || prodId <= 0) return;

    final isWish = isProductWishlisted(product.id);
    if (isWish) {
      await ApiService.removeFromWishlist(customerId: _customerId!, productId: prodId);
    } else {
      await ApiService.addToWishlist(customerId: _customerId!, productId: prodId);
    }
    await fetchWishlist();
  }

  bool isProductWishlisted(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  // Checkout operation
  Future<Map<String, dynamic>> checkout({
    required String paymentMethod,
    required String shippingAddress,
    required String shippingCity,
    required String shippingPhone,
    String notes = '',
  }) async {
    if (!_isLoggedIn || _customerId == null) {
      return {'status': 'error', 'message': 'User session not found.'};
    }

    _isLoading = true;
    notifyListeners();

    final response = await ApiService.checkout(
      customerId: _customerId!,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      shippingCity: shippingCity,
      shippingPhone: shippingPhone,
      notes: notes,
    );

    if (response['status'] == 'success') {
      _items.clear();
      _rawCartLines.clear();
    }

    _isLoading = false;
    notifyListeners();
    return response;
  }
}
