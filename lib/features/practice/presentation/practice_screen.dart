import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../discover/presentation/discover_screen.dart';
import '../data/builder_exercises.dart';
import '../data/game_words.dart';
import '../data/practice_data_repository.dart';
import 'grammar_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late Future<Map<String, int>> _progressFuture = _loadProgress();
  final PracticeDataRepository _repository = const PracticeDataRepository();

  Future<Map<String, int>> _loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    return {
      'sessions': preferences.getInt('bubixo.practice.sessions') ?? 0,
      'correct': preferences.getInt('bubixo.practice.correct_answers') ?? 0,
    };
  }

  Future<void> _open(_ActivityMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('bubixo.last_activity_type', 'practice');
    await preferences.setString('bubixo.last_activity_id', mode.toString());
    final data = await _repository.loadAll();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PracticeActivityScreen(mode: mode, exercises: data.exercises, gameWords: data.words),
      ),
    );
    if (mounted) {
      setState(() {
        _progressFuture = _loadProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('practice-screen-scroll'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl),
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hazır olduğunda başla', style: AppTypography.displayXs.copyWith(color: AppColors.onPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text('Gerçek kaynak alıştırmalarıyla kendi hızında ilerle.', style: AppTypography.bodySm.copyWith(color: AppColors.mutedSoft)),
            ])),
            const SizedBox(width: AppSpacing.md),
            const Icon(Iconsax.flash_1, color: AppColors.onPrimary, size: 30),
          ]),
        ),
        const SizedBox(height: AppSpacing.lg),
        FutureBuilder<Map<String, int>>(
          future: _progressFuture,
          builder: (context, snapshot) {
            final progress = snapshot.data;
            if (progress == null || (progress['sessions'] == 0 && progress['correct'] == 0)) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.chart_2, color: AppColors.bodyMid, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İlerlemen', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${progress['sessions']} tamamlanan oturum · ${progress['correct']} doğru cevap',
                          style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Alıştırma türleri', style: AppTypography.displayXs),
        const SizedBox(height: AppSpacing.md),
        _PracticeCard(
          icon: Iconsax.text_block,
          title: 'Cümle kurma', subtitle: 'Türkçe cümleden doğru İngilizce sırasını oluştur.',
          meta: '120 alıştırma · 3 seviye',
          onTap: () => _open(const _ActivityMode.sentence()),
        ),
        const SizedBox(height: AppSpacing.md),
        _PracticeCard(
          icon: Iconsax.category_2,
          title: 'Kelime oyunları', subtitle: 'İngilizce kelimeyi doğru Türkçe anlamıyla eşleştir.',
          meta: '240 kelime · 12 tema',
          onTap: () => _open(const _ActivityMode.words()),
        ),
        const SizedBox(height: AppSpacing.md),
        _PracticeCard(
          icon: Iconsax.book_1,
          title: 'Dil bilgisi', subtitle: 'Geniş zaman, geçmiş ve gelecek konularını örneklerle incele.',
          meta: '90 konu örneği',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const GrammarScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PracticeCard(
          icon: Iconsax.book_1,
          title: 'Hikâyeler',
          subtitle: 'Kısa hikâyeler oku; İngilizce cümleleri ve Türkçe anlamlarını birlikte incele.',
          meta: '3 seviye · İngilizce ve Türkçe',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                backgroundColor: AppColors.canvas,
                appBar: AppBar(
                  backgroundColor: AppColors.canvas,
                  surfaceTintColor: AppColors.transparent,
                  title: Text(
                    'Hikâyeler',
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                  ),
                  leading: IconButton(
                    tooltip: 'Geri',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Iconsax.arrow_left_2),
                  ),
                ),
                body: const SafeArea(
                  top: false,
                  child: DiscoverScreen(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Iconsax.info_circle, size: 19, color: AppColors.bodyMid),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('Alıştırmalar Bubixo’nun kaynak soru ve kelime havuzlarından aktarılmıştır. Tamamlanan oturumlar ve doğru cevapların bu cihazda saklanır.', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid))),
          ]),
        ),
      ],
    );
  }

}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.icon, required this.title, required this.subtitle, required this.meta, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.canvas,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.bodyMid, size: 21)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
            const SizedBox(height: 7),
            Text(meta.toUpperCase(), style: AppTypography.eyebrowSmall.copyWith(color: AppColors.muted, fontSize: 10)),
          ])),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
        ]),
      ),
    ),
  );
}

enum _ActivityKind { sentence, words, grammar }

