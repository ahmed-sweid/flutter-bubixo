import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../discover/data/story.dart';
import '../../discover/data/story_repository.dart';
import '../../practice/presentation/practice_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Future<_ProgressData> _future = _loadProgress();

  Future<_ProgressData> _loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    final stories = await const StoryRepository().loadStories();
    return _ProgressData(
      stories: stories,
      readStoryIds:
          (preferences.getStringList('bubixo.read_story_ids') ?? const <String>[])
              .toSet(),
      savedWords: preferences.getStringList('bubixo.saved_words')?.length ?? 0,
      practiceSessions: preferences.getInt('bubixo.practice.sessions') ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_ProgressData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final loading = snapshot.connectionState != ConnectionState.done;
          final storiesTotal = data?.stories.length ?? 0;
          final storiesRead = data?.readStoryCount ?? 0;
          final storiesProgress = storiesTotal == 0
              ? 0.0
              : (storiesRead / storiesTotal).clamp(0.0, 1.0);

          return ListView(
            key: const PageStorageKey<String>('learn-screen-scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            children: [
              Text(
                'Bugün ne yapmak istersin?',
                style: AppTypography.displaySm.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Kısa bir etkinlik seç ve İngilizce pratiği yap.',
                style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(16),
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
                              'Okunan hikâyeler',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.bodyMid,
                              ),
                            ),
                          ),
                          Text(
                            '$storiesRead / $storiesTotal',
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
                          value: storiesProgress,
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
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Pratik yap',
                style: AppTypography.displayXs.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Kelime oyunları, cümle kurma, dil bilgisi ve hikâyeler.',
                style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
              ),
              const SizedBox(height: AppSpacing.md),
              const PracticeScreen(compact: true),
            ],
          );
        },
      );
}

class _ProgressData {
  const _ProgressData({
    required this.stories,
    required this.readStoryIds,
    required this.savedWords,
    required this.practiceSessions,
  });

  final List<Story> stories;
  final Set<String> readStoryIds;
  final int savedWords;
  final int practiceSessions;

  int get readStoryCount =>
      readStoryIds.intersection(stories.map((story) => story.id).toSet()).length;
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
            style: AppTypography.displayXs.copyWith(
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
