import 'package:flutter/material.dart';
import '../features/splashscreen/view/splashscreen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/otp_verification_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/devices/view/device_list_screen.dart';
import '../features/devices/view/add_device_screen.dart';
import '../features/devices/view/device_detail_screen.dart';
import '../features/device_groups/view/device_group_list_screen.dart';
import '../features/users/view/user_list_screen.dart';
import '../features/users/view/add_user_screen.dart';
import '../models/device_models.dart';
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
import 'connection_failed_screen.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    SplashScreen.path: (context) => const SplashScreen(),
    LoginScreen.routeName: (context) => const LoginScreen(),
    OtpVerificationScreen.routeName: (context) => const OtpVerificationScreen(),
    RegisterScreen.routeName: (context) => const RegisterScreen(),
    DashboardScreen.routeName: (context) => const DashboardScreen(),
    DeviceListScreen.routeName: (context) => const DeviceListScreen(),
    AddDeviceScreen.routeName: (context) => const AddDeviceScreen(),
    DeviceGroupListScreen.routeName: (context) => const DeviceGroupListScreen(),
    UserListScreen.routeName: (context) => const UserListScreen(),
    AddUserScreen.routeName: (context) => const AddUserScreen(),
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
    ConnectionFailedScreen.routeName: (context) => const ConnectionFailedScreen(),
  };
}

Route<dynamic>? onAppGenerateRoute(RouteSettings settings) {
  debugPrint("Navigating to: ${settings.name}");
  switch (settings.name) {
    case DeviceDetailScreen.routeName:
      final device = settings.arguments as DeviceModel?;
      return MaterialPageRoute(
        builder: (_) => DeviceDetailScreen(device: device),
      );
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
