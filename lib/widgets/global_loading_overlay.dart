// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loading_provider.dart';
import '../utils/app_palette.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  final Widget? child;

  const GlobalLoadingOverlay({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(
      builder: (context, loading, _) {
        final isLoading = loading.isLoading;
        final message = loading.message;

        return Stack(
          children: [
            ?child,

            // Top Accent Linear Progress Bar
            if (isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: AppPalette.goldLight.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppPalette.gold,
                    ),
                  ),
                ),
              ),

            // Fullscreen Frosted Dimmed Overlay with Luxury Spinner
            IgnorePointer(
              ignoring: !isLoading,
              child: AnimatedOpacity(
                opacity: isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isLoading
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.35),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Center(
                            child: _buildLuxuryLoaderCard(context, message),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLuxuryLoaderCard(BuildContext context, String? message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppPalette.surfaceDark.withOpacity(0.92)
            : AppPalette.surfaceWhite.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPalette.gold.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppPalette.gold.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Dual-Ring Spinner
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(AppPalette.gold),
                  ),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppPalette.emeraldLight : AppPalette.emerald,
                    ),
                  ),
                ),
                const Icon(
                  Icons.diamond_outlined,
                  size: 16,
                  color: AppPalette.gold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            message ?? 'Please wait...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: isDark ? AppPalette.textLight : AppPalette.textDark,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
