import '../../../core/database/app_database.dart';
import 'vocabulary_entry.dart';

/// Reads learner-owned vocabulary collections from the local SQLite database.
class WordsRepository {
  const WordsRepository(this._database);

  final AppDatabase _database;

  Future<List<VocabularyEntry>> getSavedWords() {
    return _getWords('saved_words', 'saved_at');
  }

  Future<List<VocabularyEntry>> getReviewWords() {
    return _getWords('review_words', 'added_at');
  }

  Future<List<VocabularyEntry>> _getWords(
    String collectionTable,
    String orderColumn,
  ) async {
    // Table and column names are selected only from the constants above.
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
}
