// 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  static const String path = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // --- AUTOMATIC NAVIGATION ---
    // Change '3' to any number of seconds you prefer
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Screen Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/model.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          // 2. Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2), // Slight dim at top
                  Colors.transparent,
                  Colors.black.withOpacity(0.9), // Very dark at bottom for logo pop
                ],
              ),
            ),
          ),

          // 3. Content Area (Aligned to Bottom)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Pushes logo to the bottom
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- BIG LOGO AT BOTTOM ---
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png', 
                      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                      height: 400, // Large height as requested
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  
                  // Optional: A small loading indicator to let users know it's moving
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37), // Royal Gold
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 50), // Padding from the very bottom edge
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}