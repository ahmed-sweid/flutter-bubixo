import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/story.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({required this.story, super.key});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          story.title,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          Text(story.titleTr, style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Text(story.intro, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.book_1, color: AppColors.accentPurple, size: 19),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'OKUMA REHBERİ',
                      style: AppTypography.eyebrowSmall.copyWith(color: AppColors.mutedSoft),
                    ),
                    const Spacer(),
                    Text(
                      'Seviye ${story.level}',
                      style: AppTypography.eyebrowSmall.copyWith(color: AppColors.onPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${story.lines.length} cümleyle İngilizce oku',
                  style: AppTypography.displayXs.copyWith(color: AppColors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Önce İngilizce cümleyi oku, ardından Türkçe anlamına ve kelime notlarına göz at.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Hikâye', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          ...story.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.en,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(line.tr, style: AppTypography.bodySm),
                    if (line.words.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: line.words
                            .map(
                              (word) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.hairline.withValues(
                                    alpha: 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${word.english} · ${word.turkish}',
                                  style: AppTypography.eyebrowSmall,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hikâyenin sonuna geldin.',
            style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
