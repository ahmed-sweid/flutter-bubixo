import 'package:flutter/material.dart';

import 'app_theme_colors.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_shadows.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// Central Flutter theme mapped from DESIGN-webflow.md.
abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.accentPurple,
      onSecondary: AppColors.onPrimary,
      error: AppColors.accentRed,
      onError: AppColors.onPrimary,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
      surfaceContainerHighest: Color(0xFFF5F5F5),
      outline: AppColors.hairline,
      outlineVariant: AppColors.hairline,
      shadow: Color(0x1F080808),
      scrim: Color(0x66080808),
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.canvas,
      inversePrimary: AppColors.accentBlue,
      tertiary: AppColors.accentBlue,
      onTertiary: AppColors.onPrimary,
      surfaceTint: AppColors.primary,
    );

    final shapeSm = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );
    final shapeMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      cardColor: AppColors.canvas,
      dividerColor: AppColors.hairline,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme,
      extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.bodyMdStrong,
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
          foregroundColor: const WidgetStatePropertyAll(AppColors.onPrimary),
          textStyle: const WidgetStatePropertyAll(AppTypography.buttonMd),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          shape: WidgetStatePropertyAll(shapeSm),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStatePropertyAll(
            AppColors.onPrimary.withValues(alpha: 0.08),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
          textStyle: const WidgetStatePropertyAll(AppTypography.buttonMd),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          side: const WidgetStatePropertyAll(AppShadows.hairline),
          shape: WidgetStatePropertyAll(shapeSm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
          textStyle: const WidgetStatePropertyAll(AppTypography.buttonMd),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          shape: WidgetStatePropertyAll(shapeSm),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.mutedSoft),
        labelStyle: AppTypography.bodyMd.copyWith(color: AppColors.bodyMid),
        errorStyle: AppTypography.bodySm.copyWith(color: AppColors.accentRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.canvas,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shapeMd.copyWith(
          side: const BorderSide(color: AppColors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.canvas,
        selectedColor: AppColors.accentBlueInfo,
        disabledColor: const Color(0xFFF5F5F5),
        labelStyle: AppTypography.caption,
        secondaryLabelStyle: AppTypography.caption.copyWith(
          color: AppColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.bodyMid,
        textColor: AppColors.ink,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: AppSpacing.sm,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.hairline,
        circularTrackColor: AppColors.hairline,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.bodySm.copyWith(
          color: AppColors.onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        shape: shapeMd,
        titleTextStyle: AppTypography.displayXs,
        contentTextStyle: AppTypography.bodyMd,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        showDragHandle: true,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: AppTypography.caption.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
