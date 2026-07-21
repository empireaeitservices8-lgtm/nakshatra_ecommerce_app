import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_methods_screen.dart';
import 'refer_earn_screen.dart';
import 'saved_addresses_screen.dart';
import 'wishlist_screen.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import 'my_orders_screen.dart';
import 'my_reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String path = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Gold palette ──────────────────────────────────────────────────────────
  Color get _goldDark => const Color(0xFFB8860B);
  Color get _goldMid => const Color(0xFFD4A017);
  Color get _goldLight => const Color(0xFFFFD700);
  Color get _goldShine => const Color(0xFFFFF0A0);
  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);
  Color get _textMuted => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white60
      : const Color(0xFF8B6914);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);

  final List<Map<String, dynamic>> _statsData = [
    {'label': 'Orders', 'value': '14', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Wishlist', 'value': '8', 'icon': Icons.favorite_border},
    {'label': 'Reviews', 'value': '5', 'icon': Icons.star_border_rounded},
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'My Orders',
      'subtitle': 'Track, return or buy again',
      'icon': Icons.receipt_long_outlined,
    },
    {
      'title': 'Saved Addresses',
      'subtitle': 'Manage delivery addresses',
      'icon': Icons.location_on_outlined,
    },
    {
      'title': 'Payment Methods',
      'subtitle': 'Cards, UPI, net banking',
      'icon': Icons.credit_card_outlined,
    },
    {
      'title': 'Wishlist',
      'subtitle': '8 pieces saved for later',
      'icon': Icons.favorite_border,
    },
    {
      'title': 'My Reviews',
      'subtitle': 'Rate your purchases',
      'icon': Icons.rate_review_outlined,
    },
    {
      'title': 'Refer & Earn',
      'subtitle': 'Get ₹500 per referral',
      'icon': Icons.card_giftcard_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildMenuSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sliver AppBar with forest green gradient ──────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF14241B),
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => _showEditProfileSheet(context),
          tooltip: 'Edit Profile',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF14241B), // Luxury deep emerald
                Color(0xFF2E513D), // Emerald green
                Color(0xFF1A3828), // Deep emerald
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative shimmer circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              // Profile content
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sarah Williams',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'sarah.w@jewels.com',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 12.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Member badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.35),
                              const Color(0xFFB8860B).withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              color: _goldShine,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Gold Member',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldMid.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _goldMid.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_statsData.length, (i) {
            final item = _statsData[i];
            return Expanded(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: i < _statsData.length - 1
                        ? Border(
                            right: BorderSide(
                              color: _goldLight.withOpacity(0.15),
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: _goldDark,
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['value'] as String,
                        style: GoogleFonts.playfairDisplay(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.poppins(
                          color: _textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Menu section ──────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _menuHeader("MY ACCOUNT"),
        const SizedBox(height: 8),
        _buildMenuCard([0, 1, 2, 3]),
        const SizedBox(height: 24),
        _menuHeader("REWARDS & COMMUNITY"),
        const SizedBox(height: 8),
        _buildMenuCard([4, 5]),
        const SizedBox(height: 30),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _menuHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _goldDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<int> indices) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _goldMid.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(indices.length, (i) {
            final index = indices[i];
            final item = _menuItems[index];
            final isLast = i == indices.length - 1;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _goldLight.withOpacity(0.15),
                          _goldMid.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: _goldDark,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      color: _textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                  trailing: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _bgCream,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: _goldDark,
                    ),
                  ),
                  onTap: () {
                    if (item['title'] == 'My Orders') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                    } else if (item['title'] == 'Saved Addresses') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressesScreen(),
                        ),
                      );
                    } else if (item['title'] == 'Payment Methods') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodsScreen(),
                        ),
                      );
                    } else if (item['title'] == 'Wishlist') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
                    } else if (item['title'] == 'My Reviews') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyReviewsScreen(),
                        ),
                      );
                    } else if (item['title'] == 'Refer & Earn') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReferEarnScreen(),
                        ),
                      );
                    }
                  },
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 20,
                    color: _goldLight.withOpacity(0.15),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Logout",
                style: GoogleFonts.playfairDisplay(
                  color: _textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Are you sure you want to sign out of your luxury account?",
                style: GoogleFonts.poppins(color: _textMuted, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: _goldDark)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out successfully")),
                    );
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(
          Icons.logout_rounded,
          size: 18,
          color: Colors.redAccent,
        ),
        label: Text(
          "Sign Out",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.redAccent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.2),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // ── Edit Profile Bottom Sheet ─────────────────────────────────────────────
  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Sarah Williams');
    final phoneCtrl = TextEditingController(text: '+91 98765 43210');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _cardWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 24),
              _goldTextField(
                controller: nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _goldTextField(
                controller: phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goldTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: _goldDark, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _goldLight.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _goldDark, width: 1.5),
        ),
        filled: true,
        fillColor: _bgCream,
      ),
    );
  }
}
