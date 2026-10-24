import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/content_database.dart';
import 'lesson.dart';

class LessonRepository {
  const LessonRepository({this.database});

  /// Reads from the seeded database when one is available; bundled JSON is the
  /// fallback for platforms and failures without it.
  final AppDatabase? database;

  Future<List<Lesson>> loadLessons() async {
    final resolved = await resolveContentDatabase(database);
    if (resolved != null) {
      try {
        final lessons = await _loadFromDatabase(resolved);
        if (lessons.isNotEmpty) return lessons;
      } catch (_) {
        // Fall through to the bundled dataset.
      }
    }
    return _loadFromAssets();
  }

  Future<List<Lesson>> _loadFromDatabase(AppDatabase database) async {
    final headers = await database
        .customSelect(
          'SELECT id, title, minutes, intro, tip FROM lessons '
          'WHERE is_active = 1 ORDER BY rowid',
        )
        .get();
    final points = await database
        .customSelect(
          'SELECT lesson_id, english, turkish FROM lesson_points '
          'WHERE is_active = 1 ORDER BY lesson_id, position',
        )
        .get();
    final quizzes = await database
        .customSelect(
          'SELECT lesson_id, question, options_json, answer_index, explanation '
          'FROM lesson_quizzes WHERE is_active = 1 '
          'ORDER BY lesson_id, position',
        )
        .get();

    final pointsByLesson = <String, List<LessonPoint>>{};
    for (final row in points) {
      (pointsByLesson[row.read<String>('lesson_id')] ??= <LessonPoint>[]).add(
        LessonPoint(
          english: row.read<String>('english'),
          turkish: row.read<String>('turkish'),
        ),
      );
    }

    final quizzesByLesson = <String, List<LessonQuiz>>{};
    for (final row in quizzes) {
      (quizzesByLesson[row.read<String>('lesson_id')] ??= <LessonQuiz>[]).add(
        LessonQuiz(
          question: row.read<String>('question'),
          options: decodeStringList(row.read<Object?>('options_json')),
          answerIndex: row.read<int>('answer_index'),
          explanation: row.read<String>('explanation'),
        ),
      );
    }

    return headers
        .map(
          (row) => Lesson(
            id: row.read<String>('id'),
            title: row.read<String>('title'),
            minutes: row.read<int>('minutes'),
            intro: row.read<String>('intro'),
            tip: row.read<String>('tip'),
            points: pointsByLesson[row.read<String>('id')] ?? const [],
            quizzes: quizzesByLesson[row.read<String>('id')] ?? const [],
          ),
        )
        .where((lesson) => lesson.quizzes.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Lesson>> _loadFromAssets() async {
    final source = await rootBundle.loadString('assets/data/lessons.json');
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException(
        'Ders dosyasının üst düzey yapısı liste olmalı.',
      );
    }

    return decoded
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Ders listesinde geçersiz kayıt bulundu.',
            );
          }
          return Lesson.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }
}
