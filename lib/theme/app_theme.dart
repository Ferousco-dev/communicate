import 'package:flutter/material.dart';

/// Calm, warm palette taken straight from the CommuniCare mockups.
class AppColors {
  // Teal family (primary brand)
  static const teal = Color(0xFF1D9E75);
  static const tealDark = Color(0xFF0F6E56);
  static const tealMid = Color(0xFF5DCAA5);
  static const tealLight = Color(0xFFE1F5EE);
  static const tealBg = Color(0xFFF4FBF8);

  // Accents
  static const purple = Color(0xFF534AB7);
  static const blue = Color(0xFF185FA5);
  static const amber = Color(0xFFBA7517);
  static const amberMid = Color(0xFFEF9F27);
  static const coral = Color(0xFFD85A30);
  static const green = Color(0xFF639922);
  static const pink = Color(0xFFD4537E);

  // Neutrals
  static const ink = Color(0xFF2C2C2A);
  static const muted = Color(0xFF5F5E5A);
  static const line = Color(0xFFD3D1C7);
}

/// When sensory / quiet mode is on, pull any accent colour toward a soft sage
/// so the whole app reads calmer without changing the layout.
Color calmIf(bool sensory, Color c) =>
    sensory ? Color.lerp(c, const Color(0xFF8AA39A), 0.6)! : c;

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.teal,
    scaffoldBackgroundColor: AppColors.tealBg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}
