import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../discover/data/story_repository.dart';

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
      totalStories: stories.length,
      readStoryIds:
          (preferences.getStringList('bubixo.read_story_ids') ?? const <String>[])
              .toSet(),
      savedWords: preferences.getStringList('bubixo.saved_words')?.length ?? 0,
      practiceSessions: preferences.getInt('bubixo.practice.sessions') ?? 0,
    );
  }

  void _retryLoading() {
    setState(() {
      _future = _loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProgressData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ListView(
          key: const PageStorageKey<String>('learn-screen-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            Text(
              'BUBIXO',
              style: AppTypography.eyebrowSmall.copyWith(
                color: AppColors.bodyMid,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'İngilizce yolculuğun',
              style: AppTypography.displaySm.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Gelişimini takip et ve kendi hızında ilerle.',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Küçük adımlar, kalıcı ilerleme.',
                          style: AppTypography.displayXs.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Her kelime, okuma ve alıştırma İngilizceni biraz daha geliştirir.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.mutedSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Iconsax.chart_2,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Genel bakış',
              style: AppTypography.displayXs.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Şimdiye kadarki ilerlemen',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            ),
            const SizedBox(height: AppSpacing.md),
            if (snapshot.connectionState == ConnectionState.waiting &&
                data == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError || data == null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlerlemen şu anda yüklenemedi.',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: _retryLoading,
                        child: const Text('Yeniden dene'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Iconsax.bookmark_2,
                      label: 'Kelime',
                      value: '${data.savedWords}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: Iconsax.book_1,
                      label: 'Hikâye',
                      value: '${data.readStoryCount} / ${data.totalStories}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      icon: Iconsax.flash_1,
                      label: 'Oturum',
                      value: '${data.practiceSessions}',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    size: 20,
                    color: AppColors.bodyMid,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kendi ritmini bul',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Kelimelerini gözden geçir, bir hikâye oku veya kısa alıştırmalarla devam et. Sana uygun olan yolu seç.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.bodyMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressData {
  const _ProgressData({
    required this.totalStories,
    required this.readStoryIds,
    required this.savedWords,
    required this.practiceSessions,
  });

  final int totalStories;
  final Set<String> readStoryIds;
  final int savedWords;
  final int practiceSessions;

  int get readStoryCount => readStoryIds.length.clamp(0, totalStories).toInt();
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.bodyMid),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
