// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/address_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/address.dart';

class SavedAddressesScreen extends StatefulWidget {
  static const String path = '/saved-addresses';
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId =
          Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
          '1';
      Provider.of<AddressViewModel>(
        context,
        listen: false,
      ).fetchAddresses(customerId);
    });
  }

  void _deleteAddress(String id) async {
    final addressVM = Provider.of<AddressViewModel>(context, listen: false);
    final customerId =
        Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ??
        '1';
    final success = await addressVM.deleteAddress(customerId, id);
    if (!mounted) return;
    if (success) {
      ToastHelper.showSuccessToast(context, "Address deleted successfully");
    } else {
      ToastHelper.showErrorToast(
        context,
        addressVM.errorMessage ?? "Failed to delete address",
      );
    }
  }

  void _showAddressForm({Address? existingAddress}) {
    final isEditing = existingAddress != null;
    final nameCtrl = TextEditingController(
      text: isEditing ? existingAddress.name : '',
    );
    final phoneCtrl = TextEditingController(
      text: isEditing ? existingAddress.phone : '',
    );
    final addrCtrl = TextEditingController(
      text: isEditing ? existingAddress.address : '',
    );
    String selectedLabel = isEditing
        ? (existingAddress.label.isNotEmpty ? existingAddress.label : 'Home')
        : 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final addressVM = Provider.of<AddressViewModel>(context);
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
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEditing ? "Edit Address" : "Add New Address",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: ['Home', 'Work', 'Other'].map((label) {
                        final isSelected = selectedLabel == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedLabel = label;
                                });
                              }
                            },
                            selectedColor: _emeraldGreen,
                            backgroundColor: _bgCream,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : _textDark,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: nameCtrl,
                      label: "Recipient Name",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: phoneCtrl,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: addrCtrl,
                      label: "Complete Address",
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: addressVM.isLoading
                            ? null
                            : () async {
                                final name = nameCtrl.text.trim();
                                final phone = phoneCtrl.text.trim();
                                final address = addrCtrl.text.trim();

                                if (name.isEmpty ||
                                    phone.isEmpty ||
                                    address.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("All fields are required"),
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
                                final bool success;
                                if (isEditing) {
                                  success = await addressVM.updateAddress(
                                    customerId: customerId,
                                    addressId: existingAddress.id,
                                    label: selectedLabel,
                                    name: name,
                                    phone: phone,
                                    address: address,
                                  );
                                } else {
                                  success = await addressVM.addAddress(
                                    customerId: customerId,
                                    label: selectedLabel,
                                    name: name,
                                    phone: phone,
                                    address: address,
                                  );
                                }

                                if (success) {
                                  Navigator.pop(context);
                                  ToastHelper.showSuccessToast(
                                    context,
                                    isEditing
                                        ? "Address updated successfully"
                                        : "Address saved successfully",
                                  );
                                } else {
                                  ToastHelper.showErrorToast(
                                    context,
                                    addressVM.errorMessage ??
                                        "Operation failed",
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emeraldGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: addressVM.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEditing ? "Save Address" : "Save Address",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Provider.of<CartProvider>(context).isDarkMode
              ? Colors.white70
              : Colors.black54,
        ),
        prefixIcon: Icon(icon, color: _goldDark),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: _goldMid.withOpacity(0.3)),
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

  @override
  Widget build(BuildContext context) {
    final addressVM = Provider.of<AddressViewModel>(context);

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        title: Text(
          "Saved Addresses",
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
      body: addressVM.isLoading && addressVM.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _goldMid))
          : addressVM.addresses.isEmpty
          ? Center(
              child: Text(
                "No saved addresses yet.",
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: addressVM.addresses.length,
              itemBuilder: (context, index) {
                final addr = addressVM.addresses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _goldMid.withAlpha(25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
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
                              color: _emeraldGreen.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              addr.label.isNotEmpty ? addr.label : 'Home',
                              style: GoogleFonts.poppins(
                                color: _emeraldGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: _goldDark,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _showAddressForm(existingAddress: addr),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => _deleteAddress(addr.id),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        addr.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        addr.address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Phone: ${addr.phone}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: _cardWhite,
        child: ElevatedButton(
          onPressed: () => _showAddressForm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _emeraldGreen,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Text(
            "Add New Address",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
