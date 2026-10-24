import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

/// Minimal learning landing screen with only its heading and description.
class LearnScreen extends StatelessWidget {
  const LearnScreen({
    required this.onOpenDiscover,
    required this.onOpenWords,
    required this.onOpenPractice,
    super.key,
  });

  final VoidCallback onOpenDiscover;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenPractice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          'Bugün İngilizceye küçük bir adım at.',
          style: AppTypography.displaySm,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bir içerik seç, kendi hızında öğren ve ihtiyaç duyduğun yerde devam et.',
          style: AppTypography.bodyMd,
        ),
      ],
    );
  }
}
