import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/lesson.dart';
import '../data/lesson_repository.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late final Future<List<Lesson>> _lessonsFuture =
      const LessonRepository().loadLessons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text(
          'Temel dersler',
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(
              message: 'Dersler yüklenemedi. Dosyanın ve asset kaydının doğru olduğundan emin ol.',
              onRetry: () => setState(() {}),
            );
          }

          final lessons = snapshot.data ?? const <Lesson>[];
          if (lessons.isEmpty) {
            return const Center(child: Text('Henüz ders bulunmuyor.'));
          }
          final totalMinutes = lessons.fold<int>(0, (sum, lesson) => sum + lesson.minutes);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
            ),
            children: [
              Text('Adım adım öğren', style: AppTypography.displaySm),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bubixo’nun mevcut ders sırasını takip et. Ders içerikleri kaynak dosyadan yüklenir.',
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
                          Text(
                            'Temel dersler',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${lessons.length} ders · yaklaşık ${totalMinutes ~/ 60} saat ${totalMinutes % 60} dakika',
                            style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...lessons.asMap().entries.map((entry) {
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
                          builder: (_) => LessonDetailScreen(
                            lessons: lessons,
                            lessonIndex: index,
                          ),
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
                              child: Text(
                                '${index + 1}',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.accentPurple,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Iconsax.clock, size: 14, color: AppColors.muted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lesson.minutes} dakika',
                                        style: AppTypography.eyebrowSmall.copyWith(color: AppColors.muted),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      const Icon(Iconsax.book_1, size: 14, color: AppColors.muted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lesson.points.length} örnek',
                                        style: AppTypography.eyebrowSmall.copyWith(color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Dersler, örnekler, öğrenme ipuçları ve mini sınavlar Bubixo’nun içerik dosyasından yüklenir.',
                style: AppTypography.bodySm.copyWith(color: AppColors.muted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, size: 32, color: AppColors.bodyMid),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center, style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onRetry, child: const Text('Tekrar dene')),
            ],
          ),
        ),
      );
}
