import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/lesson.dart';
import 'cubit/lessons_cubit.dart';
import 'cubit/lessons_state.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key, this.showBackButton = true});

  /// Hide the back button when this screen is used as a bottom-navigation tab.
  final bool showBackButton;

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  Future<void> _openLesson(
    BuildContext context,
    List<Lesson> lessons,
    int index,
  ) async {
    final lessonsCubit = context.read<LessonsCubit>();
    await lessonsCubit.rememberLesson(lessons[index].id);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('bubixo.last_activity_type', 'lesson');
    await preferences.setString('bubixo.last_activity_id', lessons[index].id);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(lessons: lessons, lessonIndex: index),
      ),
    );
    if (!mounted) return;
    await lessonsCubit.refreshProgress();
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
      body: BlocProvider(
        create: (_) => LessonsCubit()..load(),
        child: BlocBuilder<LessonsCubit, LessonsState>(
          builder: (context, state) {
            if (state.status == LessonsStatus.loading ||
                state.status == LessonsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == LessonsStatus.failure) {
              return _LoadError(
                message: 'Dersler yüklenemedi. Dosyanın ve asset kaydının doğru olduğundan emin ol.',
                onRetry: () => context.read<LessonsCubit>().load(),
              );
            }

            final lessons = state.lessons;
            if (lessons.isEmpty) {
            return const Center(child: Text('Henüz ders bulunmuyor.'));
          }
          final lessonIds = lessons.map((lesson) => lesson.id).toSet();
          final completedLessonIds = state.completedLessonIds.intersection(lessonIds);
          return ListView(
            key: const PageStorageKey<String>('lessons-screen-scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
            ),
            children: [
              const SizedBox(height: AppSpacing.sm),
              ...lessons.asMap().entries.map((entry) {
                final index = entry.key;
                final lesson = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Material(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _openLesson(context, lessons, index),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.hairline),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
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
                            if (completedLessonIds.contains(lesson.id))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F7EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Bitirildi',
                                  style: AppTypography.eyebrowSmall.copyWith(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
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
