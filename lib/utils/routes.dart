import 'package:flutter/material.dart';
import '../screens/cart_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/category_products_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/gold_scheme/gold_scheme_screen.dart';
import '../screens/help_center_screen.dart';
import '../screens/latest_models_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recommendations_screen.dart';
import '../screens/refer_earn_screen.dart';
import '../screens/register_screen.dart';
import '../screens/saved_addresses_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splashscreen.dart';
import '../screens/wishlist_screen.dart';
import 'connection_failed_screen.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    SplashScreen.path: (context) => const SplashScreen(),
    LoginScreen.routeName: (context) => const LoginScreen(),
    OtpVerificationScreen.routeName: (context) => const OtpVerificationScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),
    '/dashboard': (context) => const MainScreen(),
    MainScreen.path: (context) => const MainScreen(),
    CartScreen.path: (context) => const CartScreen(),
    ProfileScreen.path: (context) => const ProfileScreen(),
    SettingsScreen.path: (context) => const SettingsScreen(),
    CategoriesScreen.path: (context) => const CategoriesScreen(),
    MyOrdersScreen.path: (context) => const MyOrdersScreen(),
    MyReviewsScreen.path: (context) => const MyReviewsScreen(),
    PaymentMethodsScreen.path: (context) => const PaymentMethodsScreen(),
    ReferEarnScreen.path: (context) => const ReferEarnScreen(),
    SavedAddressesScreen.path: (context) => const SavedAddressesScreen(),
    WishlistScreen.path: (context) => const WishlistScreen(),
    CheckoutScreen.path: (context) => const CheckoutScreen(),
    GoldSchemeScreen.path: (context) => const GoldSchemeScreen(),
    ChatScreen.path: (context) => const ChatScreen(),
    LatestModelsScreen.path: (context) => const LatestModelsScreen(),
    RecommendationsScreen.path: (context) => const RecommendationsScreen(),
    HelpCenterScreen.path: (context) => const HelpCenterScreen(),
    '/signup': (context) => const RegisterScreen(),
    ConnectionFailedScreen.routeName: (context) => const ConnectionFailedScreen(),
  };
}

Route<dynamic>? onAppGenerateRoute(RouteSettings settings) {
  debugPrint("Navigating to: ${settings.name}");
  switch (settings.name) {
    case ProductDetailScreen.path:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: args['productId'] as String,
          initialTitle: args['initialTitle'] as String,
          initialPrice: args['initialPrice'] as String,
          initialImagePath: args['initialImagePath'] as String,
          heroTag: args['heroTag'] as String?,
        ),
      );
    case SearchScreen.path:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => SearchScreen(
          allProducts: args?['allProducts'] as List<Map<String, String>>? ?? [],
          initialQuery: args?['initialQuery'] as String?,
        ),
      );
    case CategoryProductsScreen.path:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: args['categoryId'] as String,
          categoryName: args['categoryName'] as String,
        ),
      );
    default:
      return null;
  }
}
