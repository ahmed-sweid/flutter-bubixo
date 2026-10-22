import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/story.dart';
import '../../practice/presentation/practice_screen.dart';

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

  Future<void> _saveWord(WordMapping word) async {
    final preferences = await SharedPreferences.getInstance();
    final savedWords =
        preferences.getStringList('bubixo.saved_words') ?? <String>[];
    final alreadySaved = savedWords.any(
      (saved) => saved.toLowerCase() == word.english.toLowerCase(),
    );
    if (!alreadySaved) {
      savedWords.add(word.english);
      await preferences.setStringList('bubixo.saved_words', savedWords);
    }

    final entries = <Map<String, dynamic>>[];
    final rawEntries = preferences.getString('bubixo.custom_words');
    if (rawEntries != null && rawEntries.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawEntries);
        if (decoded is List<dynamic>) {
          for (final item in decoded) {
            if (item is Map &&
                item['english'] is String &&
                item['turkish'] is String) {
              entries.add(Map<String, dynamic>.from(item));
            }
          }
        }
      } on FormatException {
        // Recover from invalid local data instead of breaking the reader.
      }
    }

    final hasDefinition = entries.any(
      (entry) =>
          (entry['english'] as String).toLowerCase() ==
          word.english.toLowerCase(),
    );
    if (!hasDefinition) {
      entries.add({
        'english': word.english,
        'turkish': word.turkish,
        'kind': 'Hikâyeden',
      });
    }
    await preferences.setString('bubixo.custom_words', jsonEncode(entries));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            alreadySaved
                ? '${word.english} zaten kaydedilmiş'
                : '${word.english} kaydedilen kelimelere eklendi',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
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
          Text(story.titleTr, style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Text(story.intro, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.book_1, color: AppColors.accentPurple, size: 19),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'OKUMA REHBERİ',
                      style: AppTypography.eyebrowSmall.copyWith(color: AppColors.mutedSoft),
                    ),
                    const Spacer(),
                    Text(
                      'Seviye ${story.level}',
                      style: AppTypography.eyebrowSmall.copyWith(color: AppColors.onPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${story.lines.length} cümleyle İngilizce oku',
                  style: AppTypography.displayXs.copyWith(color: AppColors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Önce İngilizce cümleyi oku, ardından Türkçe anlamına ve kelime notlarına göz at.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Hikâye', style: AppTypography.displayXs),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (_revealedTranslations.length == story.lines.length) {
                      _revealedTranslations.clear();
                    } else {
                      _revealedTranslations
                        ..clear()
                        ..addAll(List<int>.generate(story.lines.length, (index) => index));
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
                    Text(
                      line.en,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _revealedTranslations.contains(story.lines.indexOf(line))
                                ? line.tr
                                : 'Türkçe anlamı görmek için dokun',
                            style: AppTypography.bodySm.copyWith(
                              color: _revealedTranslations.contains(story.lines.indexOf(line))
                                  ? AppColors.body
                                  : AppColors.bodyMid,
                              fontStyle: _revealedTranslations.contains(story.lines.indexOf(line))
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        ),
                        Icon(
                          _revealedTranslations.contains(story.lines.indexOf(line))
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
                                onTap: () => _saveWord(word),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.hairline.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
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
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PracticeScreen(),
                ),
              ),
              icon: const Icon(Iconsax.activity, size: 18),
              label: const Text('Pratik yap'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
    );
  }
}
