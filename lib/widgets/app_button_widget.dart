import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class AppButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isBordered;
  final bool isCurved;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.isBordered = false,
    this.isCurved = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 48.0,
    this.fontSize = 15.0,
    this.padding,
  });

  factory AppButton.curvedButton({
    Key? key,
    String? text,
    Widget? child,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 48.0,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        text: text,
        child: child,
        onPressed: onPressed ?? onTap,
        backgroundColor: backgroundColor,
        textColor: textColor,
        width: width,
        height: height,
        isLoading: isLoading,
        isCurved: true,
      );

  factory AppButton.squareButton({
    Key? key,
    String? text,
    Widget? child,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 48.0,
    bool isLoading = false,
  }) =>
      AppButton(
        key: key,
        text: text,
        child: child,
        onPressed: onPressed ?? onTap,
        backgroundColor: backgroundColor,
        textColor: textColor,
        width: width,
        height: height,
        isLoading: isLoading,
        isCurved: false,
      );

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        (isBordered ? Colors.transparent : AppPalette.emerald);
    final effectiveTextColor = textColor ??
        (isBordered ? AppPalette.emerald : Colors.white);
    final borderRadius = BorderRadius.circular(isCurved ? 24.0 : 8.0);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveTextColor,
          elevation: isBordered ? 0 : 1,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: isBordered
                ? BorderSide(
                    color: borderColor ?? AppPalette.emerald,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isBordered ? AppPalette.emerald : Colors.white,
                  ),
                ),
              )
            : (child ??
                Text(
                  text ?? '',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: effectiveTextColor,
                  ),
                )),
      ),
    );
  }
}
