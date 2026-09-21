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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer Image Area
                Expanded(
                  child: _ShimmerContainer(
                    height: double.infinity,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(16),
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    offset: _gradientPosition.value,
                  ),
                ),
                const SizedBox(height: 8),
                // Shimmer Bottom Pill
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFF6F5F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShimmerContainer(
                            height: 12,
                            width: 65,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            offset: _gradientPosition.value,
                          ),
                          const SizedBox(height: 4),
                          _ShimmerContainer(
                            height: 12,
                            width: 45,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            offset: _gradientPosition.value,
                          ),
                        ],
                      ),
                      _ShimmerContainer(
                        height: 28,
                        width: 28,
                        borderRadius: BorderRadius.circular(14),
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        offset: _gradientPosition.value,
                      ),
                    ],
                  ),
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
