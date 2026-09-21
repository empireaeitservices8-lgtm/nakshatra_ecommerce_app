// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../screens/search_screen.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': "Get 40% Off\nFor All Items",
      'subtitle': "Exclusive Gold Collection",
      'buttonText': "Shop Now",
      'image': 'assets/images/cat2.png',
      'color': const Color(0xFF2E513D),
    },
    {
      'title': "New Arrivals\nDiscover Elegance",
      'subtitle': "Crafted for Perfection",
      'buttonText': "Explore Collection",
      'image': 'assets/images/cat1.png',
      'color': const Color(0xFF5A1827),
    },
    {
      'title': "Bridal Specials\nTimeless Jewelry",
      'subtitle': "For Your Special Day",
      'buttonText': "View Designs",
      'image': 'assets/images/wed5.png',
      'color': const Color(0xFF1C2D37),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: banner['color'],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: goldAccent.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: Image.asset(
                          banner['image'],
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.45),
                        ),
                      ),
                      // Luxury Dark Overlay Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (banner['subtitle'] != null) ...[
                                Text(
                                  banner['subtitle'].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: goldAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                banner['title'],
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (banner['buttonText'] == "Explore Collection") {
                                    Provider.of<CartProvider>(
                                      context,
                                      listen: false,
                                    ).setTabIndex(2);
                                    return;
                                  }

                                  final productVM =
                                      Provider.of<ProductViewModel>(
                                        context,
                                        listen: false,
                                      );
                                  final List<Map<String, String>>
                                  searchProducts = productVM.products
                                      .map(
                                        (p) => <String, String>{
                                          'id': p.id,
                                          'title': p.title,
                                          'subtitle': p.subtitle,
                                          'price': p.price,
                                          'imagePath': p.imagePath,
                                          'category': p.category,
                                          'gender': p.gender,
                                        },
                                      )
                                      .toList();

                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, _, _) => SearchScreen(
                                        allProducts: searchProducts,
                                        initialQuery:
                                            banner['buttonText'] == "Shop Now"
                                            ? "Bracelets"
                                            : "",
                                      ),
                                      transitionsBuilder: (_, anim, _, child) =>
                                          FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                      transitionDuration: const Duration(
                                        milliseconds: 250,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  banner['buttonText'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Three dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isSelected = _currentIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isSelected ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? goldAccent : goldAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
