import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartAnimationHelper {
  static final GlobalKey homeCartKey = GlobalKey();
  static final GlobalKey categoriesCartKey = GlobalKey();
  static final GlobalKey detailCartKey = GlobalKey();
  static final GlobalKey searchCartKey = GlobalKey();

  static GlobalKey getActiveCartKey(BuildContext context) {
    if (searchCartKey.currentContext != null) {
      return searchCartKey;
    }
    if (detailCartKey.currentContext != null) {
      return detailCartKey;
    }
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.currentTabIndex == 1) {
        return categoriesCartKey;
      }
    } catch (_) {}
    return homeCartKey;
  }

  static void runAddToCartAnimation({
    required BuildContext context,
    required GlobalKey imageKey,
    required String imagePath,
    VoidCallback? onComplete,
  }) {
    final overlayState = Overlay.of(context);
    final RenderBox? imageBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
    final cartIconKey = getActiveCartKey(context);
    final RenderBox? cartBox = cartIconKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null || cartBox == null) {
      onComplete?.call();
      return;
    }

    final imageSize = imageBox.size;
    final imagePosition = imageBox.localToGlobal(Offset.zero);
    final cartPosition = cartBox.localToGlobal(Offset.zero);
    final cartSize = cartBox.size;

    final startOffset = Offset(
      imagePosition.dx + imageSize.width / 2,
      imagePosition.dy + imageSize.height / 2,
    );

    final endOffset = Offset(
      cartPosition.dx + cartSize.width / 2,
      cartPosition.dy + cartSize.height / 2,
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _CurvedAnimationOverlay(
          startOffset: startOffset,
          endOffset: endOffset,
          imagePath: imagePath,
          imageSize: Size(min(imageSize.width, 100.0), min(imageSize.height, 100.0)),
          onAnimationEnd: () {
            entry.remove();
            onComplete?.call();
          },
        );
      },
    );

    overlayState.insert(entry);
  }
}

class _CurvedAnimationOverlay extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String imagePath;
  final Size imageSize;
  final VoidCallback onAnimationEnd;

  const _CurvedAnimationOverlay({
    required this.startOffset,
    required this.endOffset,
    required this.imagePath,
    required this.imageSize,
    required this.onAnimationEnd,
  });

  @override
  State<_CurvedAnimationOverlay> createState() => _CurvedAnimationOverlayState();
}

class _CurvedAnimationOverlayState extends State<_CurvedAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;

        // Quadratic Bezier Curve Calculation
        // Control Point: arcs upward and slightly to the side
        final controlX = (widget.startOffset.dx + widget.endOffset.dx) / 2;
        final controlY = min(widget.startOffset.dy, widget.endOffset.dy) - 120.0;

        final double currentX = (1 - t) * (1 - t) * widget.startOffset.dx +
            2 * (1 - t) * t * controlX +
            t * t * widget.endOffset.dx;

        final double currentY = (1 - t) * (1 - t) * widget.startOffset.dy +
            2 * (1 - t) * t * controlY +
            t * t * widget.endOffset.dy;

        // Scale animates from 1.0 down to 0.15
        final double scale = 1.0 - (t * 0.85);

        // Opacity animates from 1.0 down to 0.4
        final double opacity = 1.0 - (t * 0.6);

        return Positioned(
          left: currentX - widget.imageSize.width / 2,
          top: currentY - widget.imageSize.height / 2,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.imageSize.width,
          height: widget.imageSize.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildItemImage(widget.imagePath),
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/product1.png',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/product1.png',
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