class _ActivityMode {
  const _ActivityMode.sentence() : kind = _ActivityKind.sentence, title = 'Cümle kurma';
  const _ActivityMode.words() : kind = _ActivityKind.words, title = 'Kelime oyunları';
  final _ActivityKind kind;
  final String title;
}

class _PracticeActivityScreen extends StatefulWidget {
  const _PracticeActivityScreen({required this.mode, required this.exercises, required this.gameWords});
  final _ActivityMode mode;
  final List<BuilderExercise> exercises;
  final List<GameWord> gameWords;
  @override
  State<_PracticeActivityScreen> createState() => _PracticeActivityScreenState();
}

class _PracticeActivityScreenState extends State<_PracticeActivityScreen> {
  final _random = Random();
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _checked = false;
  late List<int> _questionOrder;
  late List<String> _tiles;
  final List<String> _answer = [];

  bool get _sentenceMode => widget.mode.kind == _ActivityKind.sentence;
  bool get _wordMode => widget.mode.kind == _ActivityKind.words;
  int get _total => _wordMode ? widget.gameWords.length : _exercises.length;
  List<BuilderExercise> get _exercises => widget.mode.kind == _ActivityKind.grammar
      ? widget.exercises.where((e) => e.category != 'question').toList()
      : widget.exercises;
  BuilderExercise get _exercise => _exercises[_questionOrder[_index]];
  GameWord get _word => widget.gameWords[_questionOrder[_index]];

  @override
  void initState() {
    super.initState();
    _questionOrder = List<int>.generate(_total, (i) => i)..shuffle(_random);
    _prepareQuestion();
  }

  void _prepareQuestion() {
    _selected = null;
    _checked = false;
    _currentWordOptions = [];
    _answer.clear();
    if (_sentenceMode) {
      final exercise = _exercise;
      _tiles = [...exercise.english.split(' '), ...exercise.distractors]..shuffle(_random);
    } else if (_wordMode) {
      _tiles = [];
    } else {
      _tiles = [];
    }
  }

  void _check() {
    if (_checked) return;
    final correct = _sentenceMode
        ? _answer.join(' ').toLowerCase() == _exercise.english.toLowerCase()
        : _selected != null && _currentWordOptions[_selected!] == _word.turkish;
    setState(() {
      _checked = true;
      if (correct) _score++;
    });
  }

  List<String> get _wordOptions {
    final correct = _word.turkish;
    final others = widget.gameWords.where((w) => w.turkish != correct).map((w) => w.turkish).toSet().toList()..shuffle(_random);
    final options = <String>[correct, ...others.take(3)]..shuffle(_random);
    return options;
  }

  late List<String> _currentWordOptions = [];

