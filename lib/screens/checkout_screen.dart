// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../helpers/toast_helper.dart';
import '../providers/cart_provider.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/address_viewmodel.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../services/razorpay_service.dart';

class CheckoutScreen extends StatefulWidget {
  static const String path = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Main Navigation step: 1 = Address, 2 = Payment, 3 = Summary
  int _currentStep = 1;

  // Sub-Navigation step for Payment (Step 2):
  // 1 = Payment method list, 2 = Choose Saved Card, 3 = Add Card
  int _paymentSubStep = 1;

  // Premium Gold & Luxury Color Palette
  static const Color _goldAccent = Color(0xFFEAA123);
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);
  static const Color _emeraldGreen = Color(0xFF2E513D);
  static const Color _luxuryBlack = Color(0xFF1E1E1E);

  // Address selection state
  String _selectedAddressId = '';

  // Addresses mock data matching the luxury app theme
  final List<Map<String, String>> _addresses = [];

  // Payment method selection state
  String _selectedPaymentMethod = 'cod'; // default to cash on delivery

  // Cards data with CRED style themes
  final List<Map<String, String>> _savedCards = [];
  String? _selectedCardId;

  // Card controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryMonthController =
      TextEditingController();
  final TextEditingController _cardExpiryYearController =
      TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  // Coupon state
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponApplied = false;
  double _promoDiscount = 0.0;
  final String _appliedCouponCode = 'FREE100';

  // Razorpay checkout handler
  final RazorpayService _razorpayService = RazorpayService();
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardFieldChanged);
    _cardExpiryMonthController.addListener(_onCardFieldChanged);
    _cardExpiryYearController.addListener(_onCardFieldChanged);
    _cardHolderController.addListener(_onCardFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
          '1';
      Provider.of<AddressViewModel>(
        context,
        listen: false,
      ).fetchAddresses(customerId);
      Provider.of<PaymentViewModel>(
        context,
        listen: false,
      ).fetchCards(customerId);
    });
  }

  void _onCardFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _couponController.dispose();
    _cardNumberController.removeListener(_onCardFieldChanged);
    _cardExpiryMonthController.removeListener(_onCardFieldChanged);
    _cardExpiryYearController.removeListener(_onCardFieldChanged);
    _cardHolderController.removeListener(_onCardFieldChanged);
    _cardNumberController.dispose();
    _cardExpiryMonthController.dispose();
    _cardExpiryYearController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  // Razorpay branded badge
  Widget _buildRazorpayLogo({double size = 24}) {
    return Icon(Icons.bolt_rounded, color: const Color(0xFF3395FF), size: size);
  }

  // Google Pay custom branded logo
  Widget _buildGPayLogo({double fontSize = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "G",
          style: GoogleFonts.outfit(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Text(
          "P",
          style: GoogleFonts.outfit(
            color: Colors.red.shade600,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Text(
          "a",
          style: GoogleFonts.outfit(
            color: Colors.amber.shade600,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Text(
          "y",
          style: GoogleFonts.outfit(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPaymentIcon(String method) {
    IconData iconData = Icons.monetization_on_outlined;
    Color iconColor = Colors.green;

    switch (method) {
      case 'paypal':
        iconData = Icons.paypal_outlined;
        iconColor = Colors.blue;
        break;
      case 'bank':
        iconData = Icons.account_balance_outlined;
        iconColor = Colors.teal;
        break;
      case 'card':
        iconData = Icons.credit_card_outlined;
        iconColor = Colors.orange;
        break;
      case 'gpay':
        return _buildGPayLogo(fontSize: 14);
      case 'razorpay':
        return _buildRazorpayLogo(size: 22);
      case 'cod':
      default:
        iconData = Icons.monetization_on_outlined;
        iconColor = Colors.green;
        break;
    }

    return Icon(iconData, color: iconColor, size: 22);
  }

  // Modal Sheet Form to Add/Edit Addresses
  void _showAddressForm({Map<String, String>? existingAddress}) {
    final isEditing = existingAddress != null;
    final nameCtrl = TextEditingController(
      text: isEditing ? existingAddress['name'] : '',
    );
    final phoneCtrl = TextEditingController(
      text: isEditing ? existingAddress['phone'] : '',
    );
    final addrCtrl = TextEditingController(
      text: isEditing ? existingAddress['address'] : '',
    );
    String selectedLabel = isEditing
        ? (existingAddress['label'] ?? 'Home')
        : 'Home';

    final isDark = Provider.of<CartProvider>(context, listen: false).isDarkMode;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isEditing ? "Edit Address" : "Add New Address",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: ['Home', 'Work', 'Other'].map((label) {
                        final isSelected = selectedLabel == label;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedLabel = label;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [_goldAccent, _goldDark],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : (isDark
                                        ? const Color(0xFF2A2A2A)
                                        : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : textDark.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildFormTextField(
                      controller: nameCtrl,
                      label: "Recipient Name",
                      icon: Icons.person_outline,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFormTextField(
                      controller: phoneCtrl,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildFormTextField(
                      controller: addrCtrl,
                      label: "Full Address details",
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [_goldAccent, Color(0xFFC78410)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          final addr = addrCtrl.text.trim();

                          if (name.isEmpty || phone.isEmpty || addr.isEmpty) {
                            ToastHelper.showErrorToast(
                              context,
                              "Please fill in all fields",
                            );
                            return;
                          }
                          final customerId =
                              Provider.of<AuthViewModel>(
                                context,
                                listen: false,
                              ).currentUser?.id ??
                              '1';
                          final addressVM = Provider.of<AddressViewModel>(
                            context,
                            listen: false,
                          );

                          final bool success;
                          if (isEditing) {
                            success = await addressVM.updateAddress(
                              customerId: customerId,
                              addressId: existingAddress['id']!,
                              label: selectedLabel,
                              name: name,
                              phone: phone,
                              address: addr,
                            );
                          } else {
                            success = await addressVM.addAddress(
                              customerId: customerId,
                              label: selectedLabel,
                              name: name,
                              phone: phone,
                              address: addr,
                            );
                          }

                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context);
                            ToastHelper.showSuccessToast(
                              context,
                              isEditing
                                  ? "Address updated successfully"
                                  : "Address added successfully",
                            );
                            if (addressVM.addresses.isNotEmpty) {
                              setState(() {
                                _selectedAddressId =
                                    addressVM.addresses.last.id;
                              });
                            }
                          } else {
                            ToastHelper.showErrorToast(
                              context,
                              addressVM.errorMessage ??
                                  "Failed to save address",
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEditing ? "Update Address" : "Save Address",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required bool isDark,
  }) {
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: textDark, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: _goldDark, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _goldMid.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _goldAccent, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFFAF6EF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = cart.isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final addressVM = Provider.of<AddressViewModel>(context);
    final paymentVM = Provider.of<PaymentViewModel>(context);

    _addresses.clear();
    _addresses.addAll(
      addressVM.addresses.map(
        (a) => {
          'id': a.id,
          'label': a.label,
          'name': a.name,
          'address': a.address,
          'phone': a.phone,
        },
      ),
    );
    if (_selectedAddressId.isEmpty && _addresses.isNotEmpty) {
      _selectedAddressId = _addresses.first['id'] ?? '';
    }

    _savedCards.clear();
    _savedCards.addAll(
      paymentVM.cards.map(
        (c) => {
          'id': c.id,
          'number': c.number,
          'expiry': c.expiry,
          'cvv': '123',
          'holder': c.holder,
          'brand': c.brand,
          'theme': 'platinum',
        },
      ),
    );
    if (_selectedCardId == null && _savedCards.isNotEmpty) {
      _selectedCardId = _savedCards.first['id'];
    }

    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    // Dynamic AppBar title based on steps
    String appBarTitle = "Choose Delivery Address";
    if (_currentStep == 2) {
      if (_paymentSubStep == 1) {
        appBarTitle = "Choose Payment Method";
      } else if (_paymentSubStep == 2) {
        appBarTitle = "Choose Card";
      } else if (_paymentSubStep == 3) {
        appBarTitle = "Add Card";
      }
    } else if (_currentStep == 3) {
      appBarTitle = "Order Summary";
    }

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textDark,
          ),
        ),
        backgroundColor: cardWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_currentStep == 2) {
              if (_paymentSubStep > 1) {
                setState(() {
                  _paymentSubStep--;
                });
              } else {
                setState(() {
                  _currentStep = 1;
                });
              }
            } else if (_currentStep == 3) {
              setState(() {
                _currentStep = 2;
                _paymentSubStep = _selectedPaymentMethod == 'card' ? 2 : 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _goldMid.withAlpha(30), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom timeline Stepper
            _buildStepper(isDark),
            Container(height: 1, color: Colors.grey.withOpacity(0.12)),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildStepContent(
                    isDark,
                    cardWhite,
                    bgCream,
                    textDark,
                    cart,
                  ),
                ),
              ),
            ),
            // Floating Luxury Bottom Bar (proceeding actions only)
            _buildBottomBar(cardWhite, textDark, cart),
          ],
        ),
      ),
    );
  }

  // PREMIUM TIMELINE STEPPER
  Widget _buildStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _buildStepNode(0, "Cart", isDark),
          _buildStepConnector(0),
          _buildStepNode(1, "Address", isDark),
          _buildStepConnector(1),
          _buildStepNode(2, "Payment", isDark),
          _buildStepConnector(2),
          _buildStepNode(3, "Summary", isDark),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, String label, bool isDark) {
    bool isCompleted = index < _currentStep;
    bool isActive = index == _currentStep;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? _goldAccent
                  : isActive
                  ? Colors.transparent
                  : Colors.transparent,
              border: Border.all(
                color: (isCompleted || isActive)
                    ? _goldAccent
                    : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _goldAccent.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Container(
                      width: isActive ? 22 : 32,
                      height: isActive ? 22 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? _goldAccent : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: (isActive || isCompleted)
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: (isActive || isCompleted)
                  ? (isDark ? Colors.white : const Color(0xFF2C1A00))
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int startIndex) {
    bool isFilled = startIndex < _currentStep;
    return Container(
      width: 25,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isFilled ? _goldAccent : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // DYNAMIC STEP CONTENT
  Widget _buildStepContent(
    bool isDark,
    Color cardWhite,
    Color bgCream,
    Color textDark,
    CartProvider cart,
  ) {
    switch (_currentStep) {
      case 1:
        return _buildAddressStep(isDark, cardWhite, textDark);
      case 2:
        return _buildPaymentStep(isDark, cardWhite, textDark);
      case 3:
        return _buildSummaryStep(isDark, cardWhite, bgCream, textDark, cart);
      default:
        return Container();
    }
  }

  // STEP 1: CHOOSE DELIVERY ADDRESS (WITH DASHED ADD BUTTON AND LUXURIOUS GRID STYLE)
  Widget _buildAddressStep(bool isDark, Color cardWhite, Color textDark) {
    final addressVM = Provider.of<AddressViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beautiful luxury style "Dashed Card" at the top of the list to add new address
        GestureDetector(
          onTap: () => _showAddressForm(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _goldAccent.withOpacity(0.4),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_location_alt_outlined,
                  color: _goldAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  "Add New Delivery Address",
                  style: GoogleFonts.poppins(
                    color: _goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (addressVM.isBusy && _addresses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: _goldAccent)),
          )
        else if (_addresses.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _goldAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_outlined,
                    size: 40,
                    color: _goldAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No Delivery Address Found",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You haven't added any delivery address yet. Please add an address to continue with your checkout.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showAddressForm(),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: Text(
                    "Add Delivery Address",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emeraldGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // Grid/List of Addresses
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final addr = _addresses[index];
              final isSelected = _selectedAddressId == addr['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAddressId = addr['id']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? _goldAccent
                          : Colors.grey.withOpacity(0.12),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _goldAccent.withOpacity(0.08),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _goldAccent.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                addr['label'] ?? 'Address',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isSelected
                                      ? _goldAccent
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            // Premium select check badge
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: _goldAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          addr['name'] ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          addr['address'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          addr['phone'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _showAddressForm(existingAddress: addr),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _goldAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Edit",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                final customerId =
                                    Provider.of<AuthViewModel>(
                                      context,
                                      listen: false,
                                    ).currentUser?.id ??
                                    '1';
                                final delSuccess = await addressVM
                                    .deleteAddress(customerId, addr['id']!);
                                if (!mounted) return;
                                if (delSuccess) {
                                  ToastHelper.showSuccessToast(
                                    context,
                                    "Address deleted successfully",
                                  );
                                  if (_selectedAddressId == addr['id']) {
                                    setState(() {
                                      _selectedAddressId =
                                          addressVM.addresses.isNotEmpty
                                          ? addressVM.addresses.first.id
                                          : '';
                                    });
                                  }
                                } else {
                                  ToastHelper.showErrorToast(
                                    context,
                                    addressVM.errorMessage ??
                                        "Failed to delete address",
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey.shade500,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  // STEP 2: CHOOSE PAYMENT METHOD (ROUTED SUB-STEPS)
  Widget _buildPaymentStep(bool isDark, Color cardWhite, Color textDark) {
    if (_paymentSubStep == 1) {
      return _buildPaymentMethodsListStep(isDark, cardWhite, textDark);
    } else if (_paymentSubStep == 2) {
      return _buildChooseCardStep(isDark, cardWhite, textDark);
    } else {
      return _buildAddCardStep(isDark, cardWhite, textDark);
    }
  }

  // SUB-STEP 1: PAYMENT METHOD SELECTION LIST
  Widget _buildPaymentMethodsListStep(
    bool isDark,
    Color cardWhite,
    Color textDark,
  ) {
    final paymentVM = Provider.of<PaymentViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(
            "Select Payment Method",
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),
        if (paymentVM.isRazorpayEnabled)
          _buildPaymentOption(
            id: 'razorpay',
            title: "Pay Online (Razorpay)",
            subtitle: "UPI, Cards, Netbanking & Wallets",
            iconWidget: _buildRazorpayLogo(),
            isDark: isDark,
            cardWhite: cardWhite,
          ),
        _buildPaymentOption(
          id: 'card',
          title: "Debit or Credit Card",
          iconWidget: const Icon(
            Icons.credit_card_outlined,
            color: Colors.blue,
            size: 24,
          ),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        _buildPaymentOption(
          id: 'wallet',
          title: "Wallet",
          iconWidget: const Icon(
            Icons.credit_card_outlined,
            color: Colors.blue,
            size: 24,
          ),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        _buildPaymentOption(
          id: 'paypal',
          title: "Paypal",
          iconWidget: const Icon(
            Icons.paypal_outlined,
            color: Colors.blue,
            size: 24,
          ),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        _buildPaymentOption(
          id: 'bank',
          title: "Bank Transfer",
          iconWidget: const Icon(
            Icons.account_balance_outlined,
            color: Colors.teal,
            size: 24,
          ),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        _buildPaymentOption(
          id: 'cod',
          title: "Cash on Delivery",
          iconWidget: const Icon(
            Icons.monetization_on_outlined,
            color: Colors.green,
            size: 24,
          ),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        _buildPaymentOption(
          id: 'gpay',
          title: "Google Pay",
          iconWidget: _buildGPayLogo(fontSize: 16),
          isDark: isDark,
          cardWhite: cardWhite,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    String? subtitle,
    required Widget iconWidget,
    required bool isDark,
    required Color cardWhite,
  }) {
    bool isSelected = _selectedPaymentMethod == id;
    Color activeBg = isDark ? const Color(0xFF262A34) : const Color(0xFFFFFDF6);
    Color itemBg = isSelected ? activeBg : cardWhite;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _goldAccent : Colors.grey.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _goldAccent.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF2C1A00),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: _goldAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
          ],
        ),
      ),
    );
  }

  // SUB-STEP 2: CHOOSE SAVED CARD SCREEN (CRED STYLE CARD STACK VIEW)
  Widget _buildChooseCardStep(bool isDark, Color cardWhite, Color textDark) {
    // 1. Calculate top positions and total visual height of card stack dynamically
    double deckHeight = 0.0;
    List<double> cardTops = [];

    for (int i = 0; i < _savedCards.length; i++) {
      cardTops.add(deckHeight);
      final card = _savedCards[i];
      final isSelected = _selectedCardId == card['id'];
      deckHeight += isSelected ? 190.0 : 70.0; // selected cards take more space
    }

    // Adjust total container height to exactly contain the last card (180px height) without overflow
    if (_savedCards.isNotEmpty) {
      final lastIndex = _savedCards.length - 1;
      deckHeight = cardTops[lastIndex] + 180.0 + 10.0;
    } else {
      deckHeight = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "Select Card",
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),

        // Beautiful dashed Add Card item at the top
        GestureDetector(
          onTap: () {
            _cardNumberController.clear();
            _cardExpiryMonthController.clear();
            _cardExpiryYearController.clear();
            _cardCvvController.clear();
            _cardHolderController.clear();
            setState(() {
              _paymentSubStep = 3; // Go to Add Card Form
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _goldAccent.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_card_outlined,
                  color: _goldAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "Add New Debit or Credit Card",
                  style: GoogleFonts.poppins(
                    color: _goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Overlapping CRED style Card Deck Stack
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: deckHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(_savedCards.length, (index) {
                final card = _savedCards[index];
                final isSelected = _selectedCardId == card['id'];

                // Dynamic card texts
                String cardNumber = card['number'] ?? '•••• •••• •••• ••••';
                String brand = card['brand'] ?? 'PLATINUM';
                String theme = card['theme'] ?? 'platinum';
                String holder = card['holder'] ?? 'CARDHOLDER';
                String expiry = card['expiry'] ?? 'MM/YY';

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: cardTops[index],
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCardId = card['id'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: _getCardGradient(theme),
                        border: Border.all(
                          color: isSelected ? _goldAccent : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _goldAccent.withOpacity(0.2)
                                : Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: isSelected ? 2 : 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background metallic wavy design
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.08,
                              child: CustomPaint(painter: CardWavePainter()),
                            ),
                          ),
                          // Card contents
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top Row: Brand name & Card Checkbox/Action icons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      brand.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    // Selected Checkmark badge OR Edit/Delete icons if selected
                                    if (isSelected)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _cardNumberController.text =
                                                  card['number'] ?? '';
                                              final expiryParts =
                                                  (card['expiry'] ?? '').split(
                                                    '/',
                                                  );
                                              if (expiryParts.length == 2) {
                                                _cardExpiryMonthController
                                                        .text =
                                                    expiryParts[0];
                                                _cardExpiryYearController.text =
                                                    expiryParts[1].length == 2
                                                    // ignore: prefer_interpolation_to_compose_strings
                                                    ? '20' + expiryParts[1]
                                                    : expiryParts[1];
                                              }
                                              _cardCvvController.text =
                                                  card['cvv'] ?? '';
                                              _cardHolderController.text =
                                                  card['holder'] ?? '';
                                              setState(() {
                                                _paymentSubStep =
                                                    3; // Add/Edit Card
                                              });
                                            },
                                            child: const Icon(
                                              Icons.edit_note_outlined,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _savedCards.removeAt(index);
                                                if (_selectedCardId ==
                                                    card['id']) {
                                                  _selectedCardId =
                                                      _savedCards.isNotEmpty
                                                      ? _savedCards[0]['id']
                                                      : null;
                                                }
                                              });
                                            },
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white30,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                // Chip display
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFEFA6),
                                            Color(0xFFD4AF37),
                                            Color(0xFF996515),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFFFFDF7A),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: CustomPaint(
                                        painter: ChipLinePainter(),
                                      ),
                                    ),
                                  ],
                                ),
                                // Card Number Monospace Text
                                Text(
                                  cardNumber,
                                  style: GoogleFonts.sourceCodePro(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                // Bottom Row: Holder name & Expiry Date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "CARDHOLDER",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white30,
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Text(
                                            holder.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "EXPIRES",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white30,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          expiry,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  LinearGradient _getCardGradient(String? theme) {
    switch (theme) {
      case 'platinum':
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'emerald':
        return const LinearGradient(
          colors: [Color(0xFF0A2E1A), Color(0xFF1A4D2E), Color(0xFF2E513D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'gold':
      default:
        return const LinearGradient(
          colors: [Color(0xFFD4A017), Color(0xFFB8860B), Color(0xFF2C1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  // SUB-STEP 3: ADD CARD SCREEN (THIRD SCREEN IN MOCKUP WITH INPUT FORMATTERS AND LIMITS)
  Widget _buildAddCardStep(bool isDark, Color cardWhite, Color textDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Visual Card Preview with stacked depth and dynamic text
          _buildCreditCardPreview(isDark),
          const SizedBox(height: 20),

          // 2. Title "Payment details"
          Text(
            "Payment details",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 20),

          // 3. Form fields
          _buildUnderlineTextField(
            controller: _cardHolderController,
            label: "Cardholder Name",
            icon: Icons.person_outline,
            textDark: textDark,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              LengthLimitingTextInputFormatter(30),
            ],
          ),
          const SizedBox(height: 24),

          _buildUnderlineTextField(
            controller: _cardNumberController,
            label: "Card Number",
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            textDark: textDark,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
              LengthLimitingTextInputFormatter(19),
              CardNumberInputFormatter(),
            ],
          ),
          const SizedBox(height: 24),

          // Side-by-side row of Expiry Month, Expiry Year, and CVV
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildUnderlineTextField(
                  controller: _cardExpiryMonthController,
                  label: "Expiry Month",
                  icon: Icons.calendar_month_outlined,
                  keyboardType: TextInputType.number,
                  textDark: textDark,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: _buildUnderlineTextField(
                  controller: _cardExpiryYearController,
                  label: "Expiry Year",
                  icon: Icons.calendar_month_outlined,
                  keyboardType: TextInputType.number,
                  textDark: textDark,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: _buildUnderlineTextField(
                  controller: _cardCvvController,
                  label: "CVV",
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textDark: textDark,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 4. Payment amount label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Payment amount: ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                "\$${_calculateTotal(Provider.of<CartProvider>(context, listen: false)).toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _goldDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Action Buttons (Cancel / Add Card)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _cardNumberController.clear();
                    _cardExpiryMonthController.clear();
                    _cardExpiryYearController.clear();
                    _cardCvvController.clear();
                    _cardHolderController.clear();
                    setState(() {
                      _paymentSubStep = 2; // Return to Choose Card list
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: Colors.redAccent,
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [_goldAccent, Color(0xFFE59C1A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _goldAccent.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validations
                      final rawCardNumber = _cardNumberController.text
                          .replaceAll(' ', '');
                      if (rawCardNumber.length != 16) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Card Number must be exactly 16 digits",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final monthText = _cardExpiryMonthController.text;
                      int? month = int.tryParse(monthText);
                      if (month == null || month < 1 || month > 12) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Expiry Month must be between 01 and 12",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final yearText = _cardExpiryYearController.text;
                      if (yearText.length != 4 && yearText.length != 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Expiry Year must be a 2 or 4 digit year",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (_cardCvvController.text.length != 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Security Code (CVV) must be exactly 3 digits",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (_cardHolderController.text.trim().length < 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Card Holder Name must have at least 3 characters",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final customerId =
                          Provider.of<AuthViewModel>(
                            context,
                            listen: false,
                          ).currentUser?.id ??
                          '1';
                      final paymentVM = Provider.of<PaymentViewModel>(
                        context,
                        listen: false,
                      );
                      paymentVM.saveCard(
                        customerId: customerId,
                        number: _cardNumberController.text.trim(),
                        expiryMonth: monthText,
                        expiryYear: yearText,
                        cvv: _cardCvvController.text.trim(),
                        holder: _cardHolderController.text.trim(),
                        brand: 'CARD ELITE',
                        theme: 'platinum',
                      );
                      setState(() {
                        if (paymentVM.cards.isNotEmpty) {
                          _selectedCardId = paymentVM.cards.last.id;
                        }
                        _paymentSubStep = 2; // Return to card list
                      });
                      _cardNumberController.clear();
                      _cardExpiryMonthController.clear();
                      _cardExpiryYearController.clear();
                      _cardCvvController.clear();
                      _cardHolderController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Add Card",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    required Color textDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 9,
            color: Colors.grey.shade500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _goldAccent, size: 18),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 0,
            ),
            isDense: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _goldAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardPreview(bool isDark) {
    String cardNumber = _cardNumberController.text.isEmpty
        ? "•••• •••• •••• ••••"
        : _cardNumberController.text;
    String cardHolder = _cardHolderController.text.isEmpty
        ? "CARDHOLDER NAME"
        : _cardHolderController.text.toUpperCase();
    String expiryMonth = _cardExpiryMonthController.text.isEmpty
        ? "MM"
        : _cardExpiryMonthController.text;
    String expiryYear = _cardExpiryYearController.text.isEmpty
        ? "YY"
        : (_cardExpiryYearController.text.length == 4
              ? _cardExpiryYearController.text.substring(2)
              : _cardExpiryYearController.text);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        width: 320,
        height: 190,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                width: 296,
                height: 174,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      _goldDark.withOpacity(0.5),
                      _luxuryBlack.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_goldAccent, _goldDark, _luxuryBlack],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _goldAccent.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(painter: CardWavePainter()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 42,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFEFA6),
                                    Color(0xFFD4AF37),
                                    Color(0xFF996515),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFFDF7A),
                                  width: 1,
                                ),
                              ),
                              child: CustomPaint(painter: ChipLinePainter()),
                            ),
                            const Icon(
                              Icons.auto_awesome_mosaic_outlined,
                              color: Colors.white70,
                              size: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cardNumber,
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              const Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CARDHOLDER NAME",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white54,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cardHolder,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "EXPIRES",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$expiryMonth/$expiryYear",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3: ORDER SUMMARY VIEW
  Widget _buildSummaryStep(
    bool isDark,
    Color cardWhite,
    Color bgCream,
    Color textDark,
    CartProvider cart,
  ) {
    final Map<String, String> activeAddr = _addresses.firstWhere(
      (a) => a['id'] == _selectedAddressId,
      orElse: () => _addresses.isNotEmpty ? _addresses.first : {},
    );

    final activeCard = _selectedPaymentMethod == 'card'
        ? _savedCards.firstWhere(
            (c) => c['id'] == _selectedCardId,
            orElse: () => {},
          )
        : <String, String>{};

    String paymentLabel = "Cash on Delivery";
    if (_selectedPaymentMethod == 'paypal') paymentLabel = "Paypal";
    if (_selectedPaymentMethod == 'bank') paymentLabel = "Bank Transfer";
    if (_selectedPaymentMethod == 'card') {
      paymentLabel =
          "Debit or Credit Card (${activeCard['number'] ?? 'New Card'})";
    }
    if (_selectedPaymentMethod == 'gpay') paymentLabel = "Google Pay";
    if (_selectedPaymentMethod == 'razorpay') {
      paymentLabel = "Pay Online (Razorpay)";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. VIP Delivery Guarantee Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F2D1C), const Color(0xFF1E3A27)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.green.withOpacity(0.3)
                    : Colors.green.shade200,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.lightGreen : Colors.green.shade700)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_outlined,
                    color: isDark ? Colors.lightGreen : Colors.green.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PREMIUM SHIPPING GUARANTEED",
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Estimated Delivery by Thursday, 07 Oct",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark
                              ? Colors.lightGreen
                              : Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Horizontal scrolling Cart Items list
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Items in Order",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${cart.items.length} Product${cart.items.length > 1 ? 's' : ''}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _goldAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _goldMid.withAlpha(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: item.imagePath.startsWith('http')
                                      ? Image.network(
                                          item.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(Icons.image, size: 24),
                                        )
                                      : Image.asset(
                                          item.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(Icons.image, size: 24),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.price,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _goldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: _goldAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${item.quantity}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. Envelope styled Delivery Address card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Address",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                child: Text(
                  "Change",
                  style: GoogleFonts.poppins(
                    color: _goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _goldAccent.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _goldAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: _goldAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeAddr['name'] ?? '',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeAddr['address'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeAddr['phone'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _goldAccent.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (activeAddr['label'] ?? 'HOME').toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: _goldAccent,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Payment Method Card Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Method",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStep = 2;
                    _paymentSubStep = 1;
                  });
                },
                child: Text(
                  "Change",
                  style: GoogleFonts.poppins(
                    color: _goldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_selectedPaymentMethod == 'card' && activeCard.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = 2;
                  _paymentSubStep = 2; // Return to card selection stack
                });
              },
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _getCardGradient(activeCard['theme'] ?? 'platinum'),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.06,
                        child: CustomPaint(painter: CardWavePainter()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (activeCard['brand'] ?? 'PLATINUM')
                                    .toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _goldAccent,
                                size: 18,
                              ),
                            ],
                          ),
                          Text(
                            activeCard['number'] ?? '•••• •••• •••• ••••',
                            style: GoogleFonts.sourceCodePro(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (activeCard['holder'] ?? 'JANE DOE')
                                    .toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                activeCard['expiry'] ?? 'MM/YY',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  _buildSelectedPaymentIcon(_selectedPaymentMethod),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Pay with $paymentLabel",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textDark,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // 5. Coupon field
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _couponController,
                    style: GoogleFonts.poppins(color: textDark, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Enter Coupon Code",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: _goldAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_goldAccent, _goldDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    final code = _couponController.text.trim();
                    if (code.isEmpty) return;

                    final orderVM = Provider.of<OrderViewModel>(
                      context,
                      listen: false,
                    );
                    final customerId =
                        Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        ).currentUser?.id ??
                        '1';
                    final success = await orderVM.validateCoupon(
                      customerId,
                      code,
                    );
                    if (success) {
                      setState(() {
                        _isCouponApplied = true;
                        _promoDiscount = orderVM.couponDiscount;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            orderVM.couponMessage ??
                                "Coupon applied successfully!",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() {
                        _isCouponApplied = false;
                        _promoDiscount = 0.0;
                      });
                      ToastHelper.showErrorToast(
                        context,
                        orderVM.couponMessage ?? "Invalid coupon code",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Apply",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _couponController.text = _appliedCouponCode;
                });
              },
              child: Text(
                "See Offers (Apply FREE100)",
                style: GoogleFonts.poppins(
                  color: _goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // 6. Pricing invoice block
          Text(
            "Pricing Details",
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _goldMid.withAlpha(20), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                _buildPriceBreakdownRow(
                  "Items (${cart.items.length})",
                  _calculateSubtotal(cart),
                  isDark,
                  textDark,
                ),
                const SizedBox(height: 12),
                _buildPriceBreakdownRow("Shipping", 0.0, isDark, textDark),
                if (_isCouponApplied) ...[
                  const SizedBox(height: 12),
                  _buildPriceBreakdownRow(
                    "Promo Code ($_appliedCouponCode Applied!)",
                    -_promoDiscount,
                    isDark,
                    textDark,
                    isDiscount: true,
                  ),
                ],
                const SizedBox(height: 12),
                Container(height: 1, color: _goldMid.withOpacity(0.15)),
                const SizedBox(height: 12),
                _buildPriceBreakdownRow(
                  "Total Amount",
                  _calculateTotal(cart),
                  isDark,
                  textDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownRow(
    String label,
    dynamic amount,
    bool isDark,
    Color textDark, {
    bool isDiscount = false,
  }) {
    String valueText = "";
    if (amount is String) {
      valueText = amount;
    } else if (amount is num) {
      if (label == "Shipping" && amount == 0.0) {
        valueText = "FREE";
      } else {
        String sign = amount < 0 ? "-" : "";
        double displayAmount = amount.abs().toDouble();
        valueText = isDiscount
            ? "$sign₹${displayAmount.toStringAsFixed(2)}"
            : "₹${displayAmount.toStringAsFixed(2)}";
      }
    }

    final bool isTotal = label == "Total Amount";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? textDark
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
        Text(
          valueText,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? Colors.red.shade600
                : (valueText == "FREE"
                      ? Colors.green.shade700
                      : (isTotal
                            ? _goldDark
                            : (isDark ? Colors.white : Colors.black87))),
          ),
        ),
      ],
    );
  }

  double _calculateSubtotal(CartProvider cart) {
    double subtotal = 0.0;
    for (var item in cart.items) {
      double priceVal =
          double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      subtotal += priceVal * item.quantity;
    }
    return subtotal;
  }

  double _calculateTotal(CartProvider cart) {
    double subtotal = _calculateSubtotal(cart);
    double shipping = 0.0;
    double discount = _isCouponApplied ? _promoDiscount : 0.0;
    double total = subtotal + shipping - discount;
    return total < 0 ? 0.0 : total;
  }

  // FLOATING LUXURY DOCK BOTTOM BAR (PROCEED ACTION ONLY)
  Widget _buildBottomBar(Color cardWhite, Color textDark, CartProvider cart) {
    if (_currentStep == 2 && _paymentSubStep == 3) {
      return const SizedBox.shrink();
    }

    double total = _calculateTotal(cart);
    String totalStr = "₹${total.toStringAsFixed(2)}";

    // Determine primary action text
    String actionText = "Deliver Here";
    if (_currentStep == 1) {
      actionText = _addresses.isNotEmpty
          ? "Deliver Here"
          : "Add Delivery Address";
    } else if (_currentStep == 2) {
      if (_paymentSubStep == 1) {
        actionText = "Continue";
      } else if (_paymentSubStep == 2) {
        actionText = "Use Card";
      }
    } else if (_currentStep == 3) {
      actionText = "Pay Now";
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _goldAccent.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  totalStr,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _goldDark,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "View Pricing Details",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [_goldAccent, Color(0xFFE59C1A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _goldAccent.withOpacity(0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 1) {
                  if (_addresses.isNotEmpty) {
                    setState(() {
                      _currentStep = 2;
                      _paymentSubStep = 1;
                    });
                  } else {
                    _showAddressForm();
                  }
                } else if (_currentStep == 2) {
                  if (_paymentSubStep == 1) {
                    if (_selectedPaymentMethod == 'card') {
                      setState(() {
                        _paymentSubStep = 2; // Go to saved cards sub-step
                      });
                    } else {
                      setState(() {
                        _currentStep = 3; // Go to Order Summary
                      });
                    }
                  } else if (_paymentSubStep == 2) {
                    if (_selectedCardId != null) {
                      setState(() {
                        _currentStep = 3; // Go to Summary
                      });
                    }
                  }
                } else if (_currentStep == 3) {
                  if (!_isPaying) _placeOrder(cart);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                actionText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder(CartProvider cart) async {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final customerId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
        '1';

    // Extract active address details
    final activeAddr = _addresses.firstWhere(
      (a) => a['id'] == _selectedAddressId,
      orElse: () => _addresses.isNotEmpty ? _addresses.first : {},
    );

    String shippingAddress = activeAddr['address'] ?? '';
    String shippingPhone = activeAddr['phone'] ?? '';
    String shippingCity = 'Calicut';

    if (shippingAddress.contains(',')) {
      final parts = shippingAddress.split(',');
      if (parts.length > 1 && parts.last.trim().isNotEmpty) {
        shippingCity = parts.last.trim();
      }
    }

    // Online payment via Razorpay must succeed before the order is created.
    final isRazorpay = _selectedPaymentMethod == 'razorpay';
    RazorpayResult? rzpResult;
    if (isRazorpay) {
      final paymentVM = Provider.of<PaymentViewModel>(context, listen: false);
      final config = paymentVM.razorpay;
      if (config == null || !config.isUsable) {
        ToastHelper.showErrorToast(context, "Online payment is unavailable");
        return;
      }
      final total = _calculateTotal(cart);
      if (total <= 0) {
        ToastHelper.showErrorToast(context, "Invalid order amount");
        return;
      }

      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      final activeUpi = paymentVM.upiProfiles.where((u) => u.isActive);

      setState(() => _isPaying = true);
      rzpResult = await _razorpayService.pay(
        config: config,
        amount: total,
        name: 'Nakshatra',
        description: 'Jewellery Order',
        contact: (user?.phone.isNotEmpty ?? false) ? user!.phone : shippingPhone,
        email: user?.email,
        preferredUpiId: activeUpi.isNotEmpty ? activeUpi.first.upiId : null,
      );
      if (!mounted) return;

      if (!rzpResult.success) {
        setState(() => _isPaying = false);
        ToastHelper.showErrorToast(
          context,
          rzpResult.errorMessage ?? "Payment failed",
        );
        return;
      }
    }

    final success = await orderVM.placeOrder(
      customerId: customerId,
      addressId: _selectedAddressId,
      paymentMethod: isRazorpay ? 'razorpay' : 'cash',
      shippingAddress: shippingAddress.isNotEmpty
          ? shippingAddress
          : '123 Main Street',
      shippingCity: shippingCity,
      shippingPhone: shippingPhone.isNotEmpty ? shippingPhone : '+919876543210',
      notes: 'Deliver on weekend if possible',
      cardId: _selectedPaymentMethod == 'card' ? _selectedCardId : null,
      couponCode: _isCouponApplied ? _couponController.text.trim() : null,
      razorpayPaymentId: rzpResult?.paymentId,
      razorpayOrderId: rzpResult?.orderId,
      razorpaySignature: rzpResult?.signature,
    );

    if (mounted) setState(() => _isPaying = false);

    if (!success) {
      if (mounted) {
        ToastHelper.showErrorToast(
          context,
          rzpResult != null
              ? "Payment received (ID: ${rzpResult.paymentId}) but order failed: "
                    "${orderVM.errorMessage ?? 'unknown error'}. Please contact support."
              : (orderVM.errorMessage ?? "Failed to place order"),
        );
      }
      return;
    }

    final isDark = cart.isDarkMode;
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    await Provider.of<CartViewModel>(
      context,
      listen: false,
    ).clearCart(customerId);
    cart.clearCart();
    cart.setTabIndex(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _emeraldGreen.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: _emeraldGreen,
            size: 80,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Order Placed!",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your handcrafted jewelry is being prepared with love and care.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [_emeraldGreen, Color(0xFF1B382A)],
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Back to Home",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var cleanText = text.replaceAll(' ', '');
    var buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != cleanText.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var cleanText = newText.replaceAll('/', '');
    var buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      int nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != cleanText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.95,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw chip design grid lines
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
