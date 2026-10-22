import 'package:flutter/material.dart';

/// Color tokens translated from DESIGN-webflow.md.
///
/// WF Visual Sans is proprietary, so the typography tokens use Inter as the
/// preferred open-source substitute and allow Flutter's platform fallback.
abstract final class AppColors {
  static const Color primary = Color(0xFF080808);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF080808);
  static const Color inkStrong = Color(0xFF222222);
  static const Color body = Color(0xFF363636);
  static const Color bodyMid = Color(0xFF5A5A5A);
  static const Color muted = Color(0xFF898989);
  static const Color mutedSoft = Color(0xFFABABAB);

  static const Color canvas = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFD8D8D8);

  static const Color accentPurple = Color(0xFF7A3DFF);
  static const Color accentPink = Color(0xFFED52CB);
  static const Color accentBlue = Color(0xFF3B89FF);
  static const Color accentBlueDeep = Color(0xFF006ACC);
  static const Color accentBlueInfo = Color(0xFF146EF5);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color accentGreen = Color(0xFF00D722);
  static const Color accentYellow = Color(0xFFFFAE13);
  static const Color accentRed = Color(0xFFEE1D36);

  static const Color transparent = Colors.transparent;
}
