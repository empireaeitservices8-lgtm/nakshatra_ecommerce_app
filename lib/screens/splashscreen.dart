// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/sp_helper.dart';
import '../providers/cart_provider.dart';
import '../services/token_manager.dart';
import '../utils/app_palette.dart';
import '../utils/sp_keys.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_progress_widget.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String path = '/';
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  void _startSplashSequence() {
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final token = SPHelper.getToken() ?? SpHelper.getString(keyToken);

      if (token != null && token.isNotEmpty) {
        TokenManager.setToken(token);
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        final user = SPHelper.getUser();
        if (user != null) {
          authVM.setCurrentUser(user);
        }
        authVM.loadProfile();
        Provider.of<CartProvider>(context, listen: false).setTabIndex(0);
        Navigator.pushReplacementNamed(context, MainScreen.path);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.emeraldDark,
      body: Stack(
        children: [
          // Background subtle ambient radial gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF0F5B47), AppPalette.emeraldDark],
              ),
            ),
          ),

          // Content area with logo and progress
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppPalette.gold.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.diamond_outlined,
                        size: 64,
                        color: AppPalette.gold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'NAKSHATRA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ENTERPRISE JEWELLERY SUITE',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.goldLight.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 48),
                    const AppProgressWidget(
                      color: AppPalette.gold,
                      size: 28,
                      strokeWidth: 2.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
