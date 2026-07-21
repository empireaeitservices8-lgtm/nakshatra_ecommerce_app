import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const String path = '/categories';
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedGender = 'Womens';

  Color get _goldDark => const Color(0xFFB8860B);
  Color get _goldMid => const Color(0xFFD4A017);
  Color get _goldLight => const Color(0xFFFFD700);
  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _emeraldGreen => const Color(0xFF2E513D);

  final List<String> _genders = ['Womens', 'Gents', 'Kids', 'Unisex'];

  // Map of subcategories per gender
  final Map<String, List<Map<String, String>>> _categoriesMap = const {
    'Womens': [
      {
        'title': 'Necklaces',
        'image': 'assets/images/necklace2.png',
        'tagline': 'Timeless elegance for your neckline',
      },
      {
        'title': 'Earrings',
        'image': 'assets/images/earring.png',
        'tagline': 'Dazzling pieces for every occasion',
      },
      {
        'title': 'Rings',
        'image': 'assets/images/rings.png',
        'tagline': 'Crafted luxury at your fingertips',
      },
      {
        'title': 'Bracelets',
        'image': 'assets/images/bracelet.png',
        'tagline': 'Delicate wristwear in pure gold',
      },
      {
        'title': 'Wedding Sets',
        'image': 'assets/images/wed5.png',
        'tagline': 'Bridal masterpieces for your big day',
      },
    ],
    'Gents': [
      {
        'title': 'Chains',
        'image': 'assets/images/necklace.png',
        'tagline': 'Sleek and solid everyday gold chains',
      },
      {
        'title': 'Rings',
        'image': 'assets/images/ring.png',
        'tagline': 'Bold & statement rings for men',
      },
      {
        'title': 'Bracelets',
        'image': 'assets/images/bracelet.png',
        'tagline': 'Stylish and sturdy gold bracelets',
      },
      {
        'title': 'Kada',
        'image': 'assets/images/product1.png',
        'tagline': 'Traditional crafted gold kadas',
      },
    ],
    'Kids': [
      {
        'title': 'Earrings',
        'image': 'assets/images/earring.png',
        'tagline': 'Cute & lightweight studs for children',
      },
      {
        'title': 'Bracelets',
        'image': 'assets/images/bracelet.png',
        'tagline': 'Charming adjustable link wristwear',
      },
      {
        'title': 'Rings',
        'image': 'assets/images/ring.png',
        'tagline': 'Delicate and smooth little gold rings',
      },
    ],
    'Unisex': [
      {
        'title': 'Chains',
        'image': 'assets/images/necklace.png',
        'tagline': 'Classic chains designed for everyone',
      },
      {
        'title': 'Rings',
        'image': 'assets/images/rings.png',
        'tagline': 'Elegant everyday bands for all',
      },
      {
        'title': 'Bracelets',
        'image': 'assets/images/bracelet.png',
        'tagline': 'Versatile wristwear to complement any style',
      },
    ],
  };

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
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardWhite,
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
                Icons.shopping_cart_outlined,
                color: Provider.of<CartProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black87,
                size: 22,
              ),
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

  @override
  Widget build(BuildContext context) {
    final subCategories = _categoriesMap[_selectedGender] ?? [];
    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nakshathra",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _goldDark,
                            letterSpacing: 1.5,
                          ),
                        ),
                        _buildCartIconWithBadge(context),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Our Categories",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Explore our premium collections crafted with gold, diamonds, and pure love.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- GENDER PILLS SELECTOR ---
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _genders.length,
                        itemBuilder: (context, index) {
                          final gender = _genders[index];
                          final isSelected = _selectedGender == gender;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGender = gender;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _emeraldGreen
                                      : _cardWhite,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : _goldMid.withOpacity(0.3),
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: _emeraldGreen.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    gender,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // --- CATEGORIES LIST ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = subCategories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        // Open Search Screen with pre-filled category filter (e.g. Gents Rings)
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SearchScreen(
                              allProducts: HomeScreen.allProducts,
                              initialQuery: '$_selectedGender ${cat['title']}',
                            ),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(
                              milliseconds: 250,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: _cardWhite,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _goldMid.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: _goldMid.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            children: [
                              // Details
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cat['title']!,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat['tagline']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: textMuted,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Image
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _goldLight.withOpacity(0.1),
                                        _goldMid.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Image.asset(
                                    cat['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: subCategories.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
