// ignore_for_file: duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/models/cart_item.dart';
import 'package:provider/provider.dart';

import '../helpers/cart_animation_helper.dart';
import '../helpers/toast_helper.dart';
import '../models/product.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/animated_add_to_cart_button.dart';
import '../widgets/animated_cart_badge.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String path = '/product-detail';
  final String productId;
  final String initialTitle;
  final String initialPrice;
  final String initialImagePath;
  final String? heroTag;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.initialTitle,
    required this.initialPrice,
    required this.initialImagePath,
    this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey _imageKey = GlobalKey();
  int _activeGalleryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final customerId = authVM.currentUser?.id ?? '1';
      Provider.of<ProductViewModel>(
        context,
        listen: false,
      ).fetchProductDetail(widget.productId, customerId: customerId);
    });
  }

  Widget _buildImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: 600,
        cacheHeight: 600,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/product1.png',
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } else {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/product1.png',
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final cartVM = Provider.of<CartViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final wishlistVM = Provider.of<WishlistViewModel>(context);

    final isDark = cartVM.isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white70 : Colors.black54;

    // Use current API product if loaded, otherwise fallback to constructor initial values
    final currentProduct = productVM.currentProduct;
    final isProductLoaded =
        currentProduct != null && currentProduct.id == widget.productId;

    final title = isProductLoaded ? currentProduct.title : widget.initialTitle;
    final price = isProductLoaded ? currentProduct.price : widget.initialPrice;
    final imagePath = isProductLoaded
        ? currentProduct.imagePath
        : widget.initialImagePath;
    final description = isProductLoaded
        ? currentProduct.description
        : "Exquisite pure gold jewelry, certified 22 Karat by Nakshathra Hallmark. Meticulously handcrafted by master artisans to celebrate your special moments with timeless elegance.";
    final weight = isProductLoaded
        ? '${currentProduct.weightGrams} g'
        : '4.5 g';
    final purity = isProductLoaded ? currentProduct.purity : '22K Gold';
    final inStock = isProductLoaded ? currentProduct.inStock : true;

    // Calculate original price (20% off)
    double priceVal =
        double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 100.0;
    double originalVal = priceVal / 0.8;
    String originalPrice = '₹${originalVal.toStringAsFixed(2)}';

    // Check cart status
    final cartItem = cartVM.items.firstWhere(
      (item) => item.productId == widget.productId,
      orElse: () =>
          CartItem(id: '', productId: '', title: '', price: '', imagePath: ''),
    );
    final cartQty = cartItem.id.isNotEmpty ? cartItem.quantity : 0;
    final customerId = authVM.currentUser?.id ?? '1';

    // Favorite status
    final favorited = wishlistVM.isWishlisted(widget.productId);

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP CUSTOM APP BAR ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: textDark,
                      ),
                    ),
                  ),
                  Text(
                    "Details",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Row(
                    children: [
                      // Wishlist heart button
                      GestureDetector(
                        onTap: () async {
                          if (favorited) {
                            final success = await wishlistVM.removeFromWishlist(
                              customerId,
                              widget.productId,
                            );
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Removed from Wishlist"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wishlistVM.errorMessage ??
                                          "Failed to remove from Wishlist",
                                    ),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              }
                            }
                          } else {
                            final success = await wishlistVM.addToWishlist(
                              customerId,
                              Product(
                                id: widget.productId,
                                title: title,
                                subtitle: isProductLoaded
                                    ? currentProduct.subtitle
                                    : 'Gold',
                                price: price,
                                imagePath: imagePath,
                                category: '',
                                gender: '',
                              ),
                            );
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Added to Wishlist"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wishlistVM.errorMessage ??
                                          "Failed to add to Wishlist",
                                    ),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            favorited
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: favorited
                                ? const Color(0xFFD4AF37)
                                : textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Cart icon with bouncy badge
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              ),
                              child: Container(
                                key: CartAnimationHelper.detailCartKey,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cardWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: textDark,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: AnimatedCartBadge(
                                count: cartVM.items.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── BODY SCROLL ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Product Image Hero Gallery
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              itemCount: 3,
                              onPageChanged: (idx) {
                                setState(() {
                                  _activeGalleryIndex = idx;
                                });
                              },
                              itemBuilder: (context, index) {
                                final imageWidget = Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: _buildImage(
                                      imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                                if (index == 0) {
                                  return Hero(
                                    tag:
                                        widget.heroTag ??
                                        'product_${widget.productId}',
                                    child: imageWidget,
                                  );
                                }
                                return imageWidget;
                              },
                            ),
                            // Page indicators
                            Positioned(
                              bottom: 16,
                              child: Row(
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: _activeGalleryIndex == index
                                        ? 16
                                        : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _activeGalleryIndex == index
                                          ? const Color(0xFFD4AF37)
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Detail Specs & Meta Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isProductLoaded
                                          ? currentProduct.category
                                          : "Gold Jewelry",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    price,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFB8860B),
                                    ),
                                  ),
                                  Text(
                                    originalPrice,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          if (productVM.isLoading || !isProductLoaded) ...[
                            if (productVM.errorMessage != null)
                              Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Error loading details",
                                      style: GoogleFonts.poppins(
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Provider.of<ProductViewModel>(
                                          context,
                                          listen: false,
                                        ).fetchProductDetail(widget.productId);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2E513D,
                                        ),
                                      ),
                                      child: const Text(
                                        "Retry",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD4AF37),
                                    ),
                                  ),
                                ),
                              ),
                          ] else ...[
                            // Specifications Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSpecItem(
                                  "Weight",
                                  weight,
                                  Icons.scale_outlined,
                                  isDark,
                                ),
                                _buildSpecItem(
                                  "Purity",
                                  purity,
                                  Icons.workspace_premium_outlined,
                                  isDark,
                                ),
                                _buildSpecItem(
                                  "Availability",
                                  inStock ? "In Stock" : "Out of Stock",
                                  inStock
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.cancel_outlined,
                                  isDark,
                                  color: inStock
                                      ? const Color(0xFF2E513D)
                                      : Colors.red,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Text(
                              "Description",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Certificate notice
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white54.withOpacity(0.04)
                                    : const Color(0xFF2E513D).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    color: Color(0xFF2E513D),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "BIS Hallmark Certified 22K Gold. Meticulously tested and stamped for purity authenticity.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF2E513D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── STICKY BOTTOM ACTION BAR ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Column for price info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total Price",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: (productVM.isLoading || !isProductLoaded)
                          ? Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : AnimatedAddToCartButton(
                              quantity: cartQty,
                              height: 48,
                              buttonColor: const Color(0xFF2E513D),
                              inStock: inStock,
                              onAdd: () async {
                                if (!inStock) {
                                  ToastHelper.showErrorToast(
                                    context,
                                    "This item is currently out of stock.",
                                  );
                                  return;
                                }
                                // Trigger flying animation
                                CartAnimationHelper.runAddToCartAnimation(
                                  context: context,
                                  imageKey: _imageKey,
                                  imagePath: imagePath,
                                );

                                final product = Product(
                                  id: widget.productId,
                                  title: title,
                                  subtitle: isProductLoaded
                                      ? currentProduct.subtitle
                                      : 'Gold',
                                  price: price,
                                  imagePath: imagePath,
                                  category: '',
                                  gender: '',
                                );

                                // Call View Model adding
                                final success = await cartVM.addToCart(
                                  customerId,
                                  widget.productId,
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                              onRemove: () {
                                if (cartQty > 0) {
                                  cartVM.updateQuantity(
                                    customerId,
                                    cartItem.id,
                                    cartQty - 1,
                                  );
                                }
                              },
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

  Widget _buildSpecItem(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    final boxBg = isDark ? const Color(0xFF262626) : Colors.white;
    final detailCol =
        color ?? (isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B));

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: boxBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: detailCol,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
