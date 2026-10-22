import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale from DESIGN-webflow.md.
///
/// WF Visual Sans is not bundled with the project. Inter is used as the
/// documented open-source substitute; Flutter falls back if it is unavailable.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle displayXxl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 80,
    fontWeight: FontWeight.w600,
    height: 1.04,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const TextStyle displayXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 1.04,
    color: AppColors.ink,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44.8,
    fontWeight: FontWeight.w600,
    height: 1.04,
    color: AppColors.ink,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.ink,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.ink,
  );

  static const TextStyle displayXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 1.5,
    color: AppColors.ink,
  );

  static const TextStyle eyebrowSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
    letterSpacing: 0.6,
    color: AppColors.ink,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.8,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: -0.288,
    color: AppColors.body,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: -0.16,
    color: AppColors.body,
  );

  static const TextStyle bodyMdStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: -0.16,
    color: AppColors.ink,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.bodyMid,
  );

  static const TextStyle bodySmStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.6,
    color: AppColors.ink,
  );

  /// Flutter does not expose a 550 weight; w500 is the closest supported role.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.8,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.bodyMid,
  );

  static const TextStyle captionMono = TextStyle(
    fontFamily: 'Inconsolata',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.bodyMid,
  );

  static const TextStyle buttonMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: -0.16,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayXxl,
    displayMedium: displayXl,
    displaySmall: displayLg,
    headlineLarge: displayMd,
    headlineMedium: displaySm,
    headlineSmall: displayXs,
    titleLarge: displaySm,
    titleMedium: bodyMdStrong,
    titleSmall: bodySmStrong,
    bodyLarge: bodyMd,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
    labelLarge: buttonMd,
    labelMedium: caption,
    labelSmall: eyebrowSmall,
  );
}
