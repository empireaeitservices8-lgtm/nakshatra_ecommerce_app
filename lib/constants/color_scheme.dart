import 'package:flutter/material.dart';
import 'app_colors.dart';

const Color _bgCream = Color(0xFFFAF6EF);
const Color _textDark = Color(0xFF2C1A00);
const Color _baseBlack = Color(0xFF121212);
const Color _surfaceDark = Color(0xFF1E1E1E);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: emeraldGreen,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFD0E8D7),
  onPrimaryContainer: emeraldGreen,
  secondary: goldAccent,
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFFFFF1D6),
  onSecondaryContainer: goldDark,
  tertiary: goldDark,
  onTertiary: Colors.white,
  error: Color(0xFFB3261E),
  onError: Colors.white,
  background: _bgCream,
  onBackground: _textDark,
  surface: Colors.white,
  onSurface: _textDark,
  outline: Color(0xFF79747E),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: emeraldGreen,
  onPrimary: Colors.white,
  primaryContainer: emeraldGreen,
  onPrimaryContainer: Colors.white,
  secondary: goldAccent,
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFF4A3E25),
  onSecondaryContainer: goldAccent,
  tertiary: goldDark,
  onTertiary: Colors.white,
  error: Colors.red,
  onError: Colors.white,
  background: _baseBlack,
  onBackground: Colors.white,
  surface: _surfaceDark,
  onSurface: Colors.white,
  outline: Color(0xFF938F99),
);
