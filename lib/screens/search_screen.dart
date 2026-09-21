// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nakshatra_app/constants/app_colors.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'package:nakshatra_app/helpers/cart_animation_helper.dart';
import 'package:nakshatra_app/screens/cart_screen.dart';
import 'package:nakshatra_app/widgets/animated_cart_badge.dart';
import 'package:nakshatra_app/widgets/skeleton_product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  static const String path = '/search';
  final List<Map<String, String>> allProducts;
  final String? initialQuery;
  final String? categoryId;

  const SearchScreen({
    super.key,
    required this.allProducts,
    this.initialQuery,
    this.categoryId,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  static const String _recentSearchesKey = 'nakshatra_recent_searches';

  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);
  Color get _textMuted => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white54
      : const Color(0x992C1A00);

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasSearched = false;
  List<Product> _categorySearchResults = [];

  List<String> _recentSearches = [];

  final List<String> _trendingTags = [
    '18CT',
    'Necklace',
    'Bracelet',
    'Bangle',
    'Ring',
    'Stud',
    'Pendant',
    'Diamond',
  ];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _loadRecentSearches();

    if (widget.categoryId != null) {
      if (widget.initialQuery != null) {
        _searchCtrl.text = widget.initialQuery!;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchCategoryProducts(widget.categoryId!);
        }
      });
    } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onSearch(widget.initialQuery!);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_recentSearchesKey);
      if (list != null && list.isNotEmpty) {
        if (mounted) {
          setState(() {
            _recentSearches = list;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _recentSearches = [
              '18ct',
              'Gold Necklace',
              'Diamond Ring',
              'Bangles',
            ];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final updated = List<String>.from(_recentSearches);
      updated.removeWhere(
        (item) => item.toLowerCase() == trimmed.toLowerCase(),
      );
      updated.insert(0, trimmed);
      if (updated.length > 10) {
        updated.removeLast();
      }
      await prefs.setStringList(_recentSearchesKey, updated);
      if (mounted) {
        setState(() {
          _recentSearches = updated;
        });
      }
    } catch (_) {}
  }

  Future<void> _removeRecentSearch(String term) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updated = List<String>.from(_recentSearches);
      updated.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
      await prefs.setStringList(_recentSearchesKey, updated);
      if (mounted) {
        setState(() {
          _recentSearches = updated;
        });
      }
    } catch (_) {}
  }

  Future<void> _clearAllRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
      if (mounted) {
        setState(() {
          _recentSearches.clear();
        });
      }
    } catch (_) {}
  }

  void _fetchCategoryProducts(String categoryId) async {
    final catIdInt = int.tryParse(categoryId);
    if (catIdInt == null) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final customerId = authVM.currentUser?.id ?? '1';

    final productVM = Provider.of<ProductViewModel>(context, listen: false);
    await productVM.fetchCategoryProducts(
      categoryId: catIdInt,
      customerId: customerId,
    );

    if (mounted) {
      setState(() {
        _hasSearched = true;
        _categorySearchResults = productVM.categoryProducts;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final q = query.trim();
    if (q.isEmpty) {
      final productVM = Provider.of<ProductViewModel>(context, listen: false);
      productVM.clearSearchResults();
      setState(() {
        _hasSearched = false;
        _categorySearchResults = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _onSearch(q);
    });
  }

  void _onSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      final productVM = Provider.of<ProductViewModel>(context, listen: false);
      productVM.clearSearchResults();
      setState(() {
        _hasSearched = false;
        _categorySearchResults = [];
      });
      return;
    }

    _saveRecentSearch(q);

    setState(() {
      _hasSearched = true;
      _categorySearchResults = [];
    });

    final productVM = Provider.of<ProductViewModel>(context, listen: false);
    await productVM.searchProducts(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Provider.of<CartProvider>(context).isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search field
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _cardWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          focusNode: _focusNode,
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearch,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: _textDark, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search jewellery (e.g. 18ct, Ring)...',
                            hintStyle: TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: goldDark,
                              size: 20,
                            ),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      final productVM =
                                          Provider.of<ProductViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      productVM.clearSearchResults();
                                      setState(() {
                                        _hasSearched = false;
                                        _categorySearchResults = [];
                                      });
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: _textMuted,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildCartIconWithBadge(context),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: _hasSearched
                    ? _buildSearchResults()
                    : _buildDiscoveryView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Discovery (pre-search) view ───────────────────────────────────────────
  Widget _buildDiscoveryView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: goldDark),
                    const SizedBox(width: 6),
                    Text(
                      'Recent Searches',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _clearAllRecentSearches,
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: goldDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._recentSearches.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: goldDark.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_rounded, color: goldDark, size: 16),
                ),
                title: Text(
                  s,
                  style: GoogleFonts.poppins(fontSize: 14, color: _textDark),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close_rounded, size: 16, color: _textMuted),
                  onPressed: () => _removeRecentSearch(s),
                ),
                onTap: () {
                  _searchCtrl.text = s;
                  _searchCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: s.length),
                  );
                  _onSearch(s);
                },
              ),
            ),
            const Divider(height: 28),
          ],

          // Trending tags
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: goldDark,
              ),
              const SizedBox(width: 6),
              Text(
                'Trending Keywords',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _trendingTags
                .map(
                  (tag) => GestureDetector(
                    onTap: () {
                      _searchCtrl.text = tag;
                      _searchCtrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: tag.length),
                      );
                      _onSearch(tag);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: goldAccent.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: goldDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tag,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: goldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── Search results view ───────────────────────────────────────────────────
  Widget _buildSearchResults() {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, _) {
        if (productVM.isSearching ||
            (productVM.isLoadingCategoryProducts &&
                _categorySearchResults.isEmpty)) {
          return _buildLoadingGrid();
        }

        final products = _categorySearchResults.isNotEmpty
            ? _categorySearchResults
            : productVM.searchResults;

        if (products.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: goldDark.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: goldDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _searchCtrl.text.isNotEmpty
                        ? 'We couldn\'t find any jewellery matching "${_searchCtrl.text}".'
                        : 'Try searching with different keywords like 18ct, Ring, or Necklace.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _searchCtrl.clear();
                      productVM.clearSearchResults();
                      setState(() {
                        _hasSearched = false;
                        _categorySearchResults = [];
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${products.length} item${products.length == 1 ? '' : 's'} found',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    Text(
                      '"${_searchCtrl.text}"',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: goldDark,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
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
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const SkeletonProductCard(),
    );
  }

  Widget _buildCartIconWithBadge(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartVM, child) => Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            key: CartAnimationHelper.searchCartKey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardWhite,
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
                Icons.shopping_bag_outlined,
                color: Provider.of<CartProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black87,
                size: 22,
              ),
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: AnimatedCartBadge(count: cartVM.items.length),
          ),
        ],
      ),
    );
  }
}
