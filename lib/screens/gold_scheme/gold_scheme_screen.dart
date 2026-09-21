// ignore_for_file: duplicate_ignore, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../helpers/toast_helper.dart';
import 'gold_scheme_viewmodel.dart';
import 'gold_scheme_model.dart';

class GoldSchemeScreen extends StatefulWidget {
  static const String path = '/gold_scheme';
  const GoldSchemeScreen({super.key});

  @override
  State<GoldSchemeScreen> createState() => _GoldSchemeScreenState();
}

class _GoldSchemeScreenState extends State<GoldSchemeScreen> {
  final Color _goldDark = const Color(0xFFB8860B);
  final Color _goldMid = const Color(0xFFD4A017);
  final Color _goldAccent = const Color(0xFFFFD700);
  final Color _emeraldGreen = const Color(0xFF2E513D);

  int _selectedInstallmentOption = 2000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
          '1';
      Provider.of<GoldSchemeViewModel>(
        context,
        listen: false,
      ).fetchSchemeDetails(customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schemeVM = Provider.of<GoldSchemeViewModel>(context);
    final customerId =
        Provider.of<AuthViewModel>(context).currentUser?.id ?? '1';
    final isDark = Provider.of<CartProvider>(context).isDarkMode;

    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Nakshathra Gold Scheme",
          style: GoogleFonts.playfairDisplay(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: schemeVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4A017)),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await schemeVM.fetchSchemeDetails(customerId);
              },
              color: _goldMid,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: schemeVM.activeScheme != null
                    ? _buildActiveSchemeView(
                        schemeVM.activeScheme!,
                        customerId,
                        cardWhite,
                        textDark,
                        textMuted,
                        isDark,
                      )
                    : _buildNoSchemeView(
                        schemeVM,
                        customerId,
                        cardWhite,
                        textDark,
                        textMuted,
                        isDark,
                      ),
              ),
            ),
    );
  }

  Widget _buildActiveSchemeView(
    GoldScheme scheme,
    String customerId,
    Color cardColor,
    Color textColor,
    Color textMutedColor,
    bool isDark,
  ) {
    final double completionRatio = scheme.monthsPaid / scheme.totalMonths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_goldDark, _goldMid, _goldAccent.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _goldMid.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    scheme.name,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      scheme.status,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                "Total Amount Saved",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                "₹${scheme.totalSaved.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Installment",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "₹${scheme.monthlyInstallment.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Maturity Date",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        scheme.maturityDate.isNotEmpty
                            ? scheme.maturityDate
                            : "N/A",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Text(
          "Installment Progress",
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _goldMid.withOpacity(0.15), width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Paid: ${scheme.monthsPaid} / ${scheme.totalMonths} months",
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${(completionRatio * 100).toInt()}% Complete",
                    style: GoogleFonts.poppins(
                      color: _goldDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: completionRatio,
                  backgroundColor: _goldMid.withOpacity(0.1),
                  color: _goldMid,
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        if (scheme.monthsPaid < scheme.totalMonths)
          ElevatedButton(
            onPressed: () => _handlePayment(
              context,
              customerId,
              scheme.schemeId,
              scheme.monthlyInstallment,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: Text(
              "Pay Next Installment (₹${scheme.monthlyInstallment})",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        const SizedBox(height: 30),

        Text(
          "Payment History",
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (scheme.paymentHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "No payments recorded yet.",
                style: GoogleFonts.poppins(color: textMutedColor, fontSize: 14),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: scheme.paymentHistory.length,
            // ignore: unnecessary_underscores
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pay = scheme.paymentHistory[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _goldMid.withOpacity(0.1),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pay.transactionId.isNotEmpty
                              ? "TXN: ${pay.transactionId}"
                              : "Monthly Installment",
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pay.date,
                          style: GoogleFonts.poppins(
                            color: textMutedColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "+₹${pay.amount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            color: _emeraldGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pay.status,
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNoSchemeView(
    GoldSchemeViewModel viewModel,
    String customerId,
    Color cardColor,
    Color textColor,
    Color textMutedColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2C1A00), _goldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Accumulate Gold Digitally",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Save monthly installments and redeem ornaments with Zero Making Charges & zero wastage fees at maturity!",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Text(
          "Select Monthly Installment Plan",
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [1000, 2000, 5000].map((amt) {
            final isSelected = _selectedInstallmentOption == amt;
            return GestureDetector(
              onTap: () => setState(() => _selectedInstallmentOption = amt),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? _goldMid : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _goldMid : _goldMid.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    "₹$amt",
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _goldMid.withOpacity(0.15), width: 1),
          ),
          child: Column(
            children: [
              _buildBenefitRow(
                Icons.check_circle_outline,
                "11 Months installment plan",
              ),
              const SizedBox(height: 12),
              _buildBenefitRow(
                Icons.percent_outlined,
                "Maturity bonus of up to 1 installment",
              ),
              const SizedBox(height: 12),
              _buildBenefitRow(
                Icons.verified_outlined,
                "GIA Certified Hallmarked gold ornaments redemption",
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () => _handlePayment(
            context,
            customerId,
            1,
            _selectedInstallmentOption.toDouble(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _goldMid,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: Text(
            "Subscribe & Pay First Installment",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _goldMid, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _handlePayment(
    BuildContext context,
    String customerId,
    int schemeId,
    double amount,
  ) async {
    final schemeVM = Provider.of<GoldSchemeViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4A017)),
      ),
    );

    final success = await schemeVM.joinOrPayScheme(
      customerId: customerId,
      schemeId: schemeId,
      amount: amount,
    );

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Payment received! Scheme updated successfully."),
          backgroundColor: _emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ToastHelper.showErrorToast(
        // ignore: use_build_context_synchronously
        context,
        schemeVM.errorMessage ?? "Payment failed",
      );
    }
  }
}
