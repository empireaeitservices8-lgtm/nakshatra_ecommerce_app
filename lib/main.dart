import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'helpers/sp_helper.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
import 'providers/loading_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splashscreen.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';
import 'viewmodels/address_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/gold_scheme_viewmodel.dart';
import 'viewmodels/help_center_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/payment_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/referral_viewmodel.dart';
import 'viewmodels/review_viewmodel.dart';
import 'viewmodels/splash_view_model.dart';
import 'viewmodels/wishlist_viewmodel.dart';
import 'widgets/global_loading_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPHelper.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => LoadingProvider()),
        ChangeNotifierProvider(create: (context) => SplashViewModel()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
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
        ChangeNotifierProvider(create: (context) => HelpCenterViewModel()),
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
      builder: (context, child) {
        return GlobalLoadingOverlay(child: child);
      },
    );
  }
}
