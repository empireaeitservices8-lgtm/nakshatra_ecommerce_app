// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_product_card.dart';

class LatestModelsScreen extends StatefulWidget {
  static const String path = '/latest-models';

  const LatestModelsScreen({super.key});

  @override
  State<LatestModelsScreen> createState() => _LatestModelsScreenState();
}

class _LatestModelsScreenState extends State<LatestModelsScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productVM = Provider.of<ProductViewModel>(context);

    final isDark = cartProvider.isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    final products = productVM.latestProducts;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Latest Models",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: productVM.isLoading
            ? _buildLoadingGrid()
            : products.isEmpty
            ? _buildEmptyState(textMuted)
            : _buildProductGrid(products, textMuted),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const SkeletonProductCard();
      },
    );
  }

  Widget _buildEmptyState(Color textMuted) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No new models available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List products, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '${products.length} product${products.length == 1 ? '' : 's'} found',
            style: GoogleFonts.poppins(fontSize: 13, color: textMuted),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductCard(
                id: p.id,
                title: p.title,
                subtitle: p.subtitle,
                price: p.price,
                imagePath: p.imagePath,
                inStock: p.inStock,
              );
            },
          ),
        ),
      ],
    );
  }
}
