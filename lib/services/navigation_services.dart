import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../screens/splashscreen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
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
import '../screens/gold_scheme/gold_scheme_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/category_products_screen.dart';
import '../screens/latest_models_screen.dart';
import '../screens/recommendations_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = AppConfig.navKey;

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
    case RegisterScreen.routeName:
    case '/signup':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case GoldSchemeScreen.path:
      return MaterialPageRoute(builder: (_) => const GoldSchemeScreen());
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
    case ChatScreen.path:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case CategoryProductsScreen.path:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryId: args['categoryId'] as String,
          categoryName: args['categoryName'] as String,
        ),
      );
    case LatestModelsScreen.path:
      return MaterialPageRoute(builder: (_) => const LatestModelsScreen());
    case RecommendationsScreen.path:
      return MaterialPageRoute(builder: (_) => const RecommendationsScreen());
    default:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
  }
}
