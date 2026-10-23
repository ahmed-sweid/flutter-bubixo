import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../../core/services/speech_service.dart';

/// Vocabulary UI uses examples from the original Bubixo data2.js source.
/// Saved and review lists are stored locally on the device.
class WordsScreen extends StatefulWidget {
  const WordsScreen({super.key});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> {
  final TextEditingController _translationController = TextEditingController();
  String? _translationResult;
  String? _translationError;
  bool _isTranslating = false;
  String _translationDirection = 'en-tr';
  int _selectedFilter = 0;
  final Set<String> _savedWords = <String>{};
  final Set<String> _reviewWords = <String>{};
  List<_WordEntry> _customWords = <_WordEntry>[];
  List<_WordEntry> _dictionaryWords = <_WordEntry>[];

  @override
  void initState() {
    super.initState();
    _loadWordState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final source = await rootBundle.loadString('assets/data/words.json');
      final decoded = jsonDecode(source);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Expected a list of dictionary entries.');
      }
      final words = decoded.map((item) {
        if (item is! Map<String, dynamic> ||
            item['english'] is! String ||
            item['turkish'] is! String) {
          throw const FormatException('Invalid dictionary entry.');
        }
        return _WordEntry(
          item['english'] as String,
          item['turkish'] as String,
          'Kelime / ifade',
        );
      }).toList(growable: false);
      if (!mounted) return;
      setState(() => _dictionaryWords = words);
    } on FlutterError {
      // Keep the small built-in list available if the asset cannot be loaded.
    } on FormatException {
      // Keep the small built-in list available if the asset is malformed.
    } on TypeError {
      // Keep the small built-in list available if a record has an invalid type.
    }
  }

  String _wordKey(String value) => value.trim().toLowerCase();

  Future<void> _loadWordState() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedWords
        ..clear()
        ..addAll(
          (preferences.getStringList('bubixo.saved_words') ?? const <String>[])
              .map(_wordKey)
              .where((word) => word.isNotEmpty),
        );
      _reviewWords
        ..clear()
        ..addAll(
          (preferences.getStringList('bubixo.review_words') ?? const <String>[])
              .map(_wordKey)
              .where((word) => word.isNotEmpty),
        );
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

  Future<void> _translateText() async {
    final text = _translationController.text.trim();
    if (text.isEmpty || _isTranslating) return;

    final source = _translationDirection == 'en-tr' ? 'en' : 'tr';
    final target = _translationDirection == 'en-tr' ? 'tr' : 'en';
    if (text.length > 300) {
      setState(() {
        _translationResult = null;
        _translationError = 'En fazla 300 karakter çevirebilirsin.';
      });
      return;
    }

    setState(() {
      _isTranslating = true;
      _translationResult = null;
      _translationError = null;
    });

    try {
      final tokenResponse = await http
          .post(
            Uri.parse('https://api.bubixo.com/text-tools/token'),
            headers: const {
              'Content-Type': 'application/json',
              // Match the trusted web client origin used by Bubixo's text-tools API.
              'Origin': 'https://bubixo.com',
              'Referer': 'https://bubixo.com/',
            },
          )
          .timeout(const Duration(seconds: 12));
      if (tokenResponse.statusCode < 200 || tokenResponse.statusCode >= 300) {
        throw _TranslationException(
          'Çeviri servisi token isteğini reddetti (HTTP ${tokenResponse.statusCode}).',
        );
      }

      final tokenData = jsonDecode(tokenResponse.body);
      if (tokenData is! Map<String, dynamic> || tokenData['token'] is! String) {
        throw const _TranslationException('Çeviri servisi geçerli yanıt vermedi.');
      }

      final response = await http
          .post(
            Uri.parse('https://api.bubixo.com/text-tools/translate'),
            headers: {
              'Content-Type': 'application/json',
              'Origin': 'https://bubixo.com',
              'Referer': 'https://bubixo.com/',
              'X-Text-Tools-Token': tokenData['token'] as String,
            },
            body: jsonEncode({'text': text, 'source': source, 'target': target}),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 429) {
        throw const _TranslationException('Çok sık istek gönderildi. Biraz sonra tekrar dene.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _TranslationException(
          'Çeviri isteği başarısız oldu (HTTP ${response.statusCode}). Biraz sonra tekrar dene.',
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> ||
          data['success'] != true ||
          data['translation'] is! String ||
          (data['translation'] as String).trim().isEmpty) {
        throw const _TranslationException('Çeviri servisinden geçerli bir sonuç alınamadı.');
      }

      if (!mounted) return;
      setState(() => _translationResult = (data['translation'] as String).trim());
    } on _TranslationException catch (error) {
      if (!mounted) return;
      setState(() => _translationError = error.message);
    } on http.ClientException {
      if (!mounted) return;
      setState(() => _translationError = 'Bağlantı kurulamadı. İnternetini kontrol et.');
    } on FormatException {
      if (!mounted) return;
      setState(() => _translationError = 'Çeviri servisinden beklenmeyen yanıt alındı.');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _translationError = 'Çeviri zaman aşımına uğradı. Tekrar dene.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _translationError = 'Çeviri sırasında bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _persistWordState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('bubixo.saved_words', _savedWords.toList()..sort());
    await preferences.setStringList('bubixo.review_words', _reviewWords.toList()..sort());
    await preferences.setString(
      'bubixo.custom_words',
      jsonEncode(
        _customWords
            .map((word) => {
                  'english': word.english,
                  'turkish': word.turkish,
                  'kind': word.kind,
                })
            .toList(),
      ),
    );
  }

  bool get _currentTranslationSaved {
    final result = _translationResult?.trim();
    final input = _translationController.text.trim();
    if (result == null || result.isEmpty || input.isEmpty) return false;
    final english = _translationDirection == 'en-tr' ? input : result;
    final turkish = _translationDirection == 'en-tr' ? result : input;
    return _customWords.any(
      (word) =>
          _wordKey(word.english) == _wordKey(english) &&
          _wordKey(word.turkish) == _wordKey(turkish),
    );
  }

  Future<void> _saveTranslationToWords() async {
    final result = _translationResult?.trim();
    final input = _translationController.text.trim();
    if (result == null || result.isEmpty || input.isEmpty || _currentTranslationSaved) {
      return;
    }

    final english = _translationDirection == 'en-tr' ? input : result;
    final turkish = _translationDirection == 'en-tr' ? result : input;
    setState(() {
      _customWords = _customWords
          .where((word) => _wordKey(word.english) != _wordKey(english))
          .toList(growable: true);
      _customWords.insert(0, _WordEntry(english, turkish, 'Çeviri'));
      _savedWords.add(_wordKey(english));
    });
    await _persistWordState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kelime listenin içine kaydedildi.')),
    );
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
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Story-derived entries can overlap the starter dictionary. Keep one
    // card per English expression and prefer the story's more specific gloss.
    final wordsByKey = <String, _WordEntry>{
      for (final word in (_dictionaryWords.isEmpty ? _words : _dictionaryWords))
        word.english.toLowerCase(): word,
      for (final word in _customWords) word.english.toLowerCase(): word,
    };
    final allWords = wordsByKey.values.toList(growable: false);
    final visibleWords = allWords.where((word) {
      return _selectedFilter == 0 ||
          (_selectedFilter == 1 && _savedWords.contains(_wordKey(word.english))) ||
          (_selectedFilter == 2 && _reviewWords.contains(_wordKey(word.english)));
    }).toList(growable: false);

    return ListView(
      key: const PageStorageKey<String>('words-screen-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _WordTranslatorCard(
          controller: _translationController,
          result: _translationResult,
          error: _translationError,
          isTranslating: _isTranslating,
          direction: _translationDirection,
          translationSaved: _currentTranslationSaved,
          onSaveTranslation: _saveTranslationToWords,
          onDirectionChanged: (direction) {
            setState(() {
              _translationDirection = direction;
              _translationResult = null;
              _translationError = null;
            });
          },
          onTranslate: _translateText,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _FilterPill(
              label: 'Tüm kelimeler',
              count: allWords.length,
              selected: _selectedFilter == 0,
              onTap: () => setState(() => _selectedFilter = 0),
            ),
            _FilterPill(
              label: 'Kaydedilenler',
              count: _savedWords.length,
              selected: _selectedFilter == 1,
              onTap: () => setState(() => _selectedFilter = 1),
            ),
            _FilterPill(
              label: 'Tekrar',
              count: _reviewWords.length,
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
            onShowAll: () => setState(() => _selectedFilter = 0),
          )
        else
          ...visibleWords.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _WordCard(
                word: word,
                saved: _savedWords.contains(_wordKey(word.english)),
                reviewing: _reviewWords.contains(_wordKey(word.english)),
                onToggleSaved: () async {
                  final key = _wordKey(word.english);
                  setState(() {
                    if (!_savedWords.add(key)) {
                      _savedWords.remove(key);
                    }
                  });
                  await _persistWordState();
                },
                onToggleReview: () async {
                  final key = _wordKey(word.english);
                  setState(() {
                    if (!_reviewWords.add(key)) {
                      _reviewWords.remove(key);
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

class _TranslationException implements Exception {
  const _TranslationException(this.message);
  final String message;
}

class _WordTranslatorCard extends StatelessWidget {
  const _WordTranslatorCard({
    required this.controller,
    required this.result,
    required this.error,
    required this.isTranslating,
    required this.direction,
    required this.translationSaved,
    required this.onSaveTranslation,
    required this.onDirectionChanged,
    required this.onTranslate,
  });

  final TextEditingController controller;
  final String? result;
  final String? error;
  final bool isTranslating;
  final String direction;
  final bool translationSaved;
  final VoidCallback onSaveTranslation;
  final ValueChanged<String> onDirectionChanged;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    final englishToTurkish = direction == 'en-tr';
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
            children: [
              const Icon(Iconsax.translate, color: AppColors.accentPurple, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Çeviri', style: AppTypography.displayXs),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÇEVİRİLECEK DİL',
                        style: AppTypography.eyebrowSmall.copyWith(
                          color: AppColors.muted,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        englishToTurkish ? 'İngilizce' : 'Türkçe',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.canvas,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isTranslating
                        ? null
                        : () => onDirectionChanged(
                              englishToTurkish ? 'tr-en' : 'en-tr',
                            ),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Iconsax.arrow_swap_horizontal,
                        color: AppColors.ink,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ÇEVRİLECEK SONUÇ',
                        textAlign: TextAlign.end,
                        style: AppTypography.eyebrowSmall.copyWith(
                          color: AppColors.muted,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        englishToTurkish ? 'Türkçe' : 'İngilizce',
                        textAlign: TextAlign.end,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            maxLength: 300,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: englishToTurkish
                  ? 'İngilizce kelime veya cümle yaz…'
                  : 'Türkçe kelime veya cümle yaz…',
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              alignLabelWithHint: true,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isTranslating ? null : onTranslate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: isTranslating
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Icon(Iconsax.translate, size: 18),
              label: Text(isTranslating ? 'Çevriliyor…' : 'Metni çevir'),
            ),
          ),
          if (error != null || result != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null) ...[
                    const Icon(
                      Iconsax.info_circle,
                      color: AppColors.accentRed,
                      size: 19,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      error ?? result!,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (result != null && error == null) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: translationSaved ? null : onSaveTranslation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: AppColors.hairline),
                  ),
                  icon: Icon(
                    translationSaved ? Iconsax.tick_circle : Iconsax.bookmark,
                    size: 18,
                  ),
                  label: Text(
                    translationSaved ? 'Kelime listene kaydedildi' : 'Kelime listeme ekle',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.canvas,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                color: selected ? AppColors.onPrimary : AppColors.bodyMid,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.onPrimary.withValues(alpha: 0.14)
                    : AppColors.hairline.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: AppTypography.eyebrowSmall.copyWith(
                  fontSize: 10,
                  color: selected ? AppColors.onPrimary : AppColors.bodyMid,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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

  Widget _buildWordText() {
    return Expanded(
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
    );
  }

  Widget _buildSpeakButton() {
    return IconButton(
      tooltip: 'İngilizce telaffuzu dinle',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      onPressed: () => unawaited(
        SpeechService.instance.speakEnglish(word.english),
      ),
      icon: const Icon(
        Iconsax.volume_high,
        color: AppColors.bodyMid,
        size: 21,
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.hairline),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpeakButton(),
                        const SizedBox(width: AppSpacing.md),
                        _buildWordText(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildActions(),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpeakButton(),
                    const SizedBox(width: AppSpacing.md),
                    _buildWordText(),
                    _buildActions(),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyWordsState extends StatelessWidget {
  const _EmptyWordsState({required this.onShowAll});

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
          const Icon(Iconsax.bookmark, size: 28, color: AppColors.bodyMid),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bu listede henüz kelime yok',
            style: AppTypography.displayXs,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Kelimelerin yanındaki simgeleri kullanarak kaydedebilir veya tekrar listene ekleyebilirsin.',
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
