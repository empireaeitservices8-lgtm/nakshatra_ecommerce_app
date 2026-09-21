// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/constants/app_colors.dart';
import 'package:nakshatra_app/screens/category_products_screen.dart';
import 'package:nakshatra_app/screens/recommendations_screen.dart';
import 'package:nakshatra_app/widgets/product_card.dart';
import 'package:nakshatra_app/widgets/skeleton_product_card.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';
import '../providers/cart_provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/signature_collection_banner.dart';
import '../widgets/latest_models_showcase.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Keep allProducts static map list inside HomeScreen to avoid breaking other legacy references.
  static const List<Map<String, String>> allProducts = [];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productVM = Provider.of<ProductViewModel>(context, listen: false);
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final cartVM = Provider.of<CartViewModel>(context, listen: false);
      final customerId = authVM.currentUser?.id ?? '1';

      List<Future> futures = [];
      if (productVM.latestProducts.isEmpty) {
        futures.add(productVM.fetchLatestProducts(customerId: customerId));
      }
      if (productVM.recommendationProducts.isEmpty) {
        futures.add(
          productVM.fetchRecommendationProducts(customerId: customerId),
        );
      }
      if (productVM.categories.isEmpty) {
        futures.add(productVM.fetchCategories());
      }
      futures.add(cartVM.fetchCart(customerId));

      await Future.wait(futures);

      if (mounted && productVM.errorMessage != null) {
        ToastHelper.showErrorToast(context, productVM.errorMessage!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CartProvider, bool>(
      selector: (_, cp) => cp.isDarkMode,
      builder: (context, isDarkMode, _) {
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              color: goldAccent,
              onRefresh: () async {
                final productVM = Provider.of<ProductViewModel>(
                  context,
                  listen: false,
                );
                final authVM = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                final cartVM = Provider.of<CartViewModel>(
                  context,
                  listen: false,
                );
                final customerId = authVM.currentUser?.id ?? '1';

                await Future.wait([
                  productVM.fetchLatestProducts(customerId: customerId),
                  productVM.fetchRecommendationProducts(customerId: customerId),
                  productVM.fetchCategories(),
                  cartVM.fetchCart(customerId),
                ]);

                if (mounted && productVM.errorMessage != null) {
                  ToastHelper.showErrorToast(
                    context,
                    "Products API Error: ${productVM.errorMessage}",
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // ── APP BAR ──────────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Selector<AuthViewModel, User?>(
                          selector: (_, auth) => auth.currentUser,
                          builder: (context, user, _) {
                            final rawName = user?.name.trim() ?? '';
                            final displayName = rawName.isNotEmpty
                                ? rawName.split(' ').first
                                : 'User';
                            final greeting = 'Hey, $displayName';
                            final initial = rawName.isNotEmpty
                                ? rawName[0].toUpperCase()
                                : '';

                            return Row(
                              children: [
                                // User Profile Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE6D5FF),
                                        Color(0xFFCBB2FF),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF8A2BE2,
                                        ).withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: initial.isNotEmpty
                                        ? Text(
                                            initial,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF8A2BE2),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.diamond_outlined,
                                            color: Color(0xFF8A2BE2),
                                            size: 24,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: GoogleFonts.poppins(
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF2C1A00),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Welcome back ✨",
                                      style: GoogleFonts.poppins(
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        // Notification Bell Icon
                        Selector<NotificationViewModel, int>(
                          selector: (_, vm) => vm.unreadCount,
                          builder: (context, unreadCount, _) {
                            return GestureDetector(
                              onTap: () => _openNotifications(context),
                              child: _buildNotificationIconFromCount(
                                unreadCount,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── SEARCH BAR ROW ───────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final pVM = Provider.of<ProductViewModel>(
                                context,
                                listen: false,
                              );
                              final searchProducts = pVM.products
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
                              _openSearch(context, searchProducts);
                            },
                            child: Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Search 'Price'",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const PromoBannerCarousel(),
                    const SizedBox(height: 25),

                    // Categories Row
                    Selector<ProductViewModel, bool>(
                      selector: (_, vm) => vm.categories.isNotEmpty,
                      builder: (context, hasCategories, _) {
                        if (!hasCategories) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Category",
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF2C1A00),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Select by style or occasion",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Consumer<ProductViewModel>(
                              builder: (context, pVM, _) =>
                                  _buildCategoryList(context, pVM, const []),
                            ),
                            const SizedBox(height: 25),
                          ],
                        );
                      },
                    ),

                    const SignatureCollectionBanner(),
                    const SizedBox(height: 25),
                    const LatestModelsShowcase(),
                    const SizedBox(height: 25),

                    // Recommendation Section
                    Consumer<ProductViewModel>(
                      builder: (context, pVM, _) {
                        if (pVM.products.isNotEmpty ||
                            pVM.recommendationProducts.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Recommendation",
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF2C1A00),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Timeless pieces selected for you",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        RecommendationsScreen.path,
                                      );
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
                              _buildProductGrid(pVM),
                            ],
                          );
                        } else if (!pVM.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Text(
                                "No products available",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Open full-screen search ────────────────────────────────────────────────
  void _openSearch(
    BuildContext context,
    List<Map<String, String>> searchProducts, {
    String? initialQuery,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => SearchScreen(
          allProducts: searchProducts,
          initialQuery: initialQuery,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildRoundIcon(
    IconData icon,
    Color bgColor, {
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isPrimary ? Colors.white : Colors.black87,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationIconFromCount(int unread) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildRoundIcon(
            Icons.notifications_none,
            Colors.white,
            isPrimary: false,
          ),
          if (unread > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    ProductViewModel productVM,
    List<Map<String, String>> searchProducts,
  ) {
    if (productVM.isLoading && productVM.categories.isEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final categoriesList = productVM.categories;
    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesList.length,
        itemBuilder: (context, index) {
          final cat = categoriesList[index];
          return _categoryItem(
            context,
            cat.id,
            cat.name,
            cat.imageUrl,
            searchProducts,
            index,
          );
        },
      ),
    );
  }

  Widget _categoryItem(
    BuildContext context,
    String id,
    String title,
    String path,
    List<Map<String, String>> searchProducts,
    int index,
  ) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final textDark = cartProvider.isDarkMode ? Colors.white : Colors.black87;
    final isDark = cartProvider.isDarkMode;

    Widget imageWidget;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      imageWidget = Image.network(
        path,
        width: 32,
        height: 32,
        cacheWidth: 100,
        cacheHeight: 100,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/necklace2.png', width: 32, height: 32),
      );
    } else {
      imageWidget = Image.asset(
        path,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/necklace2.png', width: 32, height: 32),
      );
    }

    final bgColor = _getCategoryPastelColor(title, index, isDark);

    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            CategoryProductsScreen.path,
            arguments: {'categoryId': id, 'categoryName': title},
          );
        },
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(child: imageWidget),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryPastelColor(String category, int index, bool isDark) {
    if (isDark) {
      return const Color(0xFF262626);
    }
    final colors = [
      const Color(0xFFF0E8FF), // Light purple
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFE0F7FA), // Light teal
      const Color(0xFFFFFDE7), // Light gold
    ];
    return colors[index % colors.length];
  }


  Widget _buildProductGrid(ProductViewModel productVM) {
    if (productVM.isLoading && productVM.products.isEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const SkeletonProductCard();
        },
      );
    }

    String getBaseName(String title) {
      final index = title.indexOf('(');
      if (index != -1) {
        return title.substring(0, index).trim().toLowerCase();
      }
      return title.trim().toLowerCase();
    }

    final productsList = productVM.recommendationProducts.isNotEmpty
        ? productVM.recommendationProducts
        : productVM.products;

    // Group by base name and limit to at most 2 per base name
    final Map<String, List<Product>> groups = {};
    for (final product in productsList) {
      final baseName = getBaseName(product.title);
      final list = groups.putIfAbsent(baseName, () => []);
      if (list.length < 2) {
        list.add(product);
      }
    }

    // Interleave the groups
    final filteredList = <Product>[];
    bool addedAny = true;
    int groupIndex = 0;
    while (addedAny) {
      addedAny = false;
      for (final key in groups.keys) {
        final list = groups[key]!;
        if (groupIndex < list.length) {
          filteredList.add(list[groupIndex]);
          addedAny = true;
        }
      }
      groupIndex++;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: filteredList.length > 2 ? 2 : filteredList.length,
      itemBuilder: (context, index) {
        final product = filteredList[index];
        return ProductCard(
          id: product.id,
          title: product.title,
          subtitle: product.subtitle,
          price: product.price,
          imagePath: product.imagePath,
          inStock: product.inStock,
        );
      },
    );
  }
}
