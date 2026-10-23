import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/lesson.dart';
import '../data/lesson_repository.dart';
import '../data/learning_progress_repository.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, this.showBackButton = true});

  /// Hide the back button when this screen is used as a bottom-navigation tab.
  final bool showBackButton;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late Future<List<Lesson>> _lessonsFuture;
  Set<String> _completedLessonIds = <String>{};
  String? _lastLessonId;
  final LearningProgressRepository _progressRepository = const LearningProgressRepository();

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final values = await Future.wait<Object?>([
      _progressRepository.loadCompletedLessons(),
      _progressRepository.loadLastLessonId(),
    ]);
    if (!mounted) return;
    setState(() {
      _completedLessonIds = values[0] as Set<String>;
      _lastLessonId = values[1] as String?;
    });
  }

  Future<void> _openLesson(List<Lesson> lessons, int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(lessons: lessons, lessonIndex: index),
      ),
    );
    await _loadProgress();
  }

  void _loadLessons() {
    _lessonsFuture = const LessonRepository().loadLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                tooltip: 'Geri',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Iconsax.arrow_left_2),
              )
            : null,
        title: Text(
          'Temel dersler',
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
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
              onRetry: () => setState(_loadLessons),
            );
          }

          final lessons = snapshot.data ?? const <Lesson>[];
          if (lessons.isEmpty) {
            return const Center(child: Text('Henüz ders bulunmuyor.'));
          }
          final lessonIds = lessons.map((lesson) => lesson.id).toSet();
          final completedLessonIds = _completedLessonIds.intersection(lessonIds);
          final totalMinutes = lessons.fold<int>(0, (sum, lesson) => sum + lesson.minutes);
          final lastLessonIndex = lessons.indexWhere((lesson) => lesson.id == _lastLessonId);
          final canResume =
              lastLessonIndex >= 0 && !completedLessonIds.contains(_lastLessonId);

          return ListView(
            key: const PageStorageKey<String>('lessons-screen-scroll'),
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
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text('İlerlemen', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700))),
                      Text('${completedLessonIds.length} / ${lessons.length} ders', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: lessons.isEmpty ? 0 : completedLessonIds.length / lessons.length,
                        minHeight: 6,
                        backgroundColor: AppColors.hairline,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
                      ),
                    ),
                  ],
                ),
              ),
              if (canResume) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openLesson(lessons, lastLessonIndex),
                    icon: const Icon(Iconsax.play_circle),
                    label: Text('Kaldığın derse devam et · ${lessons[lastLessonIndex].title}'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
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
                      onTap: () => _openLesson(lessons, index),
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
                            if (_completedLessonIds.contains(lesson.id))
                              const Icon(Iconsax.tick_circle, size: 20, color: AppColors.accentGreen)
                            else
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
