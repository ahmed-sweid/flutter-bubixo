import '../../data/vocabulary_entry.dart';

enum WordsStatus { initial, loading, loaded, failure }

class WordsState {
  const WordsState({
    this.status = WordsStatus.initial,
    this.savedWords = const <VocabularyEntry>[],
    this.reviewWords = const <VocabularyEntry>[],
    this.errorMessage,
  });

  final WordsStatus status;
  final List<VocabularyEntry> savedWords;
  final List<VocabularyEntry> reviewWords;
  final String? errorMessage;

  WordsState copyWith({
    WordsStatus? status,
    List<VocabularyEntry>? savedWords,
    List<VocabularyEntry>? reviewWords,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WordsState(
      status: status ?? this.status,
      savedWords: savedWords ?? this.savedWords,
      reviewWords: reviewWords ?? this.reviewWords,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