  @override
  Widget build(BuildContext context) {
    if (_index >= _total) return _completion();
    final exercise = _wordMode ? null : _exercise;
    if (_wordMode && _currentWordOptions.isEmpty) _currentWordOptions = _wordOptions;
    final isCorrect = widget.mode.kind == _ActivityKind.grammar
        ? _checked
        : _sentenceMode
            ? _answer.join(' ').toLowerCase() == exercise!.english.toLowerCase()
            : _selected != null && _currentWordOptions[_selected!] == _word.turkish;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text(widget.mode.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(tooltip: 'Geri', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Iconsax.arrow_left_2)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (_index + 1) / _total, minHeight: 5, backgroundColor: const Color(0xFFEAEAEA), valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple)))),
              const SizedBox(width: AppSpacing.md),
              Text('${_index + 1} / $_total', style: AppTypography.eyebrowSmall),
            ]),
            const SizedBox(height: AppSpacing.xl),
            Text(_wordMode ? 'Kelimeyi anlamıyla eşleştir' : widget.mode.kind == _ActivityKind.grammar ? 'Dil bilgisi · Seviye ${exercise!.level}' : 'Seviye ${exercise!.level} · ${_categoryLabel(exercise.category)}', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                if (_wordMode) ...[
                  Text(_word.english, textAlign: TextAlign.center, style: AppTypography.displaySm),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Hangi Türkçe anlam doğru?', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                ] else ...[
                  Text(exercise!.turkish, textAlign: TextAlign.center, style: AppTypography.displayXs),
                  if (_sentenceMode) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Kelimelere dokunarak İngilizce cümleyi oluştur.', textAlign: TextAlign.center, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                  ] else ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(exercise.english, textAlign: TextAlign.center, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Cümleyi ve kuralı incele, ardından devam et.', textAlign: TextAlign.center, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                  ],
                ],
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_sentenceMode) ...[
              Text('Cümlen', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(minHeight: 70),
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(12)),
                child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _answer.isEmpty
                    ? [
                        Text(
                          'Kelimeleri aşağıdan seç',
                          style: AppTypography.bodySm.copyWith(color: AppColors.muted),
                        ),
                      ]
                    : _answer.asMap().entries.map((entry) {
                        return ActionChip(
                          label: Text(entry.value),
                          onPressed: _checked
                              ? null
                              : () => setState(() {
                                    _tiles.add(entry.value);
                                    _answer.removeAt(entry.key);
                                  }),
                        );
                      }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tiles.map((tile) {
                return ActionChip(
                  label: Text(tile),
                  onPressed: _checked
                      ? null
                      : () => setState(() {
                            _answer.add(tile);
                            _tiles.remove(tile);
                          }),
                );
              }).toList(),
            ),
            ] else if (_wordMode) ...[
              ...List.generate(_currentWordOptions.length, (i) => _option(_currentWordOptions[i], i, isCorrect)),
            ] else ...[
              Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(12)), child: Text(exercise!.note, style: AppTypography.bodyMd)),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_checked) Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: isCorrect ? const Color(0xFFF0FFF3) : const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(isCorrect ? Iconsax.tick_circle : Iconsax.info_circle, color: isCorrect ? AppColors.accentGreen : AppColors.accentOrange),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(_wordMode ? (isCorrect ? 'Doğru: ${_word.turkish}' : 'Doğru cevap: ${_word.turkish}') : _sentenceMode ? (isCorrect ? exercise!.note : 'Doğru cevap: ${exercise!.english}. ${exercise.note}') : exercise!.note, style: AppTypography.bodySm)),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!_checked)
              FilledButton(onPressed: _sentenceMode ? (_answer.isEmpty ? null : _check) : _wordMode ? (_selected == null ? null : _check) : () => setState(() => _checked = true), child: Text(_sentenceMode ? 'Cümleyi kontrol et' : _wordMode ? 'Cevabı kontrol et' : 'Anladım')),
            if (_checked)
              FilledButton(onPressed: _next, child: Text(_index + 1 == _total ? 'Sonuçları gör' : 'Sonraki alıştırma')),
          ],
        ),
      ),
    );
  }

  Widget _option(String label, int index, bool isCorrect) {
    final selected = _selected == index;
    final correct = _checked && label == _word.turkish;
    final wrong = _checked && selected && !correct;
    final color = correct ? AppColors.accentGreen : wrong ? AppColors.accentRed : selected ? AppColors.accentPurple : AppColors.hairline;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: _checked ? null : () => setState(() => _selected = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(border: Border.all(color: color, width: selected || correct ? 1.5 : 1), borderRadius: BorderRadius.circular(12), color: correct ? const Color(0xFFF0FFF3) : wrong ? const Color(0xFFFFF1F2) : AppColors.canvas),
          child: Row(children: [Expanded(child: Text(label, style: AppTypography.bodyMd)), if (correct) const Icon(Iconsax.tick_circle, color: AppColors.accentGreen) else if (wrong) const Icon(Iconsax.close_circle, color: AppColors.accentRed) else Icon(selected ? Iconsax.radio : Iconsax.record, color: selected ? AppColors.accentPurple : AppColors.muted)]),
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_index + 1 >= _total) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(
        'bubixo.practice.sessions',
        (preferences.getInt('bubixo.practice.sessions') ?? 0) + 1,
      );
      await preferences.setInt(
        'bubixo.practice.correct_answers',
        (preferences.getInt('bubixo.practice.correct_answers') ?? 0) + _score,
      );
      if (!mounted) return;
      setState(() => _index = _total);
      return;
    }
    setState(() {
      _index++;
      _currentWordOptions = [];
      _prepareQuestion();
    });
  }

  Widget _completion() => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(title: Text('Alıştırma tamamlandı', style: AppTypography.bodyMd), leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Iconsax.arrow_left_2))),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Iconsax.award, size: 64, color: AppColors.accentPurple),
          const SizedBox(height: AppSpacing.lg),
          Text('Güzel ilerleme!', style: AppTypography.displaySm, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.mode.kind == _ActivityKind.grammar
                ? '$_total konu incelendi'
                : '$_score doğru cevap · $_total alıştırma',
            style: AppTypography.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Pratiğe dön'))),
        ]),
      ),
    ),
  );

  String _categoryLabel(String category) => switch (category) {
    'question' => 'Soru cümleleri',
    'present' => 'Geniş zaman',
    'past' => 'Geçmiş zaman',
    'future' => 'Gelecek zaman',
    _ => category,
  };
}
