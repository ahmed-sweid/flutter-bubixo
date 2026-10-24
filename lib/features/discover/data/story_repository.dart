import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/content_database.dart';
import 'story.dart';

class StoryRepository {
  const StoryRepository({this.database});

  /// Reads from the seeded database when one is available; bundled JSON is the
  /// fallback for platforms and failures without it.
  final AppDatabase? database;

  Future<List<Story>> loadStories() async {
    final resolved = await resolveContentDatabase(database);
    if (resolved != null) {
      try {
        final stories = await _loadFromDatabase(resolved);
        if (stories.isNotEmpty) return stories;
      } catch (_) {
        // Fall through to the bundled dataset.
      }
    }
    return _loadFromAssets();
  }

  Future<List<Story>> _loadFromDatabase(AppDatabase database) async {
    final headers = await database
        .customSelect(
          'SELECT id, level, title, title_tr, intro FROM stories '
          'WHERE is_active = 1 ORDER BY rowid',
        )
        .get();
    final lines = await database
        .customSelect(
          'SELECT l.id AS line_id, l.story_id, l.english, l.turkish '
          'FROM story_lines l WHERE l.is_active = 1 '
          'ORDER BY l.story_id, l.position',
        )
        .get();
    final words = await database
        .customSelect(
          'SELECT line_id, english, turkish FROM story_line_words '
          'ORDER BY line_id, position',
        )
        .get();

    final wordsByLine = <int, List<WordMapping>>{};
    for (final row in words) {
      (wordsByLine[row.read<int>('line_id')] ??= <WordMapping>[]).add(
        WordMapping(
          english: row.read<String>('english'),
          turkish: row.read<String>('turkish'),
        ),
      );
    }

    final linesByStory = <String, List<StoryLine>>{};
    for (final row in lines) {
      (linesByStory[row.read<String>('story_id')] ??= <StoryLine>[]).add(
        StoryLine(
          en: row.read<String>('english'),
          tr: row.read<String>('turkish'),
          words: wordsByLine[row.read<int>('line_id')] ?? const <WordMapping>[],
        ),
      );
    }

    return headers
        .map(
          (row) => Story(
            id: row.read<String>('id'),
            level: row.read<int>('level'),
            title: row.read<String>('title'),
            titleTr: row.read<String>('title_tr'),
            intro: row.read<String>('intro'),
            lines: linesByStory[row.read<String>('id')] ?? const <StoryLine>[],
          ),
        )
        .toList(growable: false);
  }

  Future<List<Story>> _loadFromAssets() async {
    final source = await rootBundle.loadString('assets/data/stories.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
