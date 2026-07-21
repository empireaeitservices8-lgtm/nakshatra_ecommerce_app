import 'package:flutter/material.dart';
import 'providers/cart_provider.dart';
import 'services/navigation_services.dart';
import 'screens/splash_screen.dart';
import 'constants/color_scheme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const NakshathraApp(),
    ),
  );
}

class NakshathraApp extends StatelessWidget {
  const NakshathraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nakshathra Jewellery',
          themeMode: cart.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          navigatorKey: navigatorKey,
          initialRoute: SplashScreen.path,
          onGenerateRoute: generateRoute,
        );
      },
    );
  }
}
