import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/database/database_bootstrap.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import 'cubit/learn_cubit.dart';
import 'cubit/learn_state.dart';
import 'lessons_screen.dart';

/// The Learn tab is the starting point for a short, actionable learning session.
/// Other tabs remain the home for their full stories, vocabulary, and practice
/// experiences; this screen recommends a next step and links directly to them.
class LearnScreen extends StatefulWidget {
  const LearnScreen({
    required this.onOpenWords,
    required this.onOpenStories,
    required this.onOpenPractice,
    super.key,
  });

  final VoidCallback onOpenWords;
  final VoidCallback onOpenStories;
  final VoidCallback onOpenPractice;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  _LearningRecommendation _recommendationFor(LearnProgress data) {
    if (data.startedStoryCount == 0) {
      return _LearningRecommendation(
        title: 'Bir hikâyeyle başla',
        description:
            'Kısa bir hikâyeyi bağlam içinde oku. Yeni kelimeleri daha sonra listene ekleyebilirsin.',
        buttonLabel: 'Hikâyeleri keşfet',
        icon: Iconsax.book_1,
        onTap: widget.onOpenStories,
      );
    }

    if (data.savedWords == 0) {
      return _LearningRecommendation(
        title: 'İlk kelimeni kaydet',
        description:
            'Bir kelime ara ya da bir cümleyi çevir; işine yarayan ifadeleri kendi listene ekle.',
        buttonLabel: 'Kelimelere git',
        icon: Iconsax.bookmark_2,
        onTap: widget.onOpenWords,
      );
    }

    if (data.practiceSessions == 0) {
      return _LearningRecommendation(
        title: 'Öğrendiklerini kullan',
        description:
            'İlk kısa alıştırmanı yap ve kelimeleri cümle içinde kullanmayı dene.',
        buttonLabel: 'Pratiğe başla',
        icon: Iconsax.flash_1,
        onTap: widget.onOpenPractice,
      );
    }

    return _LearningRecommendation(
      title: 'Öğrendiklerini pekiştir',
      description:
          'Bir alıştırma daha yap veya yeni bir hikâye okuyarak kelimeleri bağlam içinde gör.',
      buttonLabel: 'Alıştırma seç',
      icon: Iconsax.flash_1,
      onTap: widget.onOpenPractice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LearnCubit(
        databaseProvider: DatabaseBootstrap.isSupportedPlatform
            ? DatabaseBootstrap.initialize
            : null,
      )..load(),
      child: BlocBuilder<LearnCubit, LearnState>(
        builder: (context, state) {
          final data = state.progress;
          final recommendation = _recommendationFor(
            data ?? LearnProgress.empty(),
          );

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
                'Bugün küçük bir adım at. Nereden başlayacağını birlikte seçelim.',
                style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
              ),
              const SizedBox(height: AppSpacing.xl),

              // A short welcome message sets the tone; the next card provides
              // the actual recommended action.
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
                            'Bir hikâye, birkaç kelime veya kısa bir alıştırma bile iyi bir başlangıçtır.',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.mutedSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Iconsax.teacher,
                      color: AppColors.onPrimary,
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Sana önerilen sonraki adım',
                style: AppTypography.displayXs.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _RecommendationCard(recommendation: recommendation),
              const SizedBox(height: AppSpacing.xl),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Öğrenme akışın',
                          style: AppTypography.displayXs.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Dört bölüm, tek bir öğrenme rutini.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.bodyMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _LearningStepCard(
                icon: Iconsax.note_2,
                title: 'Temel dersleri ilerlet',
                description: 'Kısa dersler, örnek cümleler ve mini sınavlar.',
                detail: 'Derslere git',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LessonsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _LearningStepCard(
                icon: Iconsax.book_1,
                title: 'Bağlam içinde öğren',
                description: 'Kısa bir İngilizce hikâye oku.',
                detail: data == null
                    ? 'Hikâyeleri keşfet'
                    : data.startedStoryCount == 0
                    ? 'Henüz hikâye açmadın'
                    : '${data.startedStoryCount} / ${data.totalStories} hikâye açıldı',
                onTap: widget.onOpenStories,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LearningStepCard(
                icon: Iconsax.bookmark_2,
                title: 'Kelimelerini biriktir',
                description: 'Çevir, kaydet ve tekrar etmek için ayır.',
                detail: data == null
                    ? 'Kelime listene git'
                    : '${data.savedWords} kayıtlı kelime',
                onTap: widget.onOpenWords,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LearningStepCard(
                icon: Iconsax.flash_1,
                title: 'Kullanarak pekiştir',
                description: 'Cümle kurma, kelime oyunları veya dil bilgisi.',
                detail: data == null
                    ? 'Alıştırmaları gör'
                    : '${data.practiceSessions} tamamlanan oturum',
                onTap: widget.onOpenPractice,
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Şu ana kadarki ilerlemen',
                style: AppTypography.displayXs.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.status == LearnStatus.loading && data == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == LearnStatus.failure || data == null)
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
                        'İlerleme bilgilerin yüklenemedi. Diğer bölümleri kullanmaya devam edebilirsin.',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.bodyMid,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () => context.read<LearnCubit>().load(),
                          child: const Text('Yeniden dene'),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
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
                        value:
                            '${data.startedStoryCount} / ${data.totalStories}',
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
                if (data.correctAnswers > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.tick_circle,
                          size: 20,
                          color: AppColors.bodyMid,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${data.correctAnswers} doğru cevap verdin. Harika, devam et!',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.bodyMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LearningRecommendation {
  const _LearningRecommendation({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onTap;
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final _LearningRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  recommendation.icon,
                  size: 22,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      recommendation.description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.bodyMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: recommendation.onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Iconsax.arrow_right_3, size: 18),
              label: Text(recommendation.buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningStepCard extends StatelessWidget {
  const _LearningStepCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String detail;
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 21, color: AppColors.ink),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.bodyMid,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detail,
                      style: AppTypography.eyebrowSmall.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.bodyMid,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
      constraints: const BoxConstraints(minHeight: 108),
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
