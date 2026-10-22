import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

/// Initial shell-level landing page. Real learning content is added in a
/// separate, focused feature after the navigation shell is verified.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

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
        Text('Öğrenmeye devam et.', style: AppTypography.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Kaldığın yerden devam et; henüz bir oturum yoksa bugünün önerisi burada olacak.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _LearningEntryCard(
          eyebrow: 'ÖĞRENME YOLUN',
          title: 'Kaldığın yerden devam et',
          description:
              'Öğrenme içeriği ve kayıtlı ilerleme bir sonraki geliştirme adımında bağlanacak.',
          icon: Iconsax.routing,
        ),
        const SizedBox(height: AppSpacing.md),
        _LearningEntryCard(
          eyebrow: 'BUGÜNÜN ÖNERİSİ',
          title: 'Küçük bir adımla başla',
          description:
              'Günün dersi, önerisi ve tekrar zamanı gerçek öğrenme verileri bağlandığında burada görünecek.',
          icon: Iconsax.sun_1,
          accent: AppColors.accentPurple,
        ),
      ],
    );
  }
}

class _LearningEntryCard extends StatelessWidget {
  const _LearningEntryCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.accent = AppColors.ink,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  eyebrow,
                  style: AppTypography.eyebrowSmall.copyWith(
                    color: AppColors.bodyMid,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: AppTypography.bodySm),
        ],
      ),
    );
  }
}
