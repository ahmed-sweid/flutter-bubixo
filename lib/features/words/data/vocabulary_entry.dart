/// A vocabulary item read from the local database.
class VocabularyEntry {
  const VocabularyEntry({
    required this.id,
    required this.english,
    required this.turkish,
    required this.kind,
    required this.source,
    this.emoji,
  });

  final String id;
  final String english;
  final String turkish;
  final String kind;
  final String source;
  final String? emoji;

  factory VocabularyEntry.fromRow(Map<String, Object?> row) {
    return VocabularyEntry(
      id: row['id']! as String,
      english: row['english']! as String,
      turkish: row['turkish']! as String,
      kind: row['kind']! as String,
      source: row['source']! as String,
      emoji: row['emoji'] as String?,
    );
  }
}
