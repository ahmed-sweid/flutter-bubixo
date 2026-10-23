import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/grammar_repository.dart';
import '../data/grammar_topic.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  final GrammarRepository _repository = const GrammarRepository();
  late Future<List<GrammarTopic>> _topicsFuture = _repository.loadTopics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text('Dil bilgisi', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: FutureBuilder<List<GrammarTopic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.warning_2, size: 30, color: AppColors.bodyMid),
                    const SizedBox(height: AppSpacing.md),
                    Text('Konular yüklenemedi.', style: AppTypography.bodyMd),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => setState(() => _topicsFuture = _repository.loadTopics()),
                      child: const Text('Yeniden dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final topics = snapshot.data ?? const <GrammarTopic>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
            children: [
              Text('Bir konu seç', style: AppTypography.displaySm),
              const SizedBox(height: AppSpacing.xs),
              Text('Kısa anlatımı oku, örnekleri incele ve mini testle pekiştir.', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
              const SizedBox(height: AppSpacing.lg),
              ...topics.asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Material(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GrammarTopicScreen(topics: topics, topicIndex: index),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.hairline),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(topic.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text('${topic.examples.length} örnek · ${topic.quizzes.length} test sorusu', style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                                ],
                              ),
                            ),
                            const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.bodyMid),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class GrammarTopicScreen extends StatefulWidget {
  const GrammarTopicScreen({required this.topics, required this.topicIndex, super.key});

  final List<GrammarTopic> topics;
  final int topicIndex;

  @override
  State<GrammarTopicScreen> createState() => _GrammarTopicScreenState();
}

class _GrammarTopicScreenState extends State<GrammarTopicScreen> {
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;

  GrammarTopic get _topic => widget.topics[widget.topicIndex];
  GrammarQuiz get _question => _topic.quizzes[_questionIndex];

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _question.answerIndex) _score++;
    });
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= _topic.quizzes.length) {
      setState(() {
        _questionIndex = _topic.quizzes.length;
      });
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedOption = null;
      _answered = false;
    });
  }

  void _restartQuiz() {
    setState(() {
      _questionIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizComplete = _questionIndex >= _topic.quizzes.length;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text(_topic.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_topic.badge, style: AppTypography.eyebrowSmall.copyWith(color: AppColors.accentPurple)),
                const SizedBox(height: AppSpacing.sm),
                Text(_topic.formula, style: AppTypography.bodyMd.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Ne zaman kullanılır?', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.xs),
          Text(_topic.explanation, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xl),
          Text('Örnekler', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          ..._topic.examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(example.english, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(example.turkish, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                ],
              ),
            ),
          )),
          const SizedBox(height: AppSpacing.xl),
          Text('Mini test', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          if (quizComplete)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  const Icon(Iconsax.medal_star, size: 34, color: AppColors.accentBlueDeep),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Test tamamlandı', style: AppTypography.displayXs),
                  const SizedBox(height: AppSpacing.xs),
                  Text('$_score / ${_topic.quizzes.length} doğru cevap', style: AppTypography.bodyMd),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(onPressed: _restartQuiz, icon: const Icon(Iconsax.refresh), label: const Text('Tekrar çöz')),
                  if (widget.topicIndex + 1 < widget.topics.length)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => GrammarTopicScreen(topics: widget.topics, topicIndex: widget.topicIndex + 1),
                        ),
                      ),
                      child: const Text('Sonraki konu'),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: const Color(0xFFF7F7F8), borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Soru ${_questionIndex + 1} / ${_topic.quizzes.length}', style: AppTypography.eyebrowSmall.copyWith(color: AppColors.bodyMid)),
                  const SizedBox(height: AppSpacing.md),
                  Text(_question.question, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  ..._question.options.asMap().entries.map((entry) {
                    final selected = _selectedOption == entry.key;
                    final correct = entry.key == _question.answerIndex;
                    final Color background = !_answered
                        ? AppColors.canvas
                        : correct
                            ? const Color(0xFFE8F5E9)
                            : selected
                                ? const Color(0xFFFFEBEE)
                                : AppColors.canvas;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Material(
                        color: background,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _selectOption(entry.key),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(10)),
                            child: Text(entry.value, style: AppTypography.bodySm.copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_answered) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_question.explanation, style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(onPressed: _nextQuestion, child: Text(_questionIndex + 1 == _topic.quizzes.length ? 'Sonucu gör' : 'Sonraki soru')),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
