import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../constants/app_colors.dart';
import 'cart_screen.dart';

class SearchScreen extends StatefulWidget {
  static const String path = '/search';
  final List<Map<String, String>> allProducts;
  final String? initialQuery;
  const SearchScreen({super.key, required this.allProducts, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
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
      ? Colors.white60
      : const Color(0xFF8B6914);

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> _results = [];
  bool _hasSearched = false;

  final List<String> _recentSearches = [
    'Gold Necklace',
    'Diamond Ring',
    'Wedding Set',
    'Bangles',
  ];

  final List<String> _trendingTags = [
    'Earrings',
    'Bracelets',
    'Rings',
    'Necklaces',
    'Wedding Sets',
    'Diamond',
  ];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    if (widget.initialQuery != null) {
      _searchCtrl.text = widget.initialQuery!;
      _onSearch(widget.initialQuery!);
    } else {
      // Auto-focus keyboard only if no initial query is provided
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() {
      _hasSearched = true;
      _results = widget.allProducts.where((p) {
        final title = p['title']?.toLowerCase() ?? '';
        final subtitle = p['subtitle']?.toLowerCase() ?? '';
        final category = p['category']?.toLowerCase() ?? '';
        final gender = p['gender']?.toLowerCase() ?? '';

        final words = q.split(' ');
        return words.every(
          (word) =>
              title.contains(word) ||
              subtitle.contains(word) ||
              category.contains(word) ||
              gender.contains(word),
        );
      }).toList();
    });
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
                          color: _bgCream,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                          ),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          focusNode: _focusNode,
                          onChanged: _onSearch,
                          onSubmitted: _onSearch,
                          style: TextStyle(color: _textDark, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search jewellery...',
                            hintStyle: TextStyle(
                              color: _textMuted,
                              fontSize: 14,
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
                                      _onSearch('');
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _recentSearches.clear()),
                  child: Text(
                    'Clear all',
                    style: TextStyle(fontSize: 12, color: goldDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recentSearches.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.history_rounded,
                  color: _textMuted,
                  size: 20,
                ),
                title: Text(
                  s,
                  style: TextStyle(fontSize: 14, color: _textDark),
                ),
                trailing: Icon(
                  Icons.north_west_rounded,
                  size: 16,
                  color: _textMuted,
                ),
                onTap: () {
                  _searchCtrl.text = s;
                  _onSearch(s);
                },
              ),
            ),
            const Divider(height: 28),
          ],

          // Trending tags
          Text(
            'Trending',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
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
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: goldDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              color: goldDark,
                              fontWeight: FontWeight.w500,
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
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: goldAccent.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different keyword',
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${_results.length} result${_results.length == 1 ? '' : 's'} found',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.59,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final p = _results[i];
              return ProductCard(
                id: p['id']!,
                title: p['title']!,
                subtitle: p['subtitle']!,
                price: p['price']!,
                imagePath: p['imagePath']!,
              );
            },
          ),
        ),
      ],
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
                Icons.shopping_cart_outlined,
                color: Provider.of<CartProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black87,
                size: 22,
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
