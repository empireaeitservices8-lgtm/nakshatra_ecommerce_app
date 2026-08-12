import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_products.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/signature_collection_banner.dart';
import '../widgets/latest_models_showcase.dart';
import 'search_screen.dart';
import 'cart_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final ValueNotifier<String> _selectedLocation = ValueNotifier<String>(
    "Ernakulam 682303",
  );

  // Keep allProducts static map list inside HomeScreen to avoid breaking other legacy references.
  static const List<Map<String, String>> allProducts = [
    {
      'id': '1',
      'title': 'Bangles Set',
      'subtitle': 'Gold',
      'price': '₹120.00',
      'imagePath': 'assets/images/product1.png',
      'category': 'Bracelets',
      'gender': 'Womens',
    },
    {
      'id': '2',
      'title': 'Wedding Set',
      'subtitle': 'Gold',
      'price': '₹369.00',
      'imagePath': 'assets/images/product5.png',
      'category': 'Wedding Sets',
      'gender': 'Womens',
    },
    {
      'id': '3',
      'title': 'Diamond Ring',
      'subtitle': 'Diamond and Gold',
      'price': '₹369.00',
      'imagePath': 'assets/images/product3.png',
      'category': 'Rings',
      'gender': 'Unisex',
    },
    {
      'id': '4',
      'title': 'Necklace Set',
      'subtitle': 'Gold',
      'price': '₹369.00',
      'imagePath': 'assets/images/product2.png',
      'category': 'Necklaces',
      'gender': 'Womens',
    },
    {
      'id': '5',
      'title': 'Gold Earrings',
      'subtitle': 'Gold',
      'price': '₹89.00',
      'imagePath': 'assets/images/earring.png',
      'category': 'Earrings',
      'gender': 'Womens',
    },
    {
      'id': '6',
      'title': 'Gold Bracelet',
      'subtitle': 'Gold',
      'price': '₹149.00',
      'imagePath': 'assets/images/bracelet.png',
      'category': 'Bracelets',
      'gender': 'Gents',
    },
    {
      'id': '7',
      'title': 'Gents Gold Ring',
      'subtitle': 'Solid 22k Gold',
      'price': '₹199.00',
      'imagePath': 'assets/images/ring.png',
      'category': 'Rings',
      'gender': 'Gents',
    },
    {
      'id': '8',
      'title': 'Gents Kada Chain',
      'subtitle': 'Classic Gold Link',
      'price': '₹299.00',
      'imagePath': 'assets/images/necklace.png',
      'category': 'Chains',
      'gender': 'Gents',
    },
    {
      'id': '9',
      'title': 'Kids Gold Studs',
      'subtitle': 'Cute Flower Earrings',
      'price': '₹75.00',
      'imagePath': 'assets/images/earring.png',
      'category': 'Earrings',
      'gender': 'Kids',
    },
    {
      'id': '10',
      'title': 'Kids Gold Bracelet',
      'subtitle': 'Adjustable Charm Link',
      'price': '₹95.00',
      'imagePath': 'assets/images/bracelet.png',
      'category': 'Bracelets',
      'gender': 'Kids',
    },
    {
      'id': '11',
      'title': 'Unisex Gold Chain',
      'subtitle': 'Sleek Flat Chain',
      'price': '₹180.00',
      'imagePath': 'assets/images/necklace.png',
      'category': 'Chains',
      'gender': 'Unisex',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: cartProvider.isDarkMode
          ? const Color(0xFF121212)
          : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // ── APP BAR ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).setTabIndex(1);
                        },
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goldAccent.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Transform.scale(
                              scale: 1.35,
                              child: Image.asset(
                                'assets/images/nakshayhra (1).png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Location information
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          ValueListenableBuilder<String>(
                            valueListenable: _selectedLocation,
                            builder: (context, location, _) {
                              return GestureDetector(
                                onTap: () => _showLocationPicker(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      location,
                                      style: GoogleFonts.poppins(
                                        color:
                                            Provider.of<CartProvider>(
                                              context,
                                            ).isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF2C1A00),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color:
                                          Provider.of<CartProvider>(
                                            context,
                                          ).isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF2C1A00),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      _buildCartIconWithBadge(context),
                      const SizedBox(width: 10),
                      // ── NOTIFICATION BUTTON ────────────────────────────
                      GestureDetector(
                        onTap: () => _openNotifications(context),
                        child: _buildNotificationIcon(),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ── SEARCH BAR ROW ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openSearch(context),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Search 'Price'",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              const PromoBannerCarousel(),
              const SizedBox(height: 25),
              Text(
                "Category",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Provider.of<CartProvider>(context).isDarkMode
                      ? Colors.white
                      : const Color(0xFF2C1A00),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Select by style or occasion",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              _buildCategoryList(context),
              const SizedBox(height: 25),
              const SignatureCollectionBanner(),
              const SizedBox(height: 25),
              const LatestModelsShowcase(),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recommendation",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Provider.of<CartProvider>(context).isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C1A00),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Timeless pieces selected for you",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See all",
                      style: GoogleFonts.poppins(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // ── PRODUCT GRID ─────────────────────────────────────────────
              cartProvider.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(color: goldAccent),
                      ),
                    )
                  : cartProvider.products.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              "No products available in this branch.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.59,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: cartProvider.products.length,
                          itemBuilder: (context, index) {
                            final p = cartProvider.products[index];
                            return ProductCard(
                              id: p.id,
                              title: p.title,
                              subtitle: p.subtitle,
                              price: p.price,
                              imagePath: p.imagePath,
                            );
                          },
                        ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // ── Open full-screen search ────────────────────────────────────────────────
  void _openSearch(BuildContext context, {String? initialQuery}) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentProducts = cart.products.map((p) => p.toMap()).toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            SearchScreen(
              allProducts: currentProducts.isNotEmpty ? currentProducts : allProducts,
              initialQuery: initialQuery,
            ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Choose Delivery Location",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1A00),
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<String>(
                valueListenable: _selectedLocation,
                builder: (context, currentLoc, _) {
                  return Column(
                    children:
                        [
                          "Ernakulam 682303",
                          "Kochi 682011",
                          "Trivandrum 695001",
                          "Calicut 673001",
                          "Bangalore 560001",
                        ].map((loc) {
                          final isSelected = currentLoc == loc;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: isSelected
                                  ? const Color(0xFF8A2BE2)
                                  : Colors.grey,
                            ),
                            title: Text(
                              loc,
                              style: GoogleFonts.poppins(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF2C1A00)
                                    : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF2E513D),
                                  )
                                : null,
                            onTap: () {
                              _selectedLocation.value = loc;
                              Provider.of<CartProvider>(context, listen: false).updateLocation(loc);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoundIcon(
    IconData icon,
    Color bgColor, {
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isPrimary ? Colors.white : Colors.black87,
        size: 24,
      ),
    );
  }

  Widget _buildCartIconWithBadge(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: _buildRoundIcon(
              Icons.shopping_cart_outlined,
              Colors.white,
              isPrimary: false,
            ),
          ),
          if (cart.items.isNotEmpty)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${cart.items.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildRoundIcon(
          Icons.notifications_none,
          Colors.white,
          isPrimary: false,
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _categoryItem(context, "Necklaces", 'assets/images/necklace2.png'),
          _categoryItem(context, "Earrings", 'assets/images/earring.png'),
          _categoryItem(context, "Rings", 'assets/images/rings.png'),
          _categoryItem(context, "Bracelets", 'assets/images/bracelet.png'),
          _categoryItem(context, "Wedding Sets", 'assets/images/wed5.png'),
        ],
      ),
    );
  }

  Widget _categoryItem(BuildContext context, String title, String path) {
    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final textDark = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          final cart = Provider.of<CartProvider>(context, listen: false);
          final currentProducts = cart.products.map((p) => p.toMap()).toList();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => SearchScreen(
                allProducts: currentProducts.isNotEmpty ? currentProducts : HomeScreen.allProducts,
                initialQuery: title,
              ),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 250),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFF5F5F5),
              child: Image.asset(path, width: 80, height: 60),
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: textDark)),
          ],
        ),
      ),
    );
  }
}
