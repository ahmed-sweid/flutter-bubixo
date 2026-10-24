import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_bootstrap.dart';
import '../../../words/data/words_repository.dart';

enum StoryVocabularyStatus { idle, saving, saved, failure }

class StoryVocabularyState {
  const StoryVocabularyState({
    this.status = StoryVocabularyStatus.idle,
    this.lastSavedEnglish,
    this.saveCount = 0,
    this.errorMessage,
  });

  final StoryVocabularyStatus status;
  final String? lastSavedEnglish;

  /// Increments on every successful save so repeated saves of the same word
  /// still notify the listening screen.
  final int saveCount;
  final String? errorMessage;

  StoryVocabularyState copyWith({
    StoryVocabularyStatus? status,
    String? lastSavedEnglish,
    int? saveCount,
    String? errorMessage,
  }) {
    return StoryVocabularyState(
      status: status ?? this.status,
      lastSavedEnglish: lastSavedEnglish ?? this.lastSavedEnglish,
      saveCount: saveCount ?? this.saveCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Saves vocabulary highlighted in a story into the learner's word list.
///
/// The story screen used to write these words only to the legacy preferences
/// store, which the one-time Drift migration no longer imports, so they never
/// reached the Kelimeler tab. This cubit keeps the story flow on the same
/// database-backed collection as the rest of the app.
class StoryVocabularyCubit extends Cubit<StoryVocabularyState> {
  StoryVocabularyCubit({this._repository})
    : super(const StoryVocabularyState());

  final WordsRepository? _repository;
  WordsRepository? _activeRepository;

  Future<WordsRepository> _repositoryForUse() async {
    return _activeRepository ??=
        _repository ?? WordsRepository(await DatabaseBootstrap.initialize());
  }

  Future<void> saveWord({
    required String english,
    required String turkish,
    String kind = 'Hikâyeden',
  }) async {
    if (english.trim().isEmpty || turkish.trim().isEmpty) {
      emit(
        state.copyWith(
          status: StoryVocabularyStatus.failure,
          errorMessage: 'Kaydedilecek kelime boş olamaz.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: StoryVocabularyStatus.saving, errorMessage: null),
    );

    try {
      final repository = await _repositoryForUse();
      await repository.saveCustomWord(
        english: english,
        turkish: turkish,
        kind: kind,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoryVocabularyStatus.saved,
          lastSavedEnglish: english.trim(),
          saveCount: state.saveCount + 1,
          errorMessage: null,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoryVocabularyStatus.failure,
          errorMessage: 'Kelime kaydedilemedi.',
        ),
      );
    }
  }
}
