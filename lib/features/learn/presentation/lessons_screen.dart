import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import 'lesson_detail_screen.dart';

/// Lesson catalogue using titles and durations from Bubixo's original data.js.
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  static const _lessons = <_LessonItem>[
    _LessonItem('Alfabe ve Telaffuzun Temelleri', 8, 'Başlangıç'),
    _LessonItem('Selamlaşma ve Tanışma', 10, 'Günlük İngilizce'),
    _LessonItem('am / is / are — Olmak Fiili', 12, 'Dil bilgisi'),
    _LessonItem('Sayılar, Günler ve Saat', 12, 'Temel kelimeler'),
    _LessonItem('Ailem ve Sahiplik: my, your, have got', 11, 'Günlük İngilizce'),
    _LessonItem('Günlük Rutin — Geniş Zaman', 13, 'Dil bilgisi'),
    _LessonItem('Restoranda: Sipariş ve Rica', 11, 'Günlük İngilizce'),
    _LessonItem('Yol Sorma ve Yön Tarifi', 11, 'Günlük İngilizce'),
    _LessonItem('Alışveriş: Fiyat Sorma ve Beden', 10, 'Günlük İngilizce'),
    _LessonItem('Geçmişten Bahsetme: was / were', 12, 'Dil bilgisi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text('Temel dersler', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          Text('Adım adım öğren', style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bubixo’nun mevcut ders sırasını takip et. Ders süreleri kaynak içerikteki tahmini sürelerdir.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.book_1, color: AppColors.accentPurple, size: 23),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temel dersler', style: AppTypography.bodyMd.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('${_lessons.length} ders · yaklaşık 1 saat 50 dakika', style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ..._lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LessonDetailScreen(lessonIndex: index),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1ECFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text('${index + 1}', style: AppTypography.bodyMd.copyWith(color: AppColors.accentPurple, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(lesson.category, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Iconsax.clock, size: 14, color: AppColors.muted),
                              const SizedBox(width: 4),
                              Text('${lesson.minutes} dakika', style: AppTypography.eyebrowSmall.copyWith(color: AppColors.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Her derste konu özeti, örnekler, öğrenme ipucu ve mini sınav bulunur.',
            style: AppTypography.bodySm.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _LessonItem {
  const _LessonItem(this.title, this.minutes, this.category);

  final String title;
  final int minutes;
  final String category;
}
