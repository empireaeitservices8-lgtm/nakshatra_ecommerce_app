import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/product_viewmodel.dart';
import '../models/product.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../constants/app_colors.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/signature_collection_banner.dart';
import '../widgets/latest_models_showcase.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'category_products_screen.dart';
import 'recommendations_screen.dart';
import '../widgets/animated_cart_badge.dart';
import '../widgets/skeleton_product_card.dart';
import '../helpers/cart_animation_helper.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final ValueNotifier<String> _selectedLocation = ValueNotifier<String>(
    "Ernakulam 682303",
  );

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
        futures.add(productVM.fetchRecommendationProducts(customerId: customerId));
      }
      if (productVM.categories.isEmpty) {
        futures.add(productVM.fetchCategories());
      }
      futures.add(cartVM.fetchCart(customerId));

      await Future.wait(futures);

      if (mounted && productVM.errorMessage != null) {
        ToastHelper.showErrorToast(
          context,
          "Products API Error: ${productVM.errorMessage}",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productVM = Provider.of<ProductViewModel>(context);
    final notifVM = Provider.of<NotificationViewModel>(context);

    final List<Map<String, String>> searchProducts = [];

    return Scaffold(
      backgroundColor: cartProvider.isDarkMode
          ? const Color(0xFF121212)
          : Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: goldAccent,
          onRefresh: () async {
            final productVM = Provider.of<ProductViewModel>(
              context,
              listen: false,
            );
            final authVM = Provider.of<AuthViewModel>(context, listen: false);
            final cartVM = Provider.of<CartViewModel>(context, listen: false);
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
                    Row(
                      children: [
                        // Wizo Profile Avatar (inspired by demo screenshot)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFE6D5FF), Color(0xFFCBB2FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.diamond_outlined,
                            color: Color(0xFF8A2BE2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Wizo",
                              style: GoogleFonts.poppins(
                                color: cartProvider.isDarkMode ? Colors.white : const Color(0xFF2C1A00),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ValueListenableBuilder<String>(
                              valueListenable: HomeScreen._selectedLocation,
                              builder: (context, location, _) {
                                return GestureDetector(
                                  onTap: () => _showLocationPicker(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: goldDark,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        location,
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey.shade600,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification Bell Icon
                    GestureDetector(
                      onTap: () => _openNotifications(context),
                      child: _buildNotificationIcon(notifVM),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Live Gold Ticker (Hallmarked jewelry store realism)
                _buildLiveGoldRateTicker(cartProvider.isDarkMode),
                const SizedBox(height: 15),

                // ── SEARCH BAR ROW ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openSearch(context, searchProducts),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                if (productVM.categories.isNotEmpty) ...[
                  Text(
                    "Category",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: cartProvider.isDarkMode
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
                  _buildCategoryList(context, productVM, searchProducts),
                  const SizedBox(height: 25),
                ],
                const SignatureCollectionBanner(),
                const SizedBox(height: 25),
                const LatestModelsShowcase(),
                const SizedBox(height: 25),
                if (productVM.products.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendation",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: cartProvider.isDarkMode
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
                          Navigator.pushNamed(context, RecommendationsScreen.path);
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
                  _buildProductGrid(productVM),
                ] else if (!productVM.isLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        "No products available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
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
        pageBuilder: (_, __, ___) => SearchScreen(
          allProducts: searchProducts,
          initialQuery: initialQuery,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
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
              Text(
                "Choose Delivery Location",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1A00),
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<String>(
                valueListenable: HomeScreen._selectedLocation,
                builder: (context, currentLoc, _) {
                  return Column(
                    children:
                        [
                          "Ernakulam 682303",
                          "Kochi 682011",
                          "Trivandrum 695001",
                          "Calicut 673001",
                          "Bangalore 560001",
                        ].map((loc) {
                          final isSelected = currentLoc == loc;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: isSelected
                                  ? const Color(0xFF8A2BE2)
                                  : Colors.grey,
                            ),
                            title: Text(
                              loc,
                              style: GoogleFonts.poppins(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF2C1A00)
                                    : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF2E513D),
                                  )
                                : null,
                            onTap: () {
                              HomeScreen._selectedLocation.value = loc;
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
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

  Widget _buildCartIconWithBadge(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartVM, child) => SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              key: CartAnimationHelper.homeCartKey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              child: _buildRoundIcon(
                Icons.shopping_bag_outlined,
                Colors.white,
                isPrimary: false,
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedCartBadge(count: cartVM.items.length),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationViewModel notifVM) {
    final unread = notifVM.unreadCount;
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
          return _categoryItem(context, cat.id, cat.name, cat.imageUrl, searchProducts, index);
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
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/necklace2.png', width: 32, height: 32),
      );
    } else {
      imageWidget = Image.asset(
        path,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
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
            arguments: {
              'categoryId': id,
              'categoryName': title,
            },
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

  Widget _buildWishlistIconWithBadge(BuildContext context, int count) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              cartProvider.setTabIndex(1); // Navigates to Wishlist Tab
            },
            child: _buildRoundIcon(
              Icons.favorite_border_rounded,
              Colors.white,
              isPrimary: false,
            ),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF8A2BE2), // Purple badge color
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
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

  Widget _buildLiveGoldRateTicker(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Live Gold Rate",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF2C1A00),
                ),
              ),
            ],
          ),
          Text(
            "22K: ₹6,890/g  |  24K: ₹7,516/g",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB8860B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductViewModel productVM) {
    if (productVM.isLoading && productVM.products.isEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.59,
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
        childAspectRatio: 0.59,
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
