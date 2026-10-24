import 'dart:convert';

import 'package:flutter/services.dart';

import 'app_database.dart';

const int currentContentSeedVersion = 1;

const Map<String, String> _contentAssets = <String, String>{
  'lessons': 'assets/data/lessons.json',
  'words': 'assets/data/words.json',
  'grammar': 'assets/data/grammar.json',
  'stories': 'assets/data/stories.json',
  'sentence_builder': 'assets/data/sentence_builder.json',
  'game_words': 'assets/data/game_words.json',
};

/// Imports bundled educational content into SQLite in a single transaction.
///
/// The asset JSON remains the editable source of truth. This importer does not
/// overwrite learner progress and can safely be called on every application
/// launch. Bump [currentContentSeedVersion] when a bundled dataset changes.
class ContentSeeder {
  ContentSeeder(
    this.database, {
    AssetBundle? assetBundle,
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AppDatabase database;
  final AssetBundle _assetBundle;

  Future<ContentSeedReport> seedIfNeeded() async {
    // Read and validate all assets before opening a write transaction, so a
    // missing or malformed asset cannot leave partially imported content.
    final rawAssets = await Future.wait<String>(
      _contentAssets.values.map(_assetBundle.loadString),
    );
    final datasets = <String, List<Map<String, dynamic>>>{};
    var index = 0;
    for (final entry in _contentAssets.entries) {
      datasets[entry.key] = _decodeRows(rawAssets[index], entry.value);
      index++;
    }

    if (await _isCurrent(datasets)) {
      return ContentSeedReport(
        skipped: true,
        recordCounts: _recordCounts(datasets),
      );
    }

    final seededAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    await database.transaction(() async {
      await _markExistingContentInactive();

      await _seedLessons(datasets['lessons']!);
      await _seedGrammar(datasets['grammar']!);
      await _seedStories(datasets['stories']!);
      await _seedVocabulary(
        datasets['words']!,
        datasets['stories']!,
      );
      await _seedSentenceExercises(datasets['sentence_builder']!);
      await _seedGameWords(datasets['game_words']!);
      await _seedDatasetVersions(datasets, seededAt);

      await database.customStatement(
        '''
        INSERT INTO learning_stats (
          id, legacy_quiz_attempts, legacy_quiz_correct,
          legacy_practice_sessions, legacy_practice_correct, updated_at
        ) VALUES (1, 0, 0, 0, 0, $seededAt)
        ON CONFLICT(id) DO NOTHING
        ''',
      );
    });

    return ContentSeedReport(
      skipped: false,
      recordCounts: _recordCounts(datasets),
    );
  }

  Future<bool> _isCurrent(
    Map<String, List<Map<String, dynamic>>> datasets,
  ) async {
    final rows = await database.customSelect(
      'SELECT dataset_key, version, record_count FROM content_dataset_versions',
    ).get();
    final stored = <String, ({int version, int count})>{};
    for (final row in rows) {
      stored[row.read<String>('dataset_key')] = (
        version: row.read<int>('version'),
        count: row.read<int>('record_count'),
      );
    }

    return datasets.entries.every((entry) {
      final actual = stored[entry.key];
      return actual != null &&
          actual.version == currentContentSeedVersion &&
          actual.count == entry.value.length;
    });
  }

  List<Map<String, dynamic>> _decodeRows(String raw, String assetPath) {
    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      throw FormatException('Expected a JSON list in $assetPath.');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw FormatException('Expected an object in $assetPath.');
      }
      return Map<String, dynamic>.from(item);
    }).toList(growable: false);
  }

  Map<String, int> _recordCounts(
    Map<String, List<Map<String, dynamic>>> datasets,
  ) =>
      Map<String, int>.unmodifiable({
        for (final entry in datasets.entries) entry.key: entry.value.length,
      });

  Future<void> _markExistingContentInactive() async {
    const statements = <String>[
      'UPDATE lessons SET is_active = 0',
      'UPDATE lesson_points SET is_active = 0',
      'UPDATE lesson_quizzes SET is_active = 0',
      'UPDATE grammar_topics SET is_active = 0',
      'UPDATE grammar_examples SET is_active = 0',
      'UPDATE grammar_quizzes SET is_active = 0',
      'UPDATE stories SET is_active = 0',
      'UPDATE story_lines SET is_active = 0',
      'UPDATE sentence_exercises SET is_active = 0',
      'UPDATE game_words SET is_active = 0',
    ];
    for (final statement in statements) {
      await database.customStatement(statement);
    }
  }

  Future<void> _seedLessons(List<Map<String, dynamic>> rows) async {
    final statements = <_SqlStatement>[];
    for (final lesson in rows) {
      final id = lesson['id'] as String;
      final points = _asList(lesson['points'], 'lessons.points');
      final quizzes = _asList(lesson['quiz'], 'lessons.quiz');
      statements.add(_SqlStatement(
        '''
        INSERT INTO lessons (id, title, minutes, intro, tip, is_active, content_version)
        VALUES (?, ?, ?, ?, ?, 1, $currentContentSeedVersion)
        ON CONFLICT(id) DO UPDATE SET
          title = excluded.title,
          minutes = excluded.minutes,
          intro = excluded.intro,
          tip = excluded.tip,
          is_active = 1,
          content_version = excluded.content_version
        ''',
        <Object?>[
          id,
          lesson['title'] as String,
          lesson['mins'] as int,
          lesson['intro'] as String,
          lesson['tip'] as String,
        ],
      ));

      for (var position = 0; position < points.length; position++) {
        final point = _asMap(points[position], 'lessons.points');
        statements.add(_SqlStatement(
          '''
          INSERT INTO lesson_points (lesson_id, position, english, turkish, is_active)
          VALUES (?, ?, ?, ?, 1)
          ON CONFLICT(lesson_id, position) DO UPDATE SET
            english = excluded.english,
            turkish = excluded.turkish,
            is_active = 1
          ''',
          <Object?>[
            id,
            position,
            point['en'] as String,
            point['tr'] as String,
          ],
        ));
      }

      for (var position = 0; position < quizzes.length; position++) {
        final quiz = _asMap(quizzes[position], 'lessons.quiz');
        final options = _asList(quiz['o'], 'lessons.quiz.options');
        final answerIndex = quiz['a'] as int;
        if (options.length < 2 ||
            options.any((option) => option is! String) ||
            answerIndex < 0 ||
            answerIndex >= options.length) {
          throw FormatException('Invalid answer options for lesson $id quiz $position.');
        }
        statements.add(_SqlStatement(
          '''
          INSERT INTO lesson_quizzes (
            id, lesson_id, position, question, options_json,
            answer_index, explanation, is_active
          ) VALUES (?, ?, ?, ?, ?, ?, ?, 1)
          ON CONFLICT(id) DO UPDATE SET
            question = excluded.question,
            options_json = excluded.options_json,
            answer_index = excluded.answer_index,
            explanation = excluded.explanation,
            is_active = 1
          ''',
          <Object?>[
            _stableId('lq', '$id:$position'),
            id,
            position,
            quiz['q'] as String,
            jsonEncode(options),
            answerIndex,
            quiz['e'] as String,
          ],
        ));
      }
    }
    await _runBatch(statements);
  }

  Future<void> _seedGrammar(List<Map<String, dynamic>> rows) async {
    final statements = <_SqlStatement>[];
    for (final topic in rows) {
      final id = topic['id'] as String;
      final examples = _asList(topic['ex'], 'grammar.ex');
      final quizzes = _asList(topic['quiz'], 'grammar.quiz');

      statements.add(_SqlStatement(
        '''
        INSERT INTO grammar_topics (
          id, title, badge, formula, explanation, is_active, content_version
        ) VALUES (?, ?, ?, ?, ?, 1, $currentContentSeedVersion)
        ON CONFLICT(id) DO UPDATE SET
          title = excluded.title,
          badge = excluded.badge,
          formula = excluded.formula,
          explanation = excluded.explanation,
          is_active = 1,
          content_version = excluded.content_version
        ''',
        <Object?>[
          id,
          topic['title'] as String,
          topic['badge'] as String,
          topic['formula'] as String,
          topic['when'] as String,
        ],
      ));

      for (var position = 0; position < examples.length; position++) {
        final example = _asMap(examples[position], 'grammar.ex');
        statements.add(_SqlStatement(
          '''
          INSERT INTO grammar_examples (topic_id, position, english, turkish, is_active)
          VALUES (?, ?, ?, ?, 1)
          ON CONFLICT(topic_id, position) DO UPDATE SET
            english = excluded.english,
            turkish = excluded.turkish,
            is_active = 1
          ''',
          <Object?>[
            id,
            position,
            example['en'] as String,
            example['tr'] as String,
          ],
        ));
      }

      for (var position = 0; position < quizzes.length; position++) {
        final quiz = _asMap(quizzes[position], 'grammar.quiz');
        final options = _asList(quiz['o'], 'grammar.quiz.options');
        final answerIndex = quiz['a'] as int;
        if (options.length < 2 ||
            options.any((option) => option is! String) ||
            answerIndex < 0 ||
            answerIndex >= options.length) {
          throw FormatException('Invalid answer options for grammar topic $id.');
        }
        statements.add(_SqlStatement(
          '''
          INSERT INTO grammar_quizzes (
            id, topic_id, position, question, options_json,
            answer_index, explanation, is_active
          ) VALUES (?, ?, ?, ?, ?, ?, ?, 1)
          ON CONFLICT(id) DO UPDATE SET
            question = excluded.question,
            options_json = excluded.options_json,
            answer_index = excluded.answer_index,
            explanation = excluded.explanation,
            is_active = 1
          ''',
          <Object?>[
            _stableId('gq', '$id:$position'),
            id,
            position,
            quiz['q'] as String,
            jsonEncode(options),
            answerIndex,
            quiz['e'] as String,
          ],
        ));
      }
    }
    await _runBatch(statements);
  }

  Future<void> _seedStories(List<Map<String, dynamic>> rows) async {
    final parentStatements = <_SqlStatement>[];
    for (final story in rows) {
      final id = story['id'] as String;
      parentStatements.add(_SqlStatement(
        '''
        INSERT INTO stories (
          id, level, title, title_tr, intro, is_active, content_version
        ) VALUES (?, ?, ?, ?, ?, 1, $currentContentSeedVersion)
        ON CONFLICT(id) DO UPDATE SET
          level = excluded.level,
          title = excluded.title,
          title_tr = excluded.title_tr,
          intro = excluded.intro,
          is_active = 1,
          content_version = excluded.content_version
        ''',
        <Object?>[
          id,
          story['level'] as int,
          story['title'] as String,
          story['titleTr'] as String,
          story['intro'] as String,
        ],
      ));
    }
    await _runBatch(parentStatements);

    final lineStatements = <_SqlStatement>[];
    for (final story in rows) {
      final storyId = story['id'] as String;
      final lines = _asList(story['lines'], 'stories.lines');
      for (var position = 0; position < lines.length; position++) {
        final line = _asMap(lines[position], 'stories.lines');
        lineStatements.add(_SqlStatement(
          '''
          INSERT INTO story_lines (
            story_id, position, english, turkish, is_active
          ) VALUES (?, ?, ?, ?, 1)
          ON CONFLICT(story_id, position) DO UPDATE SET
            english = excluded.english,
            turkish = excluded.turkish,
            is_active = 1
          ''',
          <Object?>[
            storyId,
            position,
            line['en'] as String,
            line['tr'] as String,
          ],
        ));
      }
    }
    await _runBatch(lineStatements);

    // Line-word mappings have no learner-owned data referencing them. Rebuild
    // this child table to ensure removed mappings do not linger after a content
    // version bump; stable story-line IDs and story progress remain intact.
    await database.customStatement('DELETE FROM story_line_words');
    final mappingStatements = <_SqlStatement>[];
    for (final story in rows) {
      final storyId = story['id'] as String;
      final lines = _asList(story['lines'], 'stories.lines');
      for (var linePosition = 0; linePosition < lines.length; linePosition++) {
        final line = _asMap(lines[linePosition], 'stories.lines');
        final mappings = _asList(line['words'], 'stories.lines.words');
        for (var position = 0; position < mappings.length; position++) {
          final pair = _asList(mappings[position], 'stories.lines.words.pair');
          if (pair.length != 2 || pair.any((value) => value is! String)) {
            throw FormatException('Invalid word mapping in story $storyId at line $linePosition.');
          }
          final english = pair[0] as String;
          final turkish = pair[1] as String;
          mappingStatements.add(_SqlStatement(
            '''
            INSERT INTO story_line_words (
              line_id, position, english, turkish,
              normalized_english, normalized_turkish
            )
            SELECT id, ?, ?, ?, ?, ?
            FROM story_lines
            WHERE story_id = ? AND position = ?
            ''',
            <Object?>[
              position,
              english,
              turkish,
              _normalize(english),
              _normalize(turkish),
              storyId,
              linePosition,
            ],
          ));
        }
      }
    }
    await _runBatch(mappingStatements);
  }

  Future<void> _seedVocabulary(
    List<Map<String, dynamic>> words,
    List<Map<String, dynamic>> stories,
  ) async {
    final statements = <_SqlStatement>[];
    for (final word in words) {
      final english = word['english'] as String;
      final turkish = word['turkish'] as String;
      final normalizedEnglish = _normalize(english);
      final normalizedTurkish = _normalize(turkish);
      statements.add(_SqlStatement(
        '''
        INSERT INTO vocabulary_entries (
          id, english, turkish, normalized_english, normalized_turkish,
          emoji, kind, source, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'dictionary', NULL)
        ON CONFLICT(normalized_english, normalized_turkish) DO UPDATE SET
          english = excluded.english,
          turkish = excluded.turkish,
          emoji = COALESCE(excluded.emoji, vocabulary_entries.emoji)
        ''',
        <Object?>[
          _stableId('word', '$normalizedEnglish\u001f$normalizedTurkish'),
          english,
          turkish,
          normalizedEnglish,
          normalizedTurkish,
          word['emoji'] as String?,
          english.trim().contains(RegExp(r'\s')) ? 'phrase' : 'word',
        ],
      ));
    }
    await _runBatch(statements);

    final storyVocabulary = <String, _VocabularyValue>{};
    for (final story in stories) {
      final lines = _asList(story['lines'], 'stories.lines');
      for (final rawLine in lines) {
        final line = _asMap(rawLine, 'stories.lines');
        final mappings = _asList(line['words'], 'stories.lines.words');
        for (final rawPair in mappings) {
          final pair = _asList(rawPair, 'stories.lines.words.pair');
          if (pair.length != 2 ||
              pair.any((value) => value is! String)) {
            throw const FormatException('Invalid story vocabulary mapping.');
          }
          final english = pair[0] as String;
          final turkish = pair[1] as String;
          final normalizedEnglish = _normalize(english);
          final normalizedTurkish = _normalize(turkish);
          final key = '$normalizedEnglish\u001f$normalizedTurkish';
          storyVocabulary.putIfAbsent(
            key,
            () => _VocabularyValue(
              id: _stableId('word', key),
              english: english,
              turkish: turkish,
              normalizedEnglish: normalizedEnglish,
              normalizedTurkish: normalizedTurkish,
              kind: english.trim().contains(RegExp(r'\s')) ? 'phrase' : 'word',
            ),
          );
        }
      }
    }

    final storyStatements = storyVocabulary.values.map((word) {
      return _SqlStatement(
        '''
        INSERT INTO vocabulary_entries (
          id, english, turkish, normalized_english, normalized_turkish,
          kind, source, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, 'story', NULL)
        ON CONFLICT(normalized_english, normalized_turkish) DO NOTHING
        ''',
        <Object?>[
          word.id,
          word.english,
          word.turkish,
          word.normalizedEnglish,
          word.normalizedTurkish,
          word.kind,
        ],
      );
    }).toList(growable: false);
    await _runBatch(storyStatements);
  }

  Future<void> _seedSentenceExercises(List<Map<String, dynamic>> rows) async {
    final statements = <_SqlStatement>[];
    for (var position = 0; position < rows.length; position++) {
      final exercise = rows[position];
      final category = exercise['category'] as String;
      final level = exercise['level'] as int;
      final english = exercise['english'] as String;
      final turkish = exercise['turkish'] as String;
      final identity =
          '$category\u001f$level\u001f${_normalize(english)}\u001f${_normalize(turkish)}';
      final distractors = _asList(exercise['distractors'], 'sentence_builder.distractors');
      if (distractors.any((value) => value is! String)) {
        throw const FormatException('Sentence-builder distractors must be strings.');
      }
      statements.add(_SqlStatement(
        '''
        INSERT INTO sentence_exercises (
          id, source_position, category, level, turkish, english,
          note, distractors_json, is_active
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
        ON CONFLICT(id) DO UPDATE SET
          source_position = excluded.source_position,
          category = excluded.category,
          level = excluded.level,
          turkish = excluded.turkish,
          english = excluded.english,
          note = excluded.note,
          distractors_json = excluded.distractors_json,
          is_active = 1
        ''',
        <Object?>[
          _stableId('exercise', identity),
          position,
          category,
          level,
          turkish,
          english,
          exercise['note'] as String,
          jsonEncode(distractors),
        ],
      ));
    }
    await _runBatch(statements);
  }

  Future<void> _seedGameWords(List<Map<String, dynamic>> rows) async {
    final statements = <_SqlStatement>[];
    for (var position = 0; position < rows.length; position++) {
      final word = rows[position];
      final english = word['english'] as String;
      final turkish = word['turkish'] as String;
      final theme = word['theme'] as String;
      final identity =
          '${_normalize(english)}\u001f${_normalize(turkish)}\u001f$theme';
      statements.add(_SqlStatement(
        '''
        INSERT INTO game_words (
          id, source_position, english, turkish, theme, is_active
        ) VALUES (?, ?, ?, ?, ?, 1)
        ON CONFLICT(id) DO UPDATE SET
          source_position = excluded.source_position,
          english = excluded.english,
          turkish = excluded.turkish,
          theme = excluded.theme,
          is_active = 1
        ''',
        <Object?>[
          _stableId('game', identity),
          position,
          english,
          turkish,
          theme,
        ],
      ));
    }
    await _runBatch(statements);
  }

  Future<void> _seedDatasetVersions(
    Map<String, List<Map<String, dynamic>>> datasets,
    int seededAt,
  ) async {
    final statements = datasets.entries.map((entry) {
      return _SqlStatement(
        '''
        INSERT INTO content_dataset_versions (
          dataset_key, version, record_count, seeded_at
        ) VALUES (?, $currentContentSeedVersion, ?, ?)
        ON CONFLICT(dataset_key) DO UPDATE SET
          version = excluded.version,
          record_count = excluded.record_count,
          seeded_at = excluded.seeded_at
        ''',
        <Object?>[entry.key, entry.value.length, seededAt],
      );
    }).toList(growable: false);
    await _runBatch(statements);
  }

  Future<void> _runBatch(List<_SqlStatement> statements) async {
    if (statements.isEmpty) return;
    await database.batch((batch) {
      for (final statement in statements) {
        batch.customStatement(statement.sql, statement.arguments);
      }
    });
  }

  List<dynamic> _asList(Object? value, String field) {
    if (value is! List<dynamic>) {
      throw FormatException('Expected a list for $field.');
    }
    return value;
  }

  Map<String, dynamic> _asMap(Object? value, String field) {
    if (value is! Map) {
      throw FormatException('Expected an object for $field.');
    }
    return Map<String, dynamic>.from(value);
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _stableId(String prefix, String source) {
    // Two bounded polynomial hashes keep IDs stable on both Dart VM and web.
    // The original text remains stored and displayed; this is only a key.
    var first = 5381;
    var second = 2166136261;
    for (final unit in source.codeUnits) {
      first = ((first * 33) + unit) % 4294967291;
      second = ((second * 37) + unit) % 4294967279;
    }
    return '${prefix}_${first.toRadixString(36).padLeft(7, '0')}${second.toRadixString(36).padLeft(7, '0')}';
  }
}

class ContentSeedReport {
  const ContentSeedReport({
    required this.skipped,
    required this.recordCounts,
  });

  /// True when the bundled datasets were already at the current seed version.
  final bool skipped;

  /// Top-level records in each source JSON dataset.
  final Map<String, int> recordCounts;
}

class _SqlStatement {
  const _SqlStatement(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;
}

class _VocabularyValue {
  const _VocabularyValue({
    required this.id,
    required this.english,
    required this.turkish,
    required this.normalizedEnglish,
    required this.normalizedTurkish,
    required this.kind,
  });

  final String id;
  final String english;
  final String turkish;
  final String normalizedEnglish;
  final String normalizedTurkish;
  final String kind;
}
