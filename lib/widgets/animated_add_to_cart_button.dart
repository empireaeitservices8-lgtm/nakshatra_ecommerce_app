import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedAddToCartButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final double height;
  final Color? buttonColor;
  final Color? textColor;
  final bool inStock;

  const AnimatedAddToCartButton({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.height = 32.0,
    this.buttonColor,
    this.textColor,
    this.inStock = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = inStock
        ? (buttonColor ?? const Color(0xFF2C2C2E))
        : Colors.grey.shade400;
    final textThemeColor = textColor ?? Colors.white;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
      child: quantity > 0
          ? Container(
              key: const ValueKey('quantity_controls'),
              height: height,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : const Color(0xFFFAF6EF),
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Minus Button
                  GestureDetector(
                    onTap: onRemove,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: height + 4,
                      height: height,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.remove_rounded,
                        size: height * 0.55,
                        color: isDark ? Colors.white : const Color(0xFF2C1A00),
                      ),
                    ),
                  ),
                  // Quantity
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: Text(
                      '$quantity',
                      key: ValueKey('qty_$quantity'),
                      style: GoogleFonts.poppins(
                        fontSize: height * 0.42,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2C1A00),
                      ),
                    ),
                  ),
                  // Plus Button
                  GestureDetector(
                    onTap: onAdd,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: height + 4,
                      height: height,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_rounded,
                        size: height * 0.55,
                        color: isDark ? Colors.white : const Color(0xFF2C1A00),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              key: const ValueKey('add_to_cart_cta'),
              height: height,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: textThemeColor,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      inStock ? "Add to Cart" : "Out of Stock",
                      style: GoogleFonts.poppins(
                        fontSize: height * 0.35,
                        fontWeight: FontWeight.bold,
                        color: textThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
