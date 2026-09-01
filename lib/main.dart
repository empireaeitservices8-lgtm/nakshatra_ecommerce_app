import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'helpers/sp_helper.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

// Feature ViewModels
import 'features/splashscreen/view/splashscreen.dart';
import 'features/splashscreen/view_model/splash_view_model.dart';
import 'features/auth/view_model/auth_viewmodel.dart';
import 'features/dashboard/view_model/dashboard_viewmodel.dart';
import 'features/devices/view_model/device_viewmodel.dart';
import 'features/device_groups/view_model/device_group_viewmodel.dart';
import 'features/users/view_model/user_viewmodel.dart';
import 'features/cart/view_model/cart_viewmodel.dart';
import 'features/products/view_model/product_viewmodel.dart';
import 'features/wishlist/view_model/wishlist_viewmodel.dart';
import 'features/checkout/view_model/address_viewmodel.dart';
import 'features/checkout/view_model/payment_viewmodel.dart';
import 'features/orders/view_model/order_viewmodel.dart';
import 'features/reviews/view_model/review_viewmodel.dart';
import 'features/profile/view_model/referral_viewmodel.dart';
import 'features/notifications/view_model/notification_viewmodel.dart';
import 'features/gold_scheme/view_model/gold_scheme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPHelper.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => SplashViewModel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => DashboardViewModel()),
        ChangeNotifierProvider(create: (context) => DeviceViewModel()),
        ChangeNotifierProvider(create: (context) => DeviceGroupViewModel()),
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => CartViewModel()),
        ChangeNotifierProvider(create: (context) => ProductViewModel()),
        ChangeNotifierProvider(create: (context) => WishlistViewModel()),
        ChangeNotifierProvider(create: (context) => AddressViewModel()),
        ChangeNotifierProvider(create: (context) => PaymentViewModel()),
        ChangeNotifierProvider(create: (context) => OrderViewModel()),
        ChangeNotifierProvider(create: (context) => ReviewViewModel()),
        ChangeNotifierProvider(create: (context) => ReferralViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationViewModel()),
        ChangeNotifierProvider(create: (context) => GoldSchemeViewModel()),
      ],
      child: const NakshathraApp(),
    ),
  );
}

class NakshathraApp extends StatelessWidget {
  const NakshathraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      themeMode: themeProvider.themeMode,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      navigatorKey: AppConfig.navKey,
      initialRoute: SplashScreen.path,
      routes: appRoutes(),
      onGenerateRoute: onAppGenerateRoute,
    );
  }
}
