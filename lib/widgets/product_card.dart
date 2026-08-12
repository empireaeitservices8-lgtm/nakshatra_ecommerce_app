import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final String id, title, subtitle, price, imagePath;
  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isWishlisted = false;

  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/product1.png', fit: fit);
        },
      );
    } else {
      return Image.asset(path, fit: fit);
    }
  }

  void _showProductDetails(BuildContext context) {
    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white70 : Colors.black54;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              // Image
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withAlpha(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildImage(widget.imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.price,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB8860B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "Product Description",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Exquisite pure gold jewelry, certified 22 Karat by Nakshathra Hallmark. Meticulously handcrafted by master artisans to celebrate your special moments with timeless elegance and unmatched brilliance.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addToCart(
                    CartItem(
                      id: widget.id,
                      title: widget.title,
                      price: widget.price,
                      imagePath: widget.imagePath,
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added ${widget.title} to Bag!"),
                      backgroundColor: const Color(0xFF2E513D),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E513D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Add to Bag",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse prices
    double priceVal =
        double.tryParse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
        100.0;
    double originalVal = priceVal / 0.8; // 20% off
    String originalPrice = '₹${originalVal.toStringAsFixed(2)}';

    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final borderCol = isDark ? Colors.white12 : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded Image Container
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildImage(widget.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  // Wishlist Button (Top Right of image container)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final isWish = cartProvider.isProductWishlisted(widget.id);
                        return GestureDetector(
                          onTap: () async {
                            if (!cartProvider.isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please login to wishlist items"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            await cartProvider.toggleWishlist(Product(
                              id: widget.id,
                              title: widget.title,
                              subtitle: widget.subtitle,
                              price: widget.price,
                              imagePath: widget.imagePath,
                              category: '',
                              gender: '',
                            ));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isWish
                                      ? "Removed from Wishlist"
                                      : "Added to Wishlist"),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWish ? Icons.favorite : Icons.favorite_border,
                              color: isWish
                                  ? const Color(0xFFD4AF37)
                                  : (isDark ? Colors.white70 : Colors.black54),
                              size: 15,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Product Title
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Description
            Text(
              "Certified 22K Nakshathra Hallmark gold item.",
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 10,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Stars rating row
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "4.8",
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Price row (Current Price, Original Price, Discount) - scaled down if needed to prevent overflows
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    widget.price,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    originalPrice,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white24
                          : const Color(0xFF2C2C2E), // Dark grey
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "-20%",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Actions buttons row (Add to Cart / Quick View)
            Row(
              children: [
                // Add to Cart button (Black background)
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(
                          CartItem(
                            id: widget.id,
                            title: widget.title,
                            price: widget.price,
                            imagePath: widget.imagePath,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added ${widget.title} to Bag!"),
                            backgroundColor: const Color(0xFF2E513D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Quick View button (White background with grey border)
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      onPressed: () => _showProductDetails(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          width: 1.0,
                        ),
                        foregroundColor: textDark,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Quick View",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
