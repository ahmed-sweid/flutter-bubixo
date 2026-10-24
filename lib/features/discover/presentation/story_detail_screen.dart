import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/story.dart';
import 'cubit/story_vocabulary_cubit.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({required this.story, super.key});

  final Story story;

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final Set<int> _revealedTranslations = <int>{};

  @override
  void initState() {
    super.initState();
    _rememberStory();
  }

  Future<void> _rememberStory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('bubixo.last_story_id', widget.story.id);
    await preferences.setString('bubixo.last_story_title', widget.story.title);
  }

  @override
  void dispose() {
    unawaited(SpeechService.instance.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return BlocProvider(
      create: (_) => StoryVocabularyCubit(),
      child: BlocListener<StoryVocabularyCubit, StoryVocabularyState>(
        listenWhen: (previous, current) =>
            previous.saveCount != current.saveCount ||
            current.status == StoryVocabularyStatus.failure,
        listener: (context, state) {
          final message = state.status == StoryVocabularyStatus.failure
              ? state.errorMessage
              : '${state.lastSavedEnglish} kaydedilen kelimelere eklendi';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message ?? '')));
        },
        child: Scaffold(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.titleTr, style: AppTypography.displayXs),
                    const SizedBox(height: AppSpacing.sm),
                    Text(story.intro, style: AppTypography.bodyMd),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text('Hikâye', style: AppTypography.displayXs),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_revealedTranslations.length ==
                            story.lines.length) {
                          _revealedTranslations.clear();
                        } else {
                          _revealedTranslations
                            ..clear()
                            ..addAll(
                              List<int>.generate(
                                story.lines.length,
                                (index) => index,
                              ),
                            );
                        }
                      });
                    },
                    icon: Icon(
                      _revealedTranslations.length == story.lines.length
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                      size: 17,
                    ),
                    label: Text(
                      _revealedTranslations.length == story.lines.length
                          ? 'Çevirileri gizle'
                          : 'Tüm çevirileri göster',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...story.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Material(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        final index = story.lines.indexOf(line);
                        setState(() {
                          if (!_revealedTranslations.add(index)) {
                            _revealedTranslations.remove(index);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.hairline),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    line.en,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'İngilizce cümleyi dinle',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => unawaited(
                                    SpeechService.instance.speakEnglish(
                                      line.en,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Iconsax.volume_high,
                                    color: AppColors.bodyMid,
                                    size: 21,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _revealedTranslations.contains(
                                          story.lines.indexOf(line),
                                        )
                                        ? line.tr
                                        : 'Türkçe anlamı görmek için dokun',
                                    style: AppTypography.bodySm.copyWith(
                                      color:
                                          _revealedTranslations.contains(
                                            story.lines.indexOf(line),
                                          )
                                          ? AppColors.body
                                          : AppColors.bodyMid,
                                      fontStyle:
                                          _revealedTranslations.contains(
                                            story.lines.indexOf(line),
                                          )
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _revealedTranslations.contains(
                                        story.lines.indexOf(line),
                                      )
                                      ? Iconsax.eye
                                      : Iconsax.eye_slash,
                                  size: 18,
                                  color: AppColors.bodyMid,
                                ),
                              ],
                            ),
                            if (line.words.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: line.words
                                    .map(
                                      (word) => InkWell(
                                        borderRadius: BorderRadius.circular(6),
                                        onTap: () {
                                          unawaited(
                                            context
                                                .read<StoryVocabularyCubit>()
                                                .saveWord(
                                                  english: word.english,
                                                  turkish: word.turkish,
                                                ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.hairline
                                                .withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            '${word.english} · ${word.turkish}',
                                            style: AppTypography.eyebrowSmall,
                                          ),
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
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hikâyenin sonuna geldin.',
                style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.arrow_left_2, size: 18),
                  label: const Text('Hikâyelere dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
