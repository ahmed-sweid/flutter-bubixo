import 'package:flutter_test/flutter_test.dart';

import 'package:bubixo/core/database/app_database.dart';
import 'package:bubixo/core/database/content_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  test('creates schema and enables foreign keys', () async {
    final tables = await database.customSelect(
      "SELECT COUNT(*) AS total FROM sqlite_master "
      "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    ).getSingle();
    final foreignKeys = await database.customSelect(
      'PRAGMA foreign_keys',
    ).getSingle();

    expect(tables.read<int>('total'), 22);
    expect(foreignKeys.read<int>('foreign_keys'), 1);
  });

  test('imports the six bundled content datasets and remains idempotent', () async {
    final seeder = ContentSeeder(database);

    final first = await seeder.seedIfNeeded();

    expect(first.skipped, isFalse);
    expect(first.recordCounts, {
      'lessons': 10,
      'words': 3000,
      'grammar': 6,
      'stories': 12,
      'sentence_builder': 120,
      'game_words': 240,
    });

    expect(await _count(database, 'lessons'), 10);
    expect(await _count(database, 'lesson_points'), 86);
    expect(await _count(database, 'lesson_quizzes'), 50);
    expect(await _count(database, 'grammar_topics'), 6);
    expect(await _count(database, 'grammar_examples'), 29);
    expect(await _count(database, 'grammar_quizzes'), 18);
    expect(await _count(database, 'stories'), 12);
    expect(await _count(database, 'story_lines'), 129);
    expect(await _count(database, 'story_line_words'), 796);
    expect(await _count(database, 'sentence_exercises'), 120);
    expect(await _count(database, 'game_words'), 240);

    final dictionaryWords = await database.customSelect(
      "SELECT COUNT(*) AS total FROM vocabulary_entries "
      "WHERE source = 'dictionary'",
    ).getSingle();
    expect(dictionaryWords.read<int>('total'), 3000);

    final second = await seeder.seedIfNeeded();

    expect(second.skipped, isTrue);
    expect(await _count(database, 'lessons'), 10);
    expect(await _count(database, 'lesson_points'), 86);
    expect(await _count(database, 'lesson_quizzes'), 50);
    expect(await _count(database, 'stories'), 12);
    expect(await _count(database, 'story_line_words'), 796);
  });

  test('rejects orphan learner progress instead of silently storing it', () async {
    await expectLater(
      database.customStatement(
        '''
        INSERT INTO lesson_progress (lesson_id, status)
        VALUES ('missing-lesson', 'completed')
        ''',
      ),
      throwsA(anything),
    );

    expect(await _count(database, 'lesson_progress'), 0);
  });
}

Future<int> _count(AppDatabase database, String table) async {
  // Only fixed table names from the test suite are passed here.
  final row = await database.customSelect(
    'SELECT COUNT(*) AS total FROM $table',
  ).getSingle();
  return row.read<int>('total');
}
