import 'package:flutter/material.dart';
import 'app_palette.dart';

@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Color goldAccent;

  const AppBrandColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.goldAccent,
  });

  factory AppBrandColors.light() => const AppBrandColors(
        primary: AppPalette.emerald,
        secondary: AppPalette.gold,
        background: AppPalette.bgCream,
        surface: AppPalette.surfaceWhite,
        text: AppPalette.textDark,
        goldAccent: AppPalette.gold,
      );

  factory AppBrandColors.dark() => const AppBrandColors(
        primary: AppPalette.emerald,
        secondary: AppPalette.gold,
        background: AppPalette.bgDark,
        surface: AppPalette.surfaceDark,
        text: AppPalette.textLight,
        goldAccent: AppPalette.gold,
      );

  @override
  AppBrandColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? text,
    Color? goldAccent,
  }) {
    return AppBrandColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      goldAccent: goldAccent ?? this.goldAccent,
    );
  }

  @override
  AppBrandColors lerp(ThemeExtension<AppBrandColors>? other, double t) {
    if (other is! AppBrandColors) return this;
    return AppBrandColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      text: Color.lerp(text, other.text, t) ?? text,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t) ?? goldAccent,
    );
  }
}
