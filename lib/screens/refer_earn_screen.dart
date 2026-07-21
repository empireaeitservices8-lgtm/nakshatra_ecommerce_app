import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class ReferEarnScreen extends StatelessWidget {
  static const String path = '/refer-earn';
  const ReferEarnScreen({super.key});

  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);
  static const Color _emeraldGreen = Color(0xFF2E513D);

  final String _referralCode = "NAKSH-SHINE-77";

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

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
      body: SingleChildScrollView(
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
                        _referralCode,
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
                          Clipboard.setData(ClipboardData(text: _referralCode));
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
                Expanded(child: _statBox(context, "3", "Friends Invited")),
                const SizedBox(width: 16),
                Expanded(child: _statBox(context, "₹1,000", "Gold Earned")),
              ],
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sharing referral link..."),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
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

  Widget _statBox(BuildContext context, String value, String label) {
    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    final cardWhite = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
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
