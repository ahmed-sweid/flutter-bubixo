import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

/// Vocabulary UI uses examples from the original Bubixo data2.js source.
/// Saved and review lists are stored locally on the device.
class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  final Set<String> _savedWords = <String>{};
  final Set<String> _reviewWords = <String>{};
  List<_WordEntry> _customWords = <_WordEntry>[];

  @override
  void initState() {
    super.initState();
    _loadWordState();
  }

  Future<void> _loadWordState() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedWords
        ..clear()
        ..addAll(preferences.getStringList('bubixo.saved_words') ?? const <String>[]);
      _reviewWords
        ..clear()
        ..addAll(preferences.getStringList('bubixo.review_words') ?? const <String>[]);
      _customWords = _decodeCustomWords(
        preferences.getString('bubixo.custom_words'),
      );
    });
  }

  List<_WordEntry> _decodeCustomWords(String? raw) {
    if (raw == null || raw.isEmpty) return <_WordEntry>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return <_WordEntry>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .where((entry) =>
              entry['english'] is String &&
              entry['turkish'] is String)
          .map(
            (entry) => _WordEntry(
              entry['english'] as String,
              entry['turkish'] as String,
              entry['kind'] is String ? entry['kind'] as String : 'Kelime',
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return <_WordEntry>[];
    } on TypeError {
      return <_WordEntry>[];
    }
  }

  Future<void> _persistWordState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('bubixo.saved_words', _savedWords.toList()..sort());
    await preferences.setStringList('bubixo.review_words', _reviewWords.toList()..sort());
  }

  static const _words = <_WordEntry>[
    _WordEntry('good', 'iyi', 'Sıfat'),
    _WordEntry('work', 'çalışmak; iş', 'Fiil / isim'),
    _WordEntry('explore', 'keşfetmek', 'Fiil'),
    _WordEntry('challenge', 'meydan okumak; zorluk', 'Fiil / isim'),
    _WordEntry('get dressed', 'giyinmek', 'İfade'),
    _WordEntry('where are you from?', 'nerelisin?', 'Günlük ifade'),
    _WordEntry('I do not understand', 'anlamıyorum', 'Günlük ifade'),
    _WordEntry('speak slowly, please', 'yavaş konuşun lütfen', 'Günlük ifade'),
    _WordEntry('communicate', 'iletişim kurmak', 'Fiil'),
    _WordEntry('concentrate', 'odaklanmak', 'Fiil'),
    _WordEntry('confirm', 'onaylamak; doğrulamak', 'Fiil'),
    _WordEntry('discover', 'keşfetmek', 'Fiil'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    // Story-derived entries can overlap the starter dictionary. Keep one
    // card per English expression and prefer the story's more specific gloss.
    final wordsByKey = <String, _WordEntry>{
      for (final word in _words) word.english.toLowerCase(): word,
      for (final word in _customWords) word.english.toLowerCase(): word,
    };
    final allWords = wordsByKey.values.toList(growable: false);
    final visibleWords = allWords.where((word) {
      final matchesQuery = word.english.toLowerCase().contains(query) ||
          word.turkish.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 0 ||
          (_selectedFilter == 1 && _savedWords.contains(word.english)) ||
          (_selectedFilter == 2 && _reviewWords.contains(word.english));
      return matchesQuery && matchesFilter;
    }).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelimeler', style: AppTypography.displaySm),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Kelimeleri keşfet, kaydet ve kendi hızında tekrar et.',
                    style: AppTypography.bodyMd,
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.bookmark_2,
                color: AppColors.onPrimary,
                size: 21,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _WordOverviewCard(
          savedCount: _savedWords.length,
          reviewCount: _reviewWords.length,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'İngilizce veya Türkçe ara',
            prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Aramayı temizle',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Iconsax.close_circle, size: 19),
                  ),
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _FilterPill(
              label: 'Tüm kelimeler',
              selected: _selectedFilter == 0,
              onTap: () => setState(() => _selectedFilter = 0),
            ),
            _FilterPill(
              label: 'Kaydedilenler',
              selected: _selectedFilter == 1,
              onTap: () => setState(() => _selectedFilter = 1),
            ),
            _FilterPill(
              label: 'Tekrar',
              selected: _selectedFilter == 2,
              onTap: () => setState(() => _selectedFilter = 2),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedFilter == 1
                    ? 'Kaydettiğin kelimeler'
                    : _selectedFilter == 2
                        ? 'Tekrar listesi'
                        : 'Sözlükten seçmeler',
                style: AppTypography.displayXs,
              ),
            ),
            Text(
              '${visibleWords.length} kelime',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (visibleWords.isEmpty)
          _EmptyWordsState(
            isSearch: query.isNotEmpty,
            onShowAll: () {
              _searchController.clear();
              setState(() => _selectedFilter = 0);
            },
          )
        else
          ...visibleWords.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _WordCard(
                word: word,
                saved: _savedWords.contains(word.english),
                reviewing: _reviewWords.contains(word.english),
                onToggleSaved: () async {
                  setState(() {
                    if (!_savedWords.add(word.english)) {
                      _savedWords.remove(word.english);
                    }
                  });
                  await _persistWordState();
                },
                onToggleReview: () async {
                  setState(() {
                    if (!_reviewWords.add(word.english)) {
                      _reviewWords.remove(word.english);
                    }
                  });
                  await _persistWordState();
                },
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Kaydettiğin kelimeler ve tekrar listen bu cihazda saklanır.',
          style: AppTypography.bodySm.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _WordEntry {
  const _WordEntry(this.english, this.turkish, this.kind);

  final String english;
  final String turkish;
  final String kind;
}

class _WordOverviewCard extends StatelessWidget {
  const _WordOverviewCard({
    required this.savedCount,
    required this.reviewCount,
  });

  final int savedCount;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.flash_1, color: AppColors.accentPurple, size: 19),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'KELİME ALANIN',
                style: AppTypography.eyebrowSmall.copyWith(
                  color: AppColors.mutedSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kelime listelerin',
            style: AppTypography.displayXs.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kaydettiklerini ve tekrar etmek istediklerini ayrı ayrı yönet.',
            style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _WordCountPill(
                  icon: Iconsax.bookmark_2,
                  label: 'Kaydedilen',
                  count: savedCount,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _WordCountPill(
                  icon: Iconsax.refresh,
                  label: 'Tekrar',
                  count: reviewCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordCountPill extends StatelessWidget {
  const _WordCountPill({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onPrimary, size: 17),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.canvas,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.hairline,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              color: selected ? AppColors.onPrimary : AppColors.bodyMid,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.word,
    required this.saved,
    required this.reviewing,
    required this.onToggleSaved,
    required this.onToggleReview,
  });

  final _WordEntry word;
  final bool saved;
  final bool reviewing;
  final VoidCallback onToggleSaved;
  final VoidCallback onToggleReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.translate,
              color: AppColors.accentPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.english,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(word.turkish, style: AppTypography.bodySm),
                const SizedBox(height: 5),
                Text(
                  word.kind.toUpperCase(),
                  style: AppTypography.eyebrowSmall.copyWith(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: reviewing ? 'Tekrar listesinden çıkar' : 'Tekrar listesine ekle',
            onPressed: onToggleReview,
            icon: Icon(
              reviewing ? Iconsax.refresh_circle : Iconsax.refresh,
              color: reviewing ? AppColors.accentBlueDeep : AppColors.bodyMid,
              size: 20,
            ),
          ),
          IconButton(
            tooltip: saved ? 'Kaydedilenlerden çıkar' : 'Kelimeyi kaydet',
            onPressed: onToggleSaved,
            icon: Icon(
              saved ? Iconsax.bookmark_2 : Iconsax.bookmark,
              color: saved ? AppColors.accentPurple : AppColors.bodyMid,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWordsState extends StatelessWidget {
  const _EmptyWordsState({
    required this.isSearch,
    required this.onShowAll,
  });

  final bool isSearch;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.search_status_1, size: 28, color: AppColors.bodyMid),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearch ? 'Eşleşen kelime bulunamadı' : 'Henüz kelime yok',
            style: AppTypography.displayXs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isSearch
                ? 'Farklı bir kelime veya Türkçe anlam deneyebilirsin.'
                : 'Tüm kelimeler listesine dönerek sözlüğe göz atabilirsin.',
            style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onShowAll, child: const Text('Tüm kelimeleri göster')),
        ],
      ),
    );
  }
}
