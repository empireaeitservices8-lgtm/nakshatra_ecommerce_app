// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/models/category.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const String path = '/categories';
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Color get _goldDark => const Color(0xFFB8860B);
  Color get _goldMid => const Color(0xFFD4A017);
  Color get _goldLight => const Color(0xFFFFD700);
  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productVM = Provider.of<ProductViewModel>(context, listen: false);
      List<Future> futures = [productVM.fetchCategories()];
      if (productVM.products.isEmpty) {
        futures.add(productVM.fetchProducts());
      }
      await Future.wait(futures);
      if (mounted && productVM.errorMessage != null) {
        ToastHelper.showErrorToast(context, productVM.errorMessage!);
      }
    });
  }

  Widget _buildImage(String path, {BoxFit fit = BoxFit.contain}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        cacheWidth: 200,
        cacheHeight: 200,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/necklace2.png', fit: fit),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/necklace2.png', fit: fit),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CartProvider, bool>(
      selector: (_, cp) => cp.isDarkMode,
      builder: (context, isDark, _) {
        final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
        final textMuted = isDark ? Colors.white60 : Colors.black54;

        return Scaffold(
          backgroundColor: _bgCream,
          body: SafeArea(
            child: Consumer<ProductViewModel>(
              builder: (context, productVM, _) {
                final categoriesList = productVM.categories;
                return CustomScrollView(
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
                          ],
                        ),
                      ),
                    ),

                    // --- CATEGORIES LIST ---
                    if (productVM.isLoading && categoriesList.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF262626)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }, childCount: 3),
                        ),
                      )
                    else if (categoriesList.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "No categories available",
                            style: TextStyle(color: textMuted),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final cat = categoriesList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    CategoryProductsScreen.path,
                                    arguments: {
                                      'categoryId': cat.id,
                                      'categoryName': cat.name,
                                    },
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  cat.name,
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textDark,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Explore our beautiful collections of ${cat.name}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: textMuted,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                            child: _buildImage(
                                              cat.imageUrl,
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
                          }, childCount: categoriesList.length),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Category catPlaceholder() {
    return Category(id: '', name: '', imageUrl: '');
  }
}

// Simple dummy class to avoid compile issues
class DummyCategory {
  final String id = '';
  final String name = '';
  final String imageUrl = '';
}

extension CategoryFallback on List {
  dynamic firstWhere(
    bool Function(dynamic) test, {
    required dynamic Function() orElse,
  }) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return orElse();
  }
}
