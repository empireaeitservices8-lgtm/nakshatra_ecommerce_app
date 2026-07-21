import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import 'categories_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  static const String path = '/home';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  final Color emeraldGreen = const Color(0xFF2E513D);
  final Color goldAccent = const Color(0xFFD4AF37);
  final Color goldDark = const Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currentIndex = cartProvider.currentTabIndex;
    final isDark = cartProvider.isDarkMode;
    final navBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  "Home",
                  currentIndex,
                  cartProvider,
                ),
                _buildNavItem(
                  1,
                  Icons.grid_view_outlined,
                  Icons.grid_view_rounded,
                  "Categories",
                  currentIndex,
                  cartProvider,
                ),
                _buildNavItem(
                  2,
                  Icons.settings_outlined,
                  Icons.settings,
                  "Settings",
                  currentIndex,
                  cartProvider,
                ),
                _buildNavItem(
                  3,
                  Icons.person_outline,
                  Icons.person,
                  "You",
                  currentIndex,
                  cartProvider,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData solidIcon,
    String label,
    int currentIndex,
    CartProvider provider,
  ) {
    final isSelected = currentIndex == index;
    final isDark = provider.isDarkMode;
    final activeColor = isDark ? goldAccent : emeraldGreen;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => provider.setTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
