import '../config/app_config.dart';

class UrlHelpers {
  static String get baseUrl {
    switch (AppConfig.environment) {
      case Environment.dg:
        return 'http://100.52.86.195:8069/api/ecommerce';
      case Environment.uat:
        return 'http://100.52.86.195:8069/api/ecommerce';
      case Environment.live:
        return 'http://100.52.86.195:8069/api/ecommerce';
    }
  }

  // Common endpoint paths
  static const String login = '/login';
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
  static const String addresses = '/addresses';
  static const String payments = '/payments';
  static const String goldScheme = '/gold-scheme';
  static const String referrals = '/referrals';
  static const String referralInfo = '/referral/info';
  static const String reviews = '/reviews';
  static const String notifications = '/notifications';
  static const String recommendations = '/recommendations';
  static const String latestModels = '/latest_models';
  static const String productSearch = '/products/search';
  static const String branches = '/branches';
  static const String helpCenter = '/help_center';
  static const String chatInfo = '/chat_info';
  static const String deleteCustomer = '/customer/delete';
}
