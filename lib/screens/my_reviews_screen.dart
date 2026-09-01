import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/toast_helper.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/review_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/review.dart';

class MyReviewsScreen extends StatefulWidget {
  static const String path = '/my-reviews';
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
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
      final customerId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ?? '1';
      Provider.of<ReviewViewModel>(context, listen: false).fetchReviews(customerId);
    });
  }

  void _addReviewForm() {
    final titleCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    int selectedRating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final reviewVM = Provider.of<ReviewViewModel>(context);
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
                      "Write a Review",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Rating Stars selection
                    Row(
                      children: List.generate(5, (index) {
                        final starRating = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedRating = starRating;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              starRating <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: titleCtrl,
                      label: "Product Name (e.g. Bangles Set)",
                      icon: Icons.shopping_bag_outlined,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: commentCtrl,
                      label: "Your Review Comment",
                      icon: Icons.rate_review_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: reviewVM.isLoading ? null : () async {
                          final comment = commentCtrl.text.trim();
                          final pName = titleCtrl.text.trim();

                          if (comment.isEmpty || pName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("All fields are required")),
                            );
                            return;
                          }

                          // In this demo, we default productId to '1' or map from common items
                          String productId = '1';
                          if (pName.toLowerCase().contains('diamond')) {
                            productId = '3';
                          }

                          final customerId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ?? '1';
                          final success = await reviewVM.addReview(
                            customerId: customerId,
                            productId: productId,
                            rating: selectedRating,
                            comment: comment,
                          );

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review submitted successfully"),
                                backgroundColor: _emeraldGreen,
                              ),
                            );
                          } else {
                            ToastHelper.showErrorToast(
                              context,
                              reviewVM.errorMessage ?? "Failed to submit review",
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emeraldGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: reviewVM.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Submit Review",
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: _goldDark, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _goldMid.withAlpha(30)),
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
    final reviewVM = Provider.of<ReviewViewModel>(context);

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        title: Text(
          "My Reviews",
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
      body: reviewVM.isLoading && reviewVM.reviews.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _goldMid))
          : reviewVM.reviews.isEmpty
              ? Center(
                  child: Text(
                    "You haven't reviewed any items yet.",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: reviewVM.reviews.length,
                  itemBuilder: (context, index) {
                    final rev = reviewVM.reviews[index];
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
                              Expanded(
                                child: Text(
                                  rev.productTitle,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                rev.date,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Stars row
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < rev.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            rev.comment,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4,
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
          onPressed: _addReviewForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _emeraldGreen,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: Text(
            "Write a Review",
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
