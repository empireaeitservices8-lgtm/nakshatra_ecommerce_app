import 'package:flutter/material.dart';
import '../utils/app_palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = foregroundColor ?? (isDark ? Colors.white : AppPalette.textDark);
    final bg = backgroundColor ?? (isDark ? AppPalette.surfaceDark : AppPalette.surfaceWhite);

    return AppBar(
      title: titleWidget ??
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
      centerTitle: true,
      elevation: elevation,
      backgroundColor: bg,
      foregroundColor: fg,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: fg,
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

PreferredSizeWidget buildAppBar({
  required String title,
  bool showBackButton = true,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
  Color? backgroundColor,
  Color? foregroundColor,
  double elevation = 0,
}) {
  return CustomAppBar(
    title: title,
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
    actions: actions,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
  );
}
