import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/content_database.dart';
import 'grammar_topic.dart';

class GrammarRepository {
  const GrammarRepository({this.database});

  /// Reads from the seeded database when one is available; bundled JSON is the
  /// fallback for platforms and failures without it.
  final AppDatabase? database;

  Future<List<GrammarTopic>> loadTopics() async {
    final resolved = await resolveContentDatabase(database);
    if (resolved != null) {
      try {
        final topics = await _loadFromDatabase(resolved);
        if (topics.isNotEmpty) return topics;
      } catch (_) {
        // Fall through to the bundled dataset.
      }
    }
    return _loadFromAssets();
  }

  Future<List<GrammarTopic>> _loadFromDatabase(AppDatabase database) async {
    final headers = await database
        .customSelect(
          'SELECT id, title, badge, formula, explanation FROM grammar_topics '
          'WHERE is_active = 1 ORDER BY rowid',
        )
        .get();
    final examples = await database
        .customSelect(
          'SELECT topic_id, english, turkish FROM grammar_examples '
          'WHERE is_active = 1 ORDER BY topic_id, position',
        )
        .get();
    final quizzes = await database
        .customSelect(
          'SELECT topic_id, question, options_json, answer_index, explanation '
          'FROM grammar_quizzes WHERE is_active = 1 '
          'ORDER BY topic_id, position',
        )
        .get();

    final examplesByTopic = <String, List<GrammarExample>>{};
    for (final row in examples) {
      (examplesByTopic[row.read<String>('topic_id')] ??= <GrammarExample>[])
          .add(
            GrammarExample(
              english: row.read<String>('english'),
              turkish: row.read<String>('turkish'),
            ),
          );
    }

    final quizzesByTopic = <String, List<GrammarQuiz>>{};
    for (final row in quizzes) {
      (quizzesByTopic[row.read<String>('topic_id')] ??= <GrammarQuiz>[]).add(
        GrammarQuiz(
          question: row.read<String>('question'),
          options: decodeStringList(row.read<Object?>('options_json')),
          answerIndex: row.read<int>('answer_index'),
          explanation: row.read<String>('explanation'),
        ),
      );
    }

    return headers
        .map(
          (row) => GrammarTopic(
            id: row.read<String>('id'),
            title: row.read<String>('title'),
            badge: row.read<String>('badge'),
            formula: row.read<String>('formula'),
            explanation: row.read<String>('explanation'),
            examples: examplesByTopic[row.read<String>('id')] ?? const [],
            quizzes: quizzesByTopic[row.read<String>('id')] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  Future<List<GrammarTopic>> _loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/data/grammar.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Dil bilgisi verisi beklenen biçimde değil.');
    }
    return decoded
        .map(
          (item) =>
              GrammarTopic.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }
}
