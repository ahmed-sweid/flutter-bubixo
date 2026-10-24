import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import 'vocabulary_entry.dart';
import 'words_repository.dart';

/// Copies the pre-database vocabulary collections into SQLite once.
///
/// The legacy preference keys are intentionally kept as a recovery copy, so a
/// failed or partial import can be retried. The repository records its own
/// marker, which makes repeated calls cheap no-ops.
class LegacyWordsMigration {
  const LegacyWordsMigration();

  Future<void> run(AppDatabase database) async {
    final preferences = await SharedPreferences.getInstance();
    final savedEnglish =
        preferences.getStringList('bubixo.saved_words') ?? const <String>[];
    final reviewEnglish =
        preferences.getStringList('bubixo.review_words') ?? const <String>[];
    final customWords = _decodeCustomWords(
      preferences.getString('bubixo.custom_words'),
    );

    if (savedEnglish.isEmpty && reviewEnglish.isEmpty && customWords.isEmpty) {
      return;
    }

    await WordsRepository(database).importLegacyCollection(
      savedEnglish: savedEnglish,
      reviewEnglish: reviewEnglish,
      customWords: customWords,
    );
  }

  List<VocabularyEntry> _decodeCustomWords(String? raw) {
    if (raw == null || raw.isEmpty) return const <VocabularyEntry>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return const <VocabularyEntry>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .where(
            (entry) => entry['english'] is String && entry['turkish'] is String,
          )
          .map(
            (entry) => VocabularyEntry(
              id: 'legacy',
              english: entry['english'] as String,
              turkish: entry['turkish'] as String,
              kind: entry['kind'] is String
                  ? entry['kind'] as String
                  : 'Kelime',
              source: 'user',
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return const <VocabularyEntry>[];
    } on TypeError {
      return const <VocabularyEntry>[];
    }
  }
}
