import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../viewmodels/order_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'cart_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  static const String path = '/my-orders';
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _goldMid = Color(0xFFD4A017);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.id ?? '1';
      Provider.of<OrderViewModel>(context, listen: false).fetchOrders(customerId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return const Color(0xFFD4A017);
      case 'shipped':
        return Colors.blue.shade700;
      case 'delivered':
        return const Color(0xFF2E513D);
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildImage(String path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/product1.png', width: width, height: height, fit: fit),
      );
    } else {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/product1.png', width: width, height: height, fit: fit),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<CartProvider>(context).isDarkMode;
    final bgCream = isDark ? const Color(0xFF121212) : const Color(0xFFFAF6EF);
    final cardWhite = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final textDark = isDark ? Colors.white : const Color(0xFF2C1A00);

    final orderVM = Provider.of<OrderViewModel>(context);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: Text(
          "My Orders",
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
        actions: [
          Center(
            child: _buildCartIconWithBadge(context, bgCream, textDark),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _goldMid.withAlpha(30), height: 1),
        ),
      ),
      body: orderVM.isLoading && orderVM.orders.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _goldMid))
          : orderVM.orders.isEmpty
              ? Center(
                  child: Text(
                    "No orders placed yet.",
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: orderVM.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderVM.orders[index];
                    final statusColor = _getStatusColor(order.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _goldMid.withAlpha(25), width: 1.2),
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
                          // Order Header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order #${order.orderId}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      order.date,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: GoogleFonts.poppins(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // Items List
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              children: List.generate(order.items.length, (i) {
                                final item = order.items[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: bgCream,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _goldMid.withAlpha(20),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: _buildImage(
                                            item.imagePath,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: textDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Qty: ${item.qty}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        item.price,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _goldDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          const Divider(height: 1),
                          // Order Footer
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Amount",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: textDark,
                                  ),
                                ),
                                Text(
                                  order.total,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: _goldDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildCartIconWithBadge(
    BuildContext context,
    Color bg,
    Color textDark,
  ) {
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
                color: bg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: textDark,
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
}
