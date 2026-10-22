import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Subtle elevation tokens. The source design uses shadows sparingly.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A080808),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x12080808),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x08080808),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const BorderSide hairline = BorderSide(color: AppColors.hairline);
}
