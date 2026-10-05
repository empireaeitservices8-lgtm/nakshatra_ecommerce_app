// ignore_for_file: duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nakshatra_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../providers/cart_provider.dart';
import 'help_center_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String path = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Gold palette ──────────────────────────────────────────────────────────
  Color get _goldDark => const Color(0xFFB8860B);
  Color get _goldMid => const Color(0xFFD4A017);
  Color get _goldLight => const Color(0xFFFFD700);
  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);
  Color get _textMuted => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white54
      : const Color(0x992C1A00);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _dangerRed => const Color(0xFFD32F2F);

  // ── Toggle states ─────────────────────────────────────────────────────────
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _offerAlerts = false;
  bool _emailNewsletter = true;
  bool _biometricLogin = true;
  bool _savePaymentInfo = false;

  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Malayalam',
    'Telugu',
    'Kannada',
  ];
  final List<String> _currencies = [
    'INR (₹)',
    'USD (\$)',
    'AED (د.إ)',
    'SGD (S\$)',
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
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Notifications'),
                      _buildNotificationsCard(),
                      const SizedBox(height: 20),
                      _sectionLabel('Privacy & Security'),
                      _buildSecurityCard(),
                      const SizedBox(height: 20),
                      _sectionLabel('Appearance & Language'),
                      _buildAppearanceCard(),
                      const SizedBox(height: 20),
                      _sectionLabel('Support'),
                      _buildSupportCard(context),
                      const SizedBox(height: 20),
                      _sectionLabel('Account'),
                      _buildAccountCard(context),
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

  // ── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF14241B),
      elevation: 0,
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
      title: const Text(
        'Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        Center(child: _buildCartIconWithBadge(context)),
        const SizedBox(width: 16),
      ],
      flexibleSpace: Container(
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
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _goldDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: _goldDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ─────────────────────────────────────────────────────────
  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _goldMid.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }

  // ── Gold Switch ───────────────────────────────────────────────────────────
  Widget _switchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldLight.withOpacity(0.25),
                  _goldMid.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _goldDark, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(color: _textMuted, fontSize: 12),
                )
              : null,
          value: value,
          onChanged: onChanged,
          activeColor: _goldDark,
          activeTrackColor: _goldLight.withOpacity(0.5),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade200,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 20,
            color: _goldLight.withOpacity(0.2),
          ),
      ],
    );
  }

  // ── Dropdown tile ─────────────────────────────────────────────────────────
  Widget _dropdownTile({
    required String title,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _goldLight.withOpacity(0.25),
                      _goldMid.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _goldDark, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  onChanged: onChanged,
                  items: items
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(color: _textDark, fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _goldDark,
                  ),
                  style: TextStyle(color: _textDark, fontSize: 13),
                  dropdownColor: _cardWhite,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 20,
            color: _goldLight.withOpacity(0.2),
          ),
      ],
    );
  }

  // ── Arrow tile ────────────────────────────────────────────────────────────
  Widget _arrowTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 2,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? _goldLight).withOpacity(0.2),
                  (iconColor ?? _goldMid).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? _goldDark, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(color: _textMuted, fontSize: 12),
                )
              : null,
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _bgCream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: iconColor ?? _goldDark,
            ),
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 20,
            color: _goldLight.withOpacity(0.2),
          ),
      ],
    );
  }

  // ── Notification card ─────────────────────────────────────────────────────
  Widget _buildNotificationsCard() {
    return _card([
      _switchTile(
        title: 'Push Notifications',
        subtitle: 'Alerts on new arrivals & deals',
        icon: Icons.notifications_outlined,
        value: _pushNotifications,
        onChanged: (v) => setState(() => _pushNotifications = v),
      ),
      _switchTile(
        title: 'Order Updates',
        subtitle: 'Shipping & delivery status',
        icon: Icons.local_shipping_outlined,
        value: _orderUpdates,
        onChanged: (v) => setState(() => _orderUpdates = v),
      ),
      _switchTile(
        title: 'Offer Alerts',
        subtitle: 'Festive discounts & flash sales',
        icon: Icons.local_offer_outlined,
        value: _offerAlerts,
        onChanged: (v) => setState(() => _offerAlerts = v),
      ),
      _switchTile(
        title: 'Email Newsletter',
        subtitle: 'Monthly trends & new collections',
        icon: Icons.mail_outline_rounded,
        value: _emailNewsletter,
        onChanged: (v) => setState(() => _emailNewsletter = v),
        isLast: true,
      ),
    ]);
  }

  // ── Security card ─────────────────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return _card([
      _switchTile(
        title: 'Biometric Login',
        subtitle: 'Fingerprint or Face ID',
        icon: Icons.fingerprint_rounded,
        value: _biometricLogin,
        onChanged: (v) => setState(() => _biometricLogin = v),
      ),
      _switchTile(
        title: 'Save Payment Info',
        subtitle: 'Encrypted & securely stored',
        icon: Icons.credit_card_outlined,
        value: _savePaymentInfo,
        onChanged: (v) => setState(() => _savePaymentInfo = v),
      ),
      _arrowTile(
        title: 'Change Password',
        subtitle: 'Update your account password',
        icon: Icons.lock_outline_rounded,
        onTap: () => _showChangePasswordSheet(context),
      ),
      _arrowTile(
        title: 'Privacy Policy',
        subtitle: 'How we handle your data',
        icon: Icons.policy_outlined,
        onTap: () => _launchUrl('https://www.nakshathra.store/privacy-policy'),
        isLast: true,
      ),
    ]);
  }

  // ── Appearance card ───────────────────────────────────────────────────────
  Widget _buildAppearanceCard() {
    final cart = Provider.of<CartProvider>(context);
    return _card([
      _switchTile(
        title: 'Dark Mode',
        subtitle: 'Switch to dark theme',
        icon: Icons.dark_mode_outlined,
        value: cart.isDarkMode,
        onChanged: (v) => cart.setDarkMode(v),
      ),
      _dropdownTile(
        title: 'Language',
        icon: Icons.translate_rounded,
        value: _selectedLanguage,
        items: _languages,
        onChanged: (v) => setState(() => _selectedLanguage = v!),
      ),
      _dropdownTile(
        title: 'Currency',
        icon: Icons.currency_rupee_rounded,
        value: _selectedCurrency,
        items: _currencies,
        onChanged: (v) => setState(() => _selectedCurrency = v!),
        isLast: true,
      ),
    ]);
  }

  // ── Support card ──────────────────────────────────────────────────────────
  Widget _buildSupportCard(BuildContext context) {
    return _card([
      _arrowTile(
        title: 'Help Center',
        subtitle: 'FAQs & guides',
        icon: Icons.help_outline_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
          );
        },
      ),
      _arrowTile(
        title: 'Chat with Us',
        subtitle: 'Available 9AM – 9PM',
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () {},
      ),
      _arrowTile(
        title: 'Rate the App',
        subtitle: 'Enjoying Nakshathra? Leave a review',
        icon: Icons.star_border_rounded,
        onTap: () {},
      ),
      _arrowTile(
        title: 'About',
        subtitle: 'Version 2.1.0',
        icon: Icons.info_outline_rounded,
        onTap: () {},
        isLast: true,
      ),
    ]);
  }

  // ── Account card ──────────────────────────────────────────────────────────
  Widget _buildAccountCard(BuildContext context) {
    return _card([
      _arrowTile(
        title: 'Delete Account',
        subtitle: 'Permanently remove your account',
        icon: Icons.delete_outline_rounded,
        titleColor: _dangerRed,
        iconColor: _dangerRed,
        onTap: () => _showDeleteConfirmation(context),
      ),
      _arrowTile(
        title: 'Logout',
        icon: Icons.logout_rounded,
        titleColor: _dangerRed,
        iconColor: _dangerRed,
        onTap: () => _showLogoutConfirmation(context),
        isLast: true,
      ),
    ]);
  }

  // ── Change Password bottom sheet ──────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 24),
                _passwordField(
                  ctx,
                  controller: currentCtrl,
                  label: 'Current Password',
                  obscure: obscureCurrent,
                  onToggle: () =>
                      setModalState(() => obscureCurrent = !obscureCurrent),
                ),
                const SizedBox(height: 14),
                _passwordField(
                  ctx,
                  controller: newCtrl,
                  label: 'New Password',
                  obscure: obscureNew,
                  onToggle: () => setModalState(() => obscureNew = !obscureNew),
                ),
                const SizedBox(height: 14),
                _passwordField(
                  ctx,
                  controller: confirmCtrl,
                  label: 'Confirm New Password',
                  obscure: obscureConfirm,
                  onToggle: () =>
                      setModalState(() => obscureConfirm = !obscureConfirm),
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
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Update Password',
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
      ),
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textMuted, fontSize: 13),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: _goldDark,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _textMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
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

  // ── Logout confirmation ───────────────────────────────────────────────────
  void _showLogoutConfirmation(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Logout?',
      message: 'You will be signed out of your Nakshathra account.',
      confirmText: 'Logout',
      confirmColor: _dangerRed,
      onConfirm: () {
        Provider.of<AuthViewModel>(context, listen: false).logout();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }

  // ── Delete account confirmation ───────────────────────────────────────────
  void _showDeleteConfirmation(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Delete Account?',
      message:
          'This will permanently delete your account and all your data. This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: _dangerRed,
      onConfirm: () async {
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final nav = Navigator.of(context);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final success = await authVM.deleteAccount();

        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
        }

        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Account deleted/deactivated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          nav.pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                authVM.errorMessage?.isNotEmpty == true
                    ? authVM.errorMessage!
                    : 'Failed to delete account',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: _textMuted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _goldDark, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
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
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
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

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link. Copied to clipboard: $url'),
            backgroundColor: _goldDark,
          ),
        );
      }
    }
  }
}
