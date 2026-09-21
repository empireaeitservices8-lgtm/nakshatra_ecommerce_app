import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/referral_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class ReferEarnScreen extends StatefulWidget {
  static const String path = '/refer-earn';
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);
  static const Color _emeraldGreen = Color(0xFF2E513D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ?? '1';
      Provider.of<ReferralViewModel>(context, listen: false).fetchReferralInfo(customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    final authVM = Provider.of<AuthViewModel>(context);
    final referralVM = Provider.of<ReferralViewModel>(context);
    final refInfo = referralVM.referralInfo;
    final refCode = (refInfo?.referralCode.isNotEmpty == true)
        ? refInfo!.referralCode
        : (authVM.currentUser?.referralCode.isNotEmpty == true
            ? authVM.currentUser!.referralCode
            : 'NAKSH-SHINE-74');
    final friendsInvited = (refInfo?.friendsInvited ?? refInfo?.referredCount ?? 0).toString();
    final goldEarnedVal = refInfo?.goldEarned ?? refInfo?.rewardsEarnedInr ?? 0.0;
    final rewardsEarned = '₹${goldEarnedVal.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: Text(
          "Refer & Earn",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textDark,
          ),
        ),
        backgroundColor: cardWhite,
        foregroundColor: textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _goldMid.withAlpha(30), height: 1),
        ),
      ),
      body: referralVM.isLoading && refInfo == null
          ? const Center(child: CircularProgressIndicator(color: _goldMid))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  // Gift illustration
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _goldMid.withAlpha(35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: _emeraldGreen,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Share the Shine",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Get Rewarded in Pure Gold",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _goldDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Invite your friends to Nakshathra. They get ₹250 off their first purchase of handcrafted jewelry, and you get a ₹500 gold coupon credited once their order ships!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Code Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _goldMid.withAlpha(30), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "YOUR REFERRAL CODE",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              refCode,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: refCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Referral code copied to Clipboard!",
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: bgCream,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _goldMid.withAlpha(30)),
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  color: _goldDark,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Referral Stats
                  Row(
                    children: [
                      Expanded(child: _statBox(context, friendsInvited, "Friends Invited")),
                      const SizedBox(width: 16),
                      Expanded(child: _statBox(context, rewardsEarned, "Gold Earned")),
                    ],
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () => _showInviteDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emeraldGreen,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Invite Friends Now",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
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
                  "Invite a Friend",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Send an exclusive referral invitation to earn gold rewards",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(color: textDark, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Friend's Email",
                    prefixIcon: const Icon(Icons.email_outlined, color: _goldDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _goldDark, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(color: textDark, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: "Friend's Phone",
                    prefixIcon: const Icon(Icons.phone_outlined, color: _goldDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _goldDark, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [_emeraldGreen, Color(0xFF1B382A)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();

                      if (email.isEmpty && phone.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter at least an email or phone number"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final customerId = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      ).currentUser?.id ?? '1';

                      final referralVM = Provider.of<ReferralViewModel>(
                        context,
                        listen: false,
                      );

                      final success = await referralVM.inviteFriend(
                        customerId: customerId,
                        friendEmail: email.isNotEmpty ? email : "friend@example.com",
                        friendPhone: phone.isNotEmpty ? phone : "+919876543210",
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Referral invitation recorded successfully!"),
                              backgroundColor: _emeraldGreen,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                referralVM.errorMessage ?? "Failed to send referral invitation",
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Send Invitation",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statBox(BuildContext context, String value, String label) {
    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldMid.withAlpha(20)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
