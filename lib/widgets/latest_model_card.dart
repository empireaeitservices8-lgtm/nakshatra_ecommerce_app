// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../helpers/cart_animation_helper.dart';
import '../helpers/toast_helper.dart';
import '../screens/product_detail_screen.dart';

class LatestModelCard extends StatefulWidget {
  final String id, title, subtitle, price, imagePath;
  final bool inStock;
  const LatestModelCard({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    this.inStock = true,
  });

  @override
  State<LatestModelCard> createState() => _LatestModelCardState();
}

class _LatestModelCardState extends State<LatestModelCard> {
  final GlobalKey _imageKey = GlobalKey();
  double _scale = 1.0;

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
        cacheWidth: 300,
        cacheHeight: 300,
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
        errorBuilder: (_, _, _) => Image.asset(
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

  @override
  Widget build(BuildContext context) {
    return Selector<CartViewModel, bool>(
      selector: (_, vm) => vm.isDarkMode,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
        final borderCol = isDark ? Colors.white12 : Colors.grey.shade200;
        final goldAccent = const Color(0xFFD4AF37);

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
                'heroTag': 'latest_model_${widget.id}',
              },
            );
          },
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 150,
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
                    Expanded(
                      child: Container(
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
                              tag: 'latest_model_${widget.id}',
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
                              top: 4,
                              right: 4,
                              child: Selector<WishlistViewModel, bool>(
                                selector: (_, vm) => vm.isWishlisted(widget.id),
                                builder: (context, favorited, _) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final customerId =
                                          Provider.of<AuthViewModel>(
                                            context,
                                            listen: false,
                                          ).currentUser?.id ??
                                          '1';
                                      final wishlistVM =
                                          Provider.of<WishlistViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      if (favorited) {
                                        final success = await wishlistVM
                                            .removeFromWishlist(
                                              customerId,
                                              widget.id,
                                            );
                                        if (context.mounted) {
                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Removed from Wishlist",
                                                ),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  wishlistVM.errorMessage ??
                                                      "Failed to remove from Wishlist",
                                                ),
                                                backgroundColor:
                                                    Colors.red.shade800,
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        final success = await wishlistVM
                                            .addToWishlist(
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
                                        if (context.mounted) {
                                          if (success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Added to Wishlist",
                                                ),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  wishlistVM.errorMessage ??
                                                      "Failed to add to Wishlist",
                                                ),
                                                backgroundColor:
                                                    Colors.red.shade800,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        favorited
                                            ? Icons.favorite
                                            : Icons.favorite_border_rounded,
                                        color: favorited
                                            ? const Color(0xFFE53935)
                                            : (isDark
                                                  ? Colors.white70
                                                  : Colors.black54),
                                        size: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom content block
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFF6F5F8),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.price,
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? goldAccent
                                        : const Color(0xFF8A2BE2),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Floating circular cart action button
                          Selector<CartViewModel, int>(
                            selector: (_, vm) => vm.getItemQuantity(widget.id),
                            builder: (context, cartQty, _) {
                              return GestureDetector(
                                onTap: () async {
                                  if (!widget.inStock) {
                                    ToastHelper.showErrorToast(
                                      context,
                                      "This item is currently out of stock.",
                                    );
                                    return;
                                  }
                                  CartAnimationHelper.runAddToCartAnimation(
                                    context: context,
                                    imageKey: _imageKey,
                                    imagePath: widget.imagePath,
                                  );
                                  final cartVM = Provider.of<CartViewModel>(
                                    context,
                                    listen: false,
                                  );
                                  final customerId =
                                      Provider.of<AuthViewModel>(
                                        context,
                                        listen: false,
                                      ).currentUser?.id ??
                                      '1';
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
                                        content: Text(
                                          cartVM.errorMessage ??
                                              "Failed to add item to Bag",
                                        ),
                                        backgroundColor: Colors.red.shade800,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: !widget.inStock
                                        ? Colors.grey.shade400
                                        : (cartQty > 0
                                              ? const Color(0xFF2E513D)
                                              : const Color(0xFF8A2BE2)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cartQty > 0
                                        ? Icons.check_rounded
                                        : Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              );
                            },
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
      },
    );
  }
}
