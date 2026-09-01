import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

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

  void addToCart(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void syncItems(List<CartItem> newItems) {
    _items.clear();
    _items.addAll(newItems);
    notifyListeners();
  }
}

