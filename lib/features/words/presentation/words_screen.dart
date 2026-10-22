import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class WordsScreen extends StatelessWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Kelimeler', style: AppTypography.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Kaydettiğin kelimeler, tematik desteler ve tekrar zamanı tek yerde olacak.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _TabSetupNote(
          title: 'Kelime alanı hazırlanıyor',
          description:
              'Sözlük arama, kaydedilen kelimeler ve aralıklı tekrar akışı ayrı bir adımda eklenecek.',
          icon: Icons.bookmarks_outlined,
        ),
      ],
    );
  }
}

class _TabSetupNote extends StatelessWidget {
  const _TabSetupNote({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: AppTypography.bodySm),
        ],
      ),
    );
  }
}
