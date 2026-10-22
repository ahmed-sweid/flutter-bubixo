import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../discover/data/story.dart';
import '../../discover/data/story_repository.dart';
import '../../discover/presentation/story_detail_screen.dart';
import 'lessons_screen.dart';

/// Learning landing screen with a shortcut back to the last opened story.
class LearnScreen extends StatelessWidget {
  const LearnScreen({
    required this.onOpenDiscover,
    required this.onOpenWords,
    required this.onOpenPractice,
    super.key,
  });

  final VoidCallback onOpenDiscover;
  final VoidCallback onOpenWords;
  final VoidCallback onOpenPractice;

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
        Text(
          'Bugün İngilizceye küçük bir adım at.',
          style: AppTypography.displaySm,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bir içerik seç, kendi hızında öğren ve ihtiyaç duyduğun yerde devam et.',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _TodayRecommendationCard(onTap: onOpenDiscover),
        const SizedBox(height: AppSpacing.md),
        const _LastStoryCard(),
        const SizedBox(height: AppSpacing.xl),
        Text('Temel dersler', style: AppTypography.displayXs),
        const SizedBox(height: AppSpacing.md),
        _LearningPathCard(
          icon: Iconsax.teacher,
          title: 'Ders sırasını takip et',
          subtitle: 'Alfabe, tanışma ve temel dil bilgisi konuları.',
          label: 'DERSLER',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const LessonsScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Nasıl öğrenmek istersin?', style: AppTypography.displayXs),
        const SizedBox(height: AppSpacing.md),
        _LearningPathCard(
          icon: Iconsax.book_1,
          title: 'Hikâye okuyarak öğren',
          subtitle: 'Cümleleri İngilizce ve Türkçe birlikte incele.',
          label: 'OKUMA',
          onTap: onOpenDiscover,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LearningPathCard(
          icon: Iconsax.translate,
          title: 'Yeni kelimeler keşfet',
          subtitle: 'Anlamları incele ve tekrar etmek istediklerini kaydet.',
          label: 'KELİME',
          onTap: onOpenWords,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LearningPathCard(
          icon: Iconsax.activity,
          title: 'Öğrendiklerini uygula',
          subtitle: 'Kısa örnek sorularla pratik yap.',
          label: 'PRATİK',
          onTap: onOpenPractice,
        ),
      ],
    );
  }
}

class _TodayRecommendationCard extends StatelessWidget {
  const _TodayRecommendationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.sun_1,
                color: AppColors.accentPurple,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'BUGÜNÜN ÖNERİSİ',
                  style: AppTypography.eyebrowSmall.copyWith(
                    color: AppColors.mutedSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bir hikâyeyle başla',
            style: AppTypography.displayXs.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İngilizceyi cümlelerin içinde keşfet. Sana uygun bir hikâye seçerek okumaya başlayabilirsin.',
            style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hikâyeleri keşfet'),
                  SizedBox(width: AppSpacing.sm),
                  Icon(Iconsax.arrow_right_3, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  const _LearningPathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECFF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.accentPurple, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.eyebrowSmall.copyWith(
                      color: AppColors.muted,
                      fontSize: 10,
                    )),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(title, style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: AppTypography.bodySm.copyWith(
                      color: AppColors.bodyMid,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
            ],
          ),
        ),
      ),
    );
  }
}


class _LastStoryCard extends StatefulWidget {
  const _LastStoryCard();

  @override
  State<_LastStoryCard> createState() => _LastStoryCardState();
}

class _LastStoryCardState extends State<_LastStoryCard> {
  late final Future<Story?> _storyFuture = _loadLastStory();

  Future<Story?> _loadLastStory() async {
    final preferences = await SharedPreferences.getInstance();
    final storyId = preferences.getString('bubixo.last_story_id');
    if (storyId == null || storyId.isEmpty) return null;
    final stories = await const StoryRepository().loadStories();
    for (final story in stories) {
      if (story.id == storyId) return story;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Story?>(
      future: _storyFuture,
      builder: (context, snapshot) {
        final story = snapshot.data;
        if (story == null) return const SizedBox.shrink();
        return Material(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StoryDetailScreen(story: story),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1ECFF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Iconsax.bookmark_2,
                      color: AppColors.accentPurple,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Son hikâyene dön',
                          style: AppTypography.eyebrowSmall.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          story.title,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(story.titleTr, style: AppTypography.bodySm),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
