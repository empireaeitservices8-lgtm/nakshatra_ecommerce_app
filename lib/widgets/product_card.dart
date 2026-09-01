import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/models/cart_item.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/product.dart';
import '../widgets/animated_add_to_cart_button.dart';
import '../helpers/cart_animation_helper.dart';
import '../screens/product_detail_screen.dart';
import '../constants/app_colors.dart';

class ProductCard extends StatefulWidget {
  final String id, title, subtitle, price, imagePath;
  final bool inStock;
  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    this.inStock = true,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final GlobalKey _imageKey = GlobalKey();
  Widget _buildImage(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        key: key,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          _getFallbackAsset(widget.title, widget.subtitle),
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } else {
      return Image.asset(
        path,
        key: key,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          _getFallbackAsset(widget.title, widget.subtitle),
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
  }

  String _getFallbackAsset(String title, String subtitle) {
    final lowerTitle = title.toLowerCase();
    final lowerSubtitle = subtitle.toLowerCase();

    if (lowerTitle.contains('necklace') ||
        lowerSubtitle.contains('necklace') ||
        lowerTitle.contains('chain') ||
        lowerSubtitle.contains('chain')) {
      return 'assets/images/necklace2.png';
    } else if (lowerTitle.contains('earring') ||
        lowerSubtitle.contains('earring') ||
        lowerTitle.contains('stud') ||
        lowerSubtitle.contains('stud')) {
      return 'assets/images/earring.png';
    } else if (lowerTitle.contains('ring') || lowerSubtitle.contains('ring')) {
      return 'assets/images/ring.png';
    } else if (lowerTitle.contains('bangle') ||
        lowerTitle.contains('bracelet') ||
        lowerSubtitle.contains('bangle') ||
        lowerSubtitle.contains('bracelet') ||
        lowerTitle.contains('kada')) {
      return 'assets/images/bracelet.png';
    }

    return 'assets/images/necklace2.png';
  }

  void _showProductDetails(BuildContext context) {
    final isDark = Provider.of<CartViewModel>(
      context,
      listen: false,
    ).isDarkMode;
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
                onPressed: () async {
                  if (!widget.inStock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("There is no stock available."),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }
                  final cartVM = Provider.of<CartViewModel>(
                    context,
                    listen: false,
                  );
                  final authVM = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  );
                  final customerId = authVM.currentUser?.id ?? '1';
                  final product = Product(
                    id: widget.id,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    price: widget.price,
                    imagePath: widget.imagePath,
                    category: '',
                    gender: '',
                  );
                  final success = await cartVM.addToCart(
                    customerId,
                    widget.id,
                    product: product,
                  );
                  Navigator.pop(context);
                  if (success) {
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(cartVM.errorMessage ?? "Failed to add item to Bag"),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !widget.inStock ? Colors.grey : const Color(0xFF2E513D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  widget.inStock ? "Add to Bag" : "Out of Stock",
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

  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    // Parse prices
    double priceVal =
        double.tryParse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
        100.0;
    double originalVal = priceVal / 0.8; // 20% off
    String originalPrice = '₹${originalVal.toStringAsFixed(2)}';

    final cartVM = Provider.of<CartViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final customerId = authVM.currentUser?.id ?? '1';
    final isDark = cartVM.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final borderCol = isDark ? Colors.white12 : Colors.grey.shade200;

    final cartItem = cartVM.items.firstWhere(
      (item) => item.productId == widget.id,
      orElse: () =>
          CartItem(id: '', productId: '', title: '', price: '', imagePath: ''),
    );
    final cartQty = cartItem.id.isNotEmpty ? cartItem.quantity : 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.pushNamed(
          context,
          ProductDetailScreen.path,
          arguments: {
            'productId': widget.id,
            'initialTitle': widget.title,
            'initialPrice': widget.price,
            'initialImagePath': widget.imagePath,
            'heroTag': 'product_card_${widget.id}',
          },
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderCol, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
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
                        : const Color(0xFFF6F5F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Hero(
                        tag: 'product_card_${widget.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildImage(
                            widget.imagePath,
                            key: _imageKey,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      // Wishlist Button (Top Right of image container)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<WishlistViewModel>(
                          builder: (context, wishlistVM, _) {
                            final favorited = wishlistVM.isWishlisted(widget.id);
                            return GestureDetector(
                              onTap: () async {
                                final customerId =
                                    Provider.of<AuthViewModel>(
                                      context,
                                      listen: false,
                                    ).currentUser?.id ??
                                    '1';
                                if (favorited) {
                                  await wishlistVM.removeFromWishlist(
                                    customerId,
                                    widget.id,
                                  );
                                } else {
                                  await wishlistVM.addToWishlist(
                                    customerId,
                                    Product(
                                      id: widget.id,
                                      title: widget.title,
                                      subtitle: widget.subtitle,
                                      price: widget.price,
                                      imagePath: widget.imagePath,
                                      category: '',
                                      gender: '',
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  favorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favorited
                                      ? const Color(0xFF8A2BE2)
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
                                  size: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Bottom content block (inspired by demo screenshot)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFF6F5F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.poppins(
                                color: textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.price,
                              style: GoogleFonts.poppins(
                                color: isDark ? goldAccent : const Color(0xFF8A2BE2),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Floating circular cart action button
                      GestureDetector(
                        onTap: () async {
                          if (!widget.inStock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("There is no stock available."),
                                backgroundColor: Colors.red.shade800,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          CartAnimationHelper.runAddToCartAnimation(
                            context: context,
                            imageKey: _imageKey,
                            imagePath: widget.imagePath,
                          );
                          final product = Product(
                            id: widget.id,
                            title: widget.title,
                            subtitle: widget.subtitle,
                            price: widget.price,
                            imagePath: widget.imagePath,
                            category: '',
                            gender: '',
                          );
                           final success = await cartVM.addToCart(
                             customerId,
                             widget.id,
                             product: product,
                           );
                           if (!success && context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text(cartVM.errorMessage ?? "Failed to add item to Bag"),
                                 backgroundColor: Colors.red.shade800,
                                 behavior: SnackBarBehavior.floating,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(10),
                                 ),
                               ),
                             );
                           }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: !widget.inStock
                                ? Colors.grey.shade400
                                : (cartQty > 0 ? const Color(0xFF2E513D) : const Color(0xFF8A2BE2)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cartQty > 0 ? Icons.check_rounded : Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
