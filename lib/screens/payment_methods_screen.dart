// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class PaymentMethodsScreen extends StatefulWidget {
  static const String path = '/payment-methods';
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);
  static const Color _emeraldGreen = Color(0xFF2E513D);

  Color get _bgCream => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF121212)
      : const Color(0xFFFAF6EF);
  Color get _cardWhite => Provider.of<CartProvider>(context).isDarkMode
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFFFFFFF);
  Color get _textDark => Provider.of<CartProvider>(context).isDarkMode
      ? Colors.white
      : const Color(0xFF2C1A00);

  final List<String> _upis = ['sarahw@okaxis', 'sarahwilliams@paytm'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
          '1';
      Provider.of<PaymentViewModel>(
        context,
        listen: false,
      ).fetchCards(customerId);
    });
  }

  void _deleteCard(String id) async {
    final customerId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
        '1';
    final success = await Provider.of<PaymentViewModel>(
      context,
      listen: false,
    ).deleteCard(customerId, id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment card removed successfully."),
          backgroundColor: Color(0xFF2E513D),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to remove payment card."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _addCardForm() {
    final numberCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController(text: '123');
    final holderCtrl = TextEditingController();
    String selectedCardType = 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final paymentVM = Provider.of<PaymentViewModel>(context);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add Credit / Debit Card",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: ['Visa', 'Mastercard', 'Rupay'].map((type) {
                        final isSelected = selectedCardType == type;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCardType = type;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _emeraldGreen : _cardWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? _emeraldGreen
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : (Provider.of<CartProvider>(
                                            context,
                                            listen: false,
                                          ).isDarkMode
                                          ? Colors.white70
                                          : Colors.black54),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _paymentTextField(
                      controller: holderCtrl,
                      label: "Card Holder Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _paymentTextField(
                      controller: numberCtrl,
                      label: "Card Number",
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _paymentTextField(
                            controller: expCtrl,
                            label: "Expiry (MM/YY)",
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _paymentTextField(
                            controller: cvvCtrl,
                            label: "CVV",
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: paymentVM.isLoading
                          ? null
                          : () async {
                              final number = numberCtrl.text.trim();
                              final expStr = expCtrl.text.trim();
                              final cvv = cvvCtrl.text.trim();
                              final holder = holderCtrl.text.trim();

                              if (number.isEmpty ||
                                  expStr.isEmpty ||
                                  cvv.isEmpty ||
                                  holder.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please fill all card details",
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              // Parse expiry
                              final expParts = expStr.split('/');
                              final expMonth = expParts.isNotEmpty
                                  ? expParts[0].trim()
                                  : '12';
                              final expYear = expParts.length > 1
                                  ? expParts[1].trim()
                                  : '28';

                              final customerId =
                                  Provider.of<AuthViewModel>(
                                    context,
                                    listen: false,
                                  ).currentUser?.id ??
                                  '1';
                              final success = await paymentVM.saveCard(
                                customerId: customerId,
                                number: number,
                                expiryMonth: expMonth,
                                expiryYear: expYear,
                                cvv: cvv,
                                holder: holder,
                                brand: selectedCardType.toUpperCase(),
                                theme: 'platinum',
                              );

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Card added successfully",
                                    ),
                                    backgroundColor: _emeraldGreen,
                                  ),
                                );
                              } else {
                                ToastHelper.showErrorToast(
                                  context,
                                  paymentVM.errorMessage ??
                                      "Failed to add card",
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _emeraldGreen,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: paymentVM.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Save Card",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _paymentTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: _goldDark, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _goldMid.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _goldDark, width: 1.5),
        ),
        filled: true,
        fillColor: _bgCream,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentVM = Provider.of<PaymentViewModel>(context);

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        title: Text(
          "Payment Methods",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: _textDark,
          ),
        ),
        backgroundColor: _cardWhite,
        foregroundColor: _textDark,
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
      body: paymentVM.isLoading && paymentVM.cards.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _goldMid))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  "Saved Cards",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 15),
                if (paymentVM.cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No cards saved yet.",
                        style: GoogleFonts.poppins(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ...paymentVM.cards.map((card) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1C2D24),
                            Color(0xFF2E513D),
                          ], // Dark forest emerald green gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
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
                                card.brand.isNotEmpty ? card.brand : 'VISA',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () => _deleteCard(card.id),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            card.number,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CARD HOLDER",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 8,
                                    ),
                                  ),
                                  Text(
                                    card.holder,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "EXPIRES",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 8,
                                    ),
                                  ),
                                  Text(
                                    card.expiry,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _addCardForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    "Add New Card",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cardWhite,
                    foregroundColor: _emeraldGreen,
                    side: const BorderSide(color: _emeraldGreen, width: 1.2),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "UPI Profiles",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ..._upis.map((upi) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _goldMid.withAlpha(20)),
                    ),
                    child: Material(
                      color: _cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _bgCream,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: _goldDark,
                          ),
                        ),
                        title: Text(
                          upi,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        trailing: Text(
                          "UPI Active",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
