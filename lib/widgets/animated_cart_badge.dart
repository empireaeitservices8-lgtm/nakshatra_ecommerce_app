// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AnimatedCartBadge extends StatefulWidget {
  final int count;
  final Color badgeColor;
  final TextStyle textStyle;

  const AnimatedCartBadge({
    super.key,
    required this.count,
    this.badgeColor = Colors.red,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  State<AnimatedCartBadge> createState() => _AnimatedCartBadgeState();
}

class _AnimatedCartBadgeState extends State<AnimatedCartBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedCartBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.badgeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.badgeColor.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        child: Text(
          '${widget.count}',
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
