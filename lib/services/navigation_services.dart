import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/search_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/refer_earn_screen.dart';
import '../screens/saved_addresses_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/signup_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Route<dynamic>? generateRoute(RouteSettings settings) {
  debugPrint("Navigating to: ${settings.name}");
  switch (settings.name) {
    case SplashScreen.path:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case LoginScreen.path:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case MainScreen.path:
      return MaterialPageRoute(builder: (_) => const MainScreen());
    case CartScreen.path:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case ProfileScreen.path:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case SettingsScreen.path:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case CategoriesScreen.path:
      return MaterialPageRoute(builder: (_) => const CategoriesScreen());
    case MyOrdersScreen.path:
      return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
    case MyReviewsScreen.path:
      return MaterialPageRoute(builder: (_) => const MyReviewsScreen());
    case PaymentMethodsScreen.path:
      return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
    case ReferEarnScreen.path:
      return MaterialPageRoute(builder: (_) => const ReferEarnScreen());
    case SavedAddressesScreen.path:
      return MaterialPageRoute(builder: (_) => const SavedAddressesScreen());
    case WishlistScreen.path:
      return MaterialPageRoute(builder: (_) => const WishlistScreen());
    case CheckoutScreen.path:
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());
    case SignUpScreen.path:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case SearchScreen.path:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => SearchScreen(
          allProducts: args?['allProducts'] as List<Map<String, String>>? ?? [],
          initialQuery: args?['initialQuery'] as String?,
        ),
      );
    default:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
  }
}
