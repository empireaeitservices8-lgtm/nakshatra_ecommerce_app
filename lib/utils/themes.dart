// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'brand_colors.dart';

final ThemeData appLightTheme = _buildTheme(Brightness.light);
final ThemeData appDarkTheme = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppPalette.emerald,
    onPrimary: Colors.white,
    primaryContainer: isDark ? AppPalette.emeraldDark : const Color(0xFFD0E8D7),
    onPrimaryContainer: isDark ? Colors.white : AppPalette.emerald,
    secondary: AppPalette.gold,
    onSecondary: Colors.black,
    secondaryContainer: isDark ? const Color(0xFF4A3E25) : AppPalette.goldLight,
    onSecondaryContainer: isDark ? AppPalette.gold : AppPalette.goldDark,
    tertiary: AppPalette.goldDark,
    onTertiary: Colors.white,
    error: isDark ? Colors.redAccent : AppPalette.error,
    onError: Colors.white,
    background: isDark ? AppPalette.bgDark : AppPalette.bgCream,
    onBackground: isDark ? AppPalette.textLight : AppPalette.textDark,
    surface: isDark ? AppPalette.surfaceDark : AppPalette.surfaceWhite,
    onSurface: isDark ? AppPalette.textLight : AppPalette.textDark,
    outline: isDark ? const Color(0xFF938F99) : const Color(0xFF79747E),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? AppPalette.bgDark : AppPalette.bgCream,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: isDark
          ? AppPalette.surfaceDark
          : AppPalette.surfaceWhite,
      foregroundColor: isDark ? Colors.white : AppPalette.textDark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppPalette.textDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? AppPalette.surfaceDark : AppPalette.surfaceWhite,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: <ThemeExtension<dynamic>>[
      isDark ? AppBrandColors.dark() : AppBrandColors.light(),
    ],
  );
}
