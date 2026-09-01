import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class AppProgressWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const AppProgressWidget({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppPalette.emerald,
          ),
        ),
      ),
    );
  }
}
