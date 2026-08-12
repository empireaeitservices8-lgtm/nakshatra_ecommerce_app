import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://100.52.86.195:8069';
  static const String dbName = 'db_old';
  
  static String? _sessionCookie;

  // Visit /web?db=db_old to establish a session with the specific database in Odoo
  static Future<String> _getSessionCookie() async {
    if (_sessionCookie != null) return _sessionCookie!;

    try {
      debugPrint("Initializing Odoo database session for database: $dbName...");
      final client = http.Client();
      final request = http.Request('GET', Uri.parse('$baseUrl/web?db=$dbName'))
        ..followRedirects = false;
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      client.close();

      final setCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
      if (setCookie != null) {
        final regExp = RegExp(r'session_id=[^;]+');
        final match = regExp.firstMatch(setCookie);
        if (match != null) {
          _sessionCookie = match.group(0);
          debugPrint("Session initialized successfully: $_sessionCookie");
          return _sessionCookie!;
        }
      }
    } catch (e) {
      debugPrint("Odoo Database handshake error: $e");
    }
    return '';
  }

  static Future<Map<String, String>> _headers() async {
    final cookie = await _getSessionCookie();
    return {
      'Content-Type': 'application/json',
      if (cookie.isNotEmpty) 'Cookie': cookie,
    };
  }

  // Wrapper for JSON-RPC POST requests
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> params) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final headers = await _headers();
      final body = jsonEncode({'params': params});

      debugPrint("API POST request to $path: $body");
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("API Response code for $path: ${response.statusCode}");
      debugPrint("API Response body for $path: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          return {
            'status': 'error',
            'message': data['error']['message'] ?? 'JSON-RPC Error',
          };
        }
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          return result;
        }
        return {'status': 'success', 'data': result};
      } else {
        return {
          'status': 'error',
          'message': 'Server returned HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint("API Request error on $path: $e");
      return {
        'status': 'error',
        'message': 'Connection error: $e',
      };
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _post('/api/ecommerce/register', {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'city': city,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _post('/api/ecommerce/login', {
      'email': email,
      'password': password,
    });
  }

  // Products
  static Future<Map<String, dynamic>> getProducts({required String branchName}) async {
    return _post('/api/ecommerce/branch_products', {
      'branch_name': branchName,
    });
  }

  // Cart
  static Future<Map<String, dynamic>> addToCart({
    required int customerId,
    required int productId,
    required int quantity,
  }) async {
    return _post('/api/ecommerce/cart/add', {
      'customer_id': customerId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  static Future<Map<String, dynamic>> updateCartQuantity({
    required int customerId,
    required int cartLineId,
    required int quantity,
  }) async {
    return _post('/api/ecommerce/cart/update', {
      'customer_id': customerId,
      'cart_line_id': cartLineId,
      'quantity': quantity,
    });
  }

  static Future<Map<String, dynamic>> removeFromCart({
    required int customerId,
    required int cartLineId,
  }) async {
    return _post('/api/ecommerce/cart/remove', {
      'customer_id': customerId,
      'cart_line_id': cartLineId,
    });
  }

  static Future<Map<String, dynamic>> viewCart({required int customerId}) async {
    return _post('/api/ecommerce/cart/view', {
      'customer_id': customerId,
    });
  }

  // Wishlist
  static Future<Map<String, dynamic>> addToWishlist({
    required int customerId,
    required int productId,
  }) async {
    return _post('/api/ecommerce/wishlist/add', {
      'customer_id': customerId,
      'product_id': productId,
    });
  }

  static Future<Map<String, dynamic>> removeFromWishlist({
    required int customerId,
    required int productId,
  }) async {
    return _post('/api/ecommerce/wishlist/remove', {
      'customer_id': customerId,
      'product_id': productId,
    });
  }

  static Future<Map<String, dynamic>> viewWishlist({required int customerId}) async {
    return _post('/api/ecommerce/wishlist/view', {
      'customer_id': customerId,
    });
  }

  // Checkout
  static Future<Map<String, dynamic>> checkout({
    required int customerId,
    required String paymentMethod,
    required String shippingAddress,
    required String shippingCity,
    required String shippingPhone,
    String notes = '',
  }) async {
    return _post('/api/ecommerce/checkout', {
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_phone': shippingPhone,
      'notes': notes,
    });
  }
}
