import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

/// Minimal learning landing screen.
///
/// Navigation to lessons, vocabulary, and practice remains available through
/// the app's bottom navigation. The landing screen intentionally avoids
/// duplicating those destinations with recommendation and shortcut cards.
class LearnScreen extends StatelessWidget {
  const LearnScreen({
    required this.onOpenLessons,
    required this.onOpenWords,
    required this.onOpenPractice,
    super.key,
  });

  // Kept as constructor callbacks for compatibility with the app shell.
  final VoidCallback onOpenLessons;
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
        Text('BUBIXO', style: AppTypography.eyebrowSmall),
        const SizedBox(height: AppSpacing.md),
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
