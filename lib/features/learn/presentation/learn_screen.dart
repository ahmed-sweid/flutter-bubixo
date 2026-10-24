import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../discover/data/story.dart';
import '../../discover/data/story_repository.dart';
import '../../discover/presentation/story_detail_screen.dart';
import '../data/lesson.dart';
import '../data/lesson_repository.dart';
import '../data/learning_progress_repository.dart';
import 'lesson_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    required this.onOpenDiscover,
    required this.onOpenWords,
    required this.onOpenPractice,
    required this.onOpenLessons,
    super.key,
  });

  final VoidCallback onOpenDiscover;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenPractice;
  final VoidCallback onOpenLessons;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Future<_DashboardData> _future = _load();

  Future<_DashboardData> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait<Object>([
      const StoryRepository().loadStories(),
      const LessonRepository().loadLessons(),
      const LearningProgressRepository().loadCompletedLessons(),
    ]);
    return _DashboardData(
      stories: results[0] as List<Story>,
      lessons: results[1] as List<Lesson>,
      completedLessons: results[2] as Set<String>,
      lastStoryId: prefs.getString('bubixo.last_story_id'),
      lastStoryTitle: prefs.getString('bubixo.last_story_title'),
      lastLessonId: prefs.getString('bubixo.learning.last_lesson_id'),
      activityType: prefs.getString('bubixo.last_activity_type'),
      activityId: prefs.getString('bubixo.last_activity_id'),
      savedWords: prefs.getStringList('bubixo.saved_words')?.length ?? 0,
      practiceSessions: prefs.getInt('bubixo.practice.sessions') ?? 0,
    );
  }

  Future<void> _continue(_DashboardData d) async {
    if (d.activityType == 'story' || (d.activityType == null && d.lastStoryId != null)) {
      final id = d.activityId ?? d.lastStoryId;
      final i = d.stories.indexWhere((s) => s.id == id);
      if (i >= 0 && mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => StoryDetailScreen(story: d.stories[i]),
        ));
        if (mounted) setState(() => _future = _load());
        return;
      }
    } else if (d.activityType == 'lesson' || (d.activityType == null && d.lastLessonId != null)) {
      final id = d.activityId ?? d.lastLessonId;
      final i = d.lessons.indexWhere((l) => l.id == id);
      if (i >= 0 && mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => LessonDetailScreen(lessons: d.lessons, lessonIndex: i),
        ));
        if (mounted) setState(() => _future = _load());
        return;
      }
    } else if (d.activityType == 'practice') {
      widget.onOpenPractice();
      return;
    }
    if (d.practiceSessions > 0) {
      widget.onOpenPractice();
      return;
    }
    widget.onOpenDiscover();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_DashboardData>(
    future: _future,
    builder: (context, snapshot) {
      final data = snapshot.data;
      final loading = snapshot.connectionState != ConnectionState.done;
      final completed = data?.completedCount ?? 0;
      final total = data?.lessons.length ?? 0;
      final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

      return ListView(
        key: const PageStorageKey<String>('learn-screen-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İlerlemen',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (loading || data == null)
                  const LinearProgressIndicator(minHeight: 3)
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'Tamamlanan dersler',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.bodyMid,
                          ),
                        ),
                      ),
                      Text(
                        '$completed / $total',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.hairline,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(height: 1, color: AppColors.hairline),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _ProgressMetric(
                          label: 'Kaydedilen kelime',
                          value: '${data.savedWords}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: AppColors.hairline,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.md),
                          child: _ProgressMetric(
                            label: 'Pratik oturumu',
                            value: '${data.practiceSessions}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _DashboardData {
  const _DashboardData({
    required this.stories, required this.lessons, required this.completedLessons,
    required this.lastStoryId, required this.lastStoryTitle, required this.lastLessonId,
    required this.activityType, required this.activityId, required this.savedWords,
    required this.practiceSessions,
  });
  final List<Story> stories;
  final List<Lesson> lessons;
  final Set<String> completedLessons;
  final String? lastStoryId, lastStoryTitle, lastLessonId, activityType, activityId;
  final int savedWords, practiceSessions;
  int get completedCount => completedLessons.intersection(lessons.map((e) => e.id).toSet()).length;
  String get continueTitle {
    if (activityType == 'story' && activityId != null) {
      for (final s in stories) { if (s.id == activityId) return s.title; }
    }
    if (activityType == 'lesson' && activityId != null) {
      for (final l in lessons) { if (l.id == activityId) return l.title; }
    }
    if (lastStoryId != null) return lastStoryTitle ?? 'Son okuduğun hikâye';
    if (lastLessonId != null) {
      for (final l in lessons) { if (l.id == lastLessonId) return l.title; }
    }
    return 'İlk etkinliğini seç';
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.xxs),
      Text(
        label,
        style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink));
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.body))),
    Text(value, style: AppTypography.bodySm.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
  ]);
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.canvas,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.bodyMid),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            Text(subtitle, style: AppTypography.bodySm),
          ])),
          const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
        ]),
      ),
    ),
  );
}
