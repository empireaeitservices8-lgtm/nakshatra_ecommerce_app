import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants/app_colors.dart';
import '../viewmodels/product_viewmodel.dart';
import '../screens/search_screen.dart';

class SignatureCollectionBanner extends StatelessWidget {
  const SignatureCollectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<CartProvider>(context).isDarkMode;

    return Container(
      width: double.infinity,
      height: 235,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: goldAccent.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                'assets/images/model.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
              ),
            ),
            // Luxury Gradient Overlay (dark emerald fading out to transparent-dark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      isDark 
                          ? Colors.black.withOpacity(0.85) 
                          : emeraldGreen.withOpacity(0.85),
                      isDark
                          ? Colors.black.withOpacity(0.4)
                          : emeraldGreen.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            // Text and button content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: goldAccent.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        "SIGNATURE",
                        style: GoogleFonts.poppins(
                          color: goldAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "The Heritage\nCollection",
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Timeless royal pieces",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final productVM = Provider.of<ProductViewModel>(context, listen: false);
                        final List<Map<String, String>> searchProducts = productVM.products
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
                            pageBuilder: (_, __, ___) => SearchScreen(
                              allProducts: searchProducts,
                              initialQuery: "Wedding Sets",
                            ),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 250),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldAccent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Explore",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 14),
                        ],
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
  }
}
