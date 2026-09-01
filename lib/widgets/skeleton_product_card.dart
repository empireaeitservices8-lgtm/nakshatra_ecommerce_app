import 'package:flutter/material.dart';

class SkeletonProductCard extends StatefulWidget {
  const SkeletonProductCard({super.key});

  @override
  State<SkeletonProductCard> createState() => _SkeletonProductCardState();
}

class _SkeletonProductCardState extends State<SkeletonProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _gradientPosition = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF2F2F2);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);

    return AnimatedBuilder(
      animation: _gradientPosition,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer Image Area
                _ShimmerContainer(
                  height: 120,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(20),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  offset: _gradientPosition.value,
                ),
                const SizedBox(height: 10),
                // Shimmer Title
                _ShimmerContainer(
                  height: 14,
                  width: 100,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  offset: _gradientPosition.value,
                ),
                const SizedBox(height: 6),
                // Shimmer Subtitle line 1
                _ShimmerContainer(
                  height: 10,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(3),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  offset: _gradientPosition.value,
                ),
                const SizedBox(height: 4),
                // Shimmer Subtitle line 2
                _ShimmerContainer(
                  height: 10,
                  width: 120,
                  borderRadius: BorderRadius.circular(3),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  offset: _gradientPosition.value,
                ),
                const SizedBox(height: 12),
                // Shimmer Rating
                _ShimmerContainer(
                  height: 10,
                  width: 50,
                  borderRadius: BorderRadius.circular(3),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  offset: _gradientPosition.value,
                ),
                const SizedBox(height: 12),
                // Shimmer Price and Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShimmerContainer(
                      height: 16,
                      width: 60,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      offset: _gradientPosition.value,
                    ),
                    _ShimmerContainer(
                      height: 28,
                      width: 60,
                      borderRadius: BorderRadius.circular(14),
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      offset: _gradientPosition.value,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final double offset;

  const _ShimmerContainer({
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.baseColor,
    required this.highlightColor,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: [
            0.0,
            0.5 + offset * 0.25,
            1.0,
          ],
        ),
      ),
    );
  }
}
