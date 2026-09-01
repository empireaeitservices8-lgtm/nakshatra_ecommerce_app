import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';
import '../constants/app_colors.dart';
import '../screens/latest_models_screen.dart';
import 'latest_model_card.dart';

class LatestModelsShowcase extends StatelessWidget {
  const LatestModelsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final productVM = Provider.of<ProductViewModel>(context);
    final latestItems = productVM.latestProducts;

    if (latestItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latest Models",
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
                  "Freshly crafted new arrivals",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, LatestModelsScreen.path);
              },
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
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: latestItems.length,
            itemBuilder: (context, index) {
              final product = latestItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: LatestModelCard(
                  id: product.id,
                  title: product.title,
                  subtitle: product.subtitle,
                  price: product.price,
                  imagePath: product.imagePath,
                  inStock: product.inStock,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
