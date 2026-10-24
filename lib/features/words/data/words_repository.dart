import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'vocabulary_entry.dart';

/// Reads and updates learner-owned vocabulary collections in SQLite.
class WordsRepository {
  const WordsRepository(this._database);

  final AppDatabase _database;

  Future<List<VocabularyEntry>> getSavedWords() =>
      _getWords('saved_words', 'saved_at');

  Future<List<VocabularyEntry>> getReviewWords() =>
      _getWords('review_words', 'added_at');

  Future<void> toggleSaved({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    final id = await _ensureVocabularyEntry(
      english: english,
      turkish: turkish,
      kind: kind,
    );
    await _database.transaction(() async {
      final existing = await _database.customSelect(
        'SELECT word_id FROM saved_words WHERE word_id = ?',
        variables: [Variable<String>(id)],
      ).getSingleOrNull();

      if (existing != null) {
        await _database.customStatement(
          'DELETE FROM saved_words WHERE word_id = ?',
          [id],
        );
      } else {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _database.customStatement(
          'INSERT INTO saved_words (word_id, saved_at) VALUES (?, ?)',
          [id, now],
        );
      }
    });
  }

  Future<void> toggleReview({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    final id = await _ensureVocabularyEntry(
      english: english,
      turkish: turkish,
      kind: kind,
    );
    await _database.transaction(() async {
      final existing = await _database.customSelect(
        'SELECT word_id FROM review_words WHERE word_id = ?',
        variables: [Variable<String>(id)],
      ).getSingleOrNull();

      if (existing != null) {
        await _database.customStatement(
          'DELETE FROM review_words WHERE word_id = ?',
          [id],
        );
      } else {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _database.customStatement(
          'INSERT INTO review_words (word_id, added_at) VALUES (?, ?)',
          [id, now],
        );
      }
    });
  }

  /// Imports a legacy list of English expressions without deleting its source.
  /// Existing preferences remain intact as a recovery copy during migration.
  Future<void> importLegacyCollection({
    required List<String> savedEnglish,
    required List<String> reviewEnglish,
    List<VocabularyEntry> customWords = const <VocabularyEntry>[],
  }) async {
    final migration = await _database.customSelect(
      "SELECT value FROM app_state WHERE key = 'legacy_words_collection_migrated_v1'",
    ).getSingleOrNull();
    if (migration != null) return;

    await _database.transaction(() async {
      for (final rawEnglish in savedEnglish) {
        await _importLegacyEnglish(rawEnglish, 'saved_words', 'saved_at');
      }
      for (final rawEnglish in reviewEnglish) {
        await _importLegacyEnglish(rawEnglish, 'review_words', 'added_at');
      }
      for (final word in customWords) {
        final id = await _ensureVocabularyEntry(
          english: word.english,
          turkish: word.turkish,
          kind: word.kind,
          source: 'user',
        );
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _database.customStatement(
          'INSERT INTO saved_words (word_id, saved_at) VALUES (?, ?) '
          'ON CONFLICT(word_id) DO NOTHING',
          [id, now],
        );
      }
      await _database.customStatement(
        "INSERT INTO app_state (key, value, updated_at) VALUES ('legacy_words_collection_migrated_v1', '1', ?)",
        [DateTime.now().toUtc().millisecondsSinceEpoch],
      );
    });
  }

  Future<void> _importLegacyEnglish(
    String rawEnglish,
    String table,
    String timestampColumn,
  ) async {
    final normalized = _normalize(rawEnglish);
    if (normalized.isEmpty) return;
    final match = await _database.customSelect(
      '''
      SELECT id FROM vocabulary_entries
      WHERE normalized_english = ?
      ORDER BY CASE WHEN source = 'dictionary' THEN 0 ELSE 1 END
      LIMIT 1
      ''',
      variables: [Variable<String>(normalized)],
    ).getSingleOrNull();
    if (match == null) return;

    final id = match.read<String>('id');
    final exists = await _database.customSelect(
      'SELECT word_id FROM $table WHERE word_id = ?',
      variables: [Variable<String>(id)],
    ).getSingleOrNull();
    if (exists == null) {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database.customStatement(
        'INSERT INTO $table (word_id, $timestampColumn) VALUES (?, ?)',
        [id, now],
      );
    }
  }

  Future<void> saveCustomWord({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    final id = await _ensureVocabularyEntry(
      english: english,
      turkish: turkish,
      kind: kind,
      source: 'user',
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _database.customStatement(
      'INSERT INTO saved_words (word_id, saved_at) VALUES (?, ?) '
      'ON CONFLICT(word_id) DO NOTHING',
      [id, now],
    );
  }

  Future<String> _ensureVocabularyEntry({
    required String english,
    required String turkish,
    required String kind,
    String source = 'dictionary',
  }) async {
    final normalizedEnglish = _normalize(english);
    final normalizedTurkish = _normalize(turkish);
    if (normalizedEnglish.isEmpty || normalizedTurkish.isEmpty) {
      throw ArgumentError('English and Turkish vocabulary values must not be empty.');
    }

    final existing = await _database.customSelect(
      '''
      SELECT id FROM vocabulary_entries
      WHERE normalized_english = ? AND normalized_turkish = ?
      LIMIT 1
      ''',
      variables: [
        Variable<String>(normalizedEnglish),
        Variable<String>(normalizedTurkish),
      ],
    ).getSingleOrNull();
    if (existing != null) return existing.read<String>('id');

    final id = 'user_${DateTime.now().microsecondsSinceEpoch}';
    await _database.customStatement(
      '''
      INSERT INTO vocabulary_entries (
        id, english, turkish, normalized_english, normalized_turkish,
        kind, source, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        id,
        english.trim(),
        turkish.trim(),
        normalizedEnglish,
        normalizedTurkish,
        kind,
        source,
        DateTime.now().toUtc().millisecondsSinceEpoch,
      ],
    );
    return id;
  }

  Future<List<VocabularyEntry>> _getWords(
    String collectionTable,
    String orderColumn,
  ) async {
    // Identifiers are selected only from the fixed constants above.
    final rows = await _database.customSelect('''
      SELECT v.id, v.english, v.turkish, v.emoji, v.kind, v.source
      FROM $collectionTable AS collection
      INNER JOIN vocabulary_entries AS v ON v.id = collection.word_id
      ORDER BY collection.$orderColumn DESC, v.english COLLATE NOCASE ASC
    ''').get();

    return List<VocabularyEntry>.unmodifiable(
      rows.map((row) => VocabularyEntry.fromRow(row.data)),
    );
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
