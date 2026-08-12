import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class WishlistScreen extends StatefulWidget {
  static const String path = '/wishlist';
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);
  static const Color _emeraldGreen = Color(0xFF2E513D);

  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);

  void _removeItem(Product product) {
    Provider.of<CartProvider>(context, listen: false).toggleWishlist(product);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistItems = cartProvider.wishlist;

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        title: Text(
          "Wishlist",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: _textDark,
          ),
        ),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: _buildCartIconWithBadge(context),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _goldMid.withAlpha(30), height: 1),
        ),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your Wishlist is Empty",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _goldMid.withAlpha(25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Image Container
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _bgCream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _goldMid.withAlpha(30)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: item.imagePath.startsWith('http')
                              ? Image.network(
                                  item.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/images/product1.png', fit: BoxFit.contain),
                                )
                              : Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: _textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.price,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add to Bag & Delete actions
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              color: _emeraldGreen,
                              size: 22,
                            ),
                            onPressed: () {
                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).addToCart(
                                CartItem(
                                  id: item.id,
                                  title: item.title,
                                  price: item.price,
                                  imagePath: item.imagePath,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Added ${item.title} to Bag!",
                                  ),
                                  backgroundColor: _emeraldGreen,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _removeItem(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgCream,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: _textDark,
                size: 20,
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
}
