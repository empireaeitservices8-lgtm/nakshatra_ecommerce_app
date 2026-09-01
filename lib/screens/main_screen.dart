import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import '../widgets/animated_cart_badge.dart';

class MainScreen extends StatefulWidget {
  static const String path = '/home';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    WishlistScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  final Color emeraldGreen = const Color(0xFF2E513D);
  final Color goldAccent = const Color(0xFFD4AF37);
  final Color goldDark = const Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartVM = Provider.of<CartViewModel>(context);
    final currentIndex = cartProvider.currentTabIndex;
    final isDark = cartProvider.isDarkMode;
    final navBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final activeColor = isDark ? goldAccent : emeraldGreen;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex >= _screens.length ? 0 : currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const CartScreen(),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        },
        backgroundColor: activeColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 24,
            ),
            Positioned(
              right: -5,
              top: -5,
              child: AnimatedCartBadge(count: cartVM.items.length),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: navBg,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        padding: EdgeInsets.zero,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Nav Items
              Row(
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_outlined,
                    Icons.home,
                    "Home",
                    currentIndex,
                    cartProvider,
                  ),
                  const SizedBox(width: 8),
                  _buildNavItem(
                    1,
                    Icons.favorite_border,
                    Icons.favorite,
                    "Wishlist",
                    currentIndex,
                    cartProvider,
                  ),
                ],
              ),
              // Right Nav Items
              Row(
                children: [
                  _buildNavItem(
                    2,
                    Icons.grid_view_outlined,
                    Icons.grid_view_rounded,
                    "Categories",
                    currentIndex,
                    cartProvider,
                  ),
                  const SizedBox(width: 8),
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
            ],
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
      onTap: () {
        provider.setTabIndex(index);
        if (index == 2) {
          Provider.of<ProductViewModel>(context, listen: false).fetchCategories();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.22 : 1.0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: Icon(
                isSelected ? solidIcon : outlineIcon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 12 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
