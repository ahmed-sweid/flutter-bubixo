import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../data/lesson.dart';
import '../data/learning_progress_repository.dart';
import '../../../core/services/speech_service.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    required this.lessons,
    required this.lessonIndex,
    super.key,
  });

  final List<Lesson> lessons;
  final int lessonIndex;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _quizIndex = 0;
  int? _selectedAnswer;
  bool _showAnswer = false;
  final LearningProgressRepository _progressRepository = const LearningProgressRepository();

  @override
  void initState() {
    super.initState();
    unawaited(_progressRepository.rememberLesson(_lesson.id));
  }

  @override
  void dispose() {
    unawaited(SpeechService.instance.stop());
    super.dispose();
  }

  Lesson get _lesson => widget.lessons[widget.lessonIndex];
  LessonQuiz get _quiz => _lesson.quizzes[_quizIndex];
  bool get _hasNextQuiz => _quizIndex < _lesson.quizzes.length - 1;
  bool get _hasNextLesson => widget.lessonIndex < widget.lessons.length - 1;

  Future<void> _continue() async {
    if (!_hasNextQuiz) {
      await _progressRepository.markLessonCompleted(_lesson.id);
      if (!mounted) return;
    }
    if (_hasNextQuiz) {
      setState(() {
        _quizIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
      });
      return;
    }

    if (_hasNextLesson) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LessonDetailScreen(
            lessons: widget.lessons,
            lessonIndex: widget.lessonIndex + 1,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _checkAnswer() async {
    if (_showAnswer || _selectedAnswer == null) return;
    final correct = _selectedAnswer == _quiz.answerIndex;
    await _progressRepository.recordQuizAnswer(correct: correct);
    if (!mounted) return;

    // Checking the final quiz answer completes this lesson, even if the learner
    // chooses to return to the lesson list before pressing the next-step button.
    if (!_hasNextQuiz) {
      await _progressRepository.markLessonCompleted(_lesson.id);
      if (!mounted) return;
    }

    setState(() => _showAnswer = true);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    final quiz = _quiz;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text(
          'Ders ${widget.lessonIndex + 1}',
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        key: PageStorageKey<String>('lesson-detail-${lesson.id}'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl,
        ),
        children: [
          Text(lesson.title, style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _Metadata(icon: Iconsax.clock, text: '${lesson.minutes} dakika'),
              _Metadata(icon: Iconsax.book_1, text: '${lesson.points.length} örnek'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Konu özeti', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.sm),
          Text(lesson.intro, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xl),
          Text('Örnekleri incele', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          ...lesson.points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              point.english,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'İngilizce örneği dinle',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => unawaited(
                              SpeechService.instance.speakEnglish(point.english),
                            ),
                            icon: const Icon(
                              Iconsax.volume_high,
                              color: AppColors.bodyMid,
                              size: 21,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(point.turkish, style: AppTypography.bodySm),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.lamp_on, color: AppColors.accentPurple, size: 19),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Öğrenme ipucu', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(lesson.tip, style: AppTypography.bodySm),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Kendini dene', style: AppTypography.displayXs)),
              Text(
                'Soru ${_quizIndex + 1}/${lesson.quizzes.length}',
                style: AppTypography.eyebrowSmall.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(quiz.question, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...quiz.options.asMap().entries.map((entry) {
            final index = entry.key;
            final selected = _selectedAnswer == index;
            final correct = index == quiz.answerIndex;
            final color = _showAnswer && correct
                ? const Color(0xFFE1F5E8)
                : _showAnswer && selected
                    ? const Color(0xFFFCE8E6)
                    : selected
                        ? const Color(0xFFF1ECFF)
                        : AppColors.canvas;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showAnswer ? null : () => setState(() => _selectedAnswer = index),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.accentPurple : AppColors.hairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.value, style: AppTypography.bodyMd)),
                      if (_showAnswer && correct)
                        const Icon(Iconsax.tick_circle, color: Color(0xFF16834A), size: 19),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_showAnswer) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _selectedAnswer == quiz.answerIndex
                  ? 'Doğru! ${quiz.explanation}'
                  : 'Doğru cevap: ${quiz.options[quiz.answerIndex]}. ${quiz.explanation}',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _selectedAnswer = null;
                _showAnswer = false;
              }),
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Tekrar dene'),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _continue,
                icon: Icon(
                  _hasNextQuiz || _hasNextLesson
                      ? Iconsax.arrow_right_3
                      : Iconsax.tick_circle,
                  size: 18,
                ),
                label: Text(
                  _hasNextQuiz
                      ? 'Sonraki soruya geç'
                      : _hasNextLesson
                          ? 'Sonraki derse geç'
                          : 'Ders listesine dön',
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedAnswer == null
                    ? null
                    : _checkAnswer,
                child: const Text('Cevabı kontrol et'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.bodyMid),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: AppTypography.bodySm),
        ],
      );
}
