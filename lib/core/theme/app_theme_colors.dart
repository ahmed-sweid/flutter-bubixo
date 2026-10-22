import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';

/// Additional brand/semantic colors not represented by ColorScheme alone.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.inkStrong,
    required this.body,
    required this.bodyMid,
    required this.muted,
    required this.mutedSoft,
    required this.hairline,
    required this.accentPurple,
    required this.accentPink,
    required this.accentBlue,
    required this.accentBlueDeep,
    required this.accentBlueInfo,
    required this.accentOrange,
    required this.accentGreen,
    required this.accentYellow,
    required this.accentRed,
  });

  final Color inkStrong;
  final Color body;
  final Color bodyMid;
  final Color muted;
  final Color mutedSoft;
  final Color hairline;

  final Color accentPurple;
  final Color accentPink;
  final Color accentBlue;
  final Color accentBlueDeep;
  final Color accentBlueInfo;
  final Color accentOrange;
  final Color accentGreen;
  final Color accentYellow;
  final Color accentRed;

  static const light = AppThemeColors(
    inkStrong: AppColors.inkStrong,
    body: AppColors.body,
    bodyMid: AppColors.bodyMid,
    muted: AppColors.muted,
    mutedSoft: AppColors.mutedSoft,
    hairline: AppColors.hairline,
    accentPurple: AppColors.accentPurple,
    accentPink: AppColors.accentPink,
    accentBlue: AppColors.accentBlue,
    accentBlueDeep: AppColors.accentBlueDeep,
    accentBlueInfo: AppColors.accentBlueInfo,
    accentOrange: AppColors.accentOrange,
    accentGreen: AppColors.accentGreen,
    accentYellow: AppColors.accentYellow,
    accentRed: AppColors.accentRed,
  );

  @override
  AppThemeColors copyWith({
    Color? inkStrong,
    Color? body,
    Color? bodyMid,
    Color? muted,
    Color? mutedSoft,
    Color? hairline,
    Color? accentPurple,
    Color? accentPink,
    Color? accentBlue,
    Color? accentBlueDeep,
    Color? accentBlueInfo,
    Color? accentOrange,
    Color? accentGreen,
    Color? accentYellow,
    Color? accentRed,
  }) {
    return AppThemeColors(
      inkStrong: inkStrong ?? this.inkStrong,
      body: body ?? this.body,
      bodyMid: bodyMid ?? this.bodyMid,
      muted: muted ?? this.muted,
      mutedSoft: mutedSoft ?? this.mutedSoft,
      hairline: hairline ?? this.hairline,
      accentPurple: accentPurple ?? this.accentPurple,
      accentPink: accentPink ?? this.accentPink,
      accentBlue: accentBlue ?? this.accentBlue,
      accentBlueDeep: accentBlueDeep ?? this.accentBlueDeep,
      accentBlueInfo: accentBlueInfo ?? this.accentBlueInfo,
      accentOrange: accentOrange ?? this.accentOrange,
      accentGreen: accentGreen ?? this.accentGreen,
      accentYellow: accentYellow ?? this.accentYellow,
      accentRed: accentRed ?? this.accentRed,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      inkStrong: Color.lerp(inkStrong, other.inkStrong, t)!,
      body: Color.lerp(body, other.body, t)!,
      bodyMid: Color.lerp(bodyMid, other.bodyMid, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedSoft: Color.lerp(mutedSoft, other.mutedSoft, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentPink: Color.lerp(accentPink, other.accentPink, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentBlueDeep: Color.lerp(accentBlueDeep, other.accentBlueDeep, t)!,
      accentBlueInfo: Color.lerp(accentBlueInfo, other.accentBlueInfo, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
    );
  }
}
