import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_bootstrap.dart';
import '../../data/words_repository.dart';
import 'words_state.dart';

/// Owns the saved and review collections shown by the vocabulary screen.
class WordsCubit extends Cubit<WordsState> {
  WordsCubit({WordsRepository? repository})
      : _repository = repository,
        super(const WordsState());

  final WordsRepository? _repository;
  WordsRepository? _activeRepository;

  Future<WordsRepository> _repositoryForUse() async {
    return _activeRepository ??= _repository ??
        WordsRepository(await DatabaseBootstrap.initialize());
  }

  Future<void> load({
    List<String> legacySavedWords = const <String>[],
    List<String> legacyReviewWords = const <String>[],
  }) async {
    emit(state.copyWith(
      status: WordsStatus.loading,
      clearError: true,
    ));

    try {
      final repository = await _repositoryForUse();
      if (legacySavedWords.isNotEmpty || legacyReviewWords.isNotEmpty) {
        await repository.importLegacyCollection(
          savedEnglish: legacySavedWords,
          reviewEnglish: legacyReviewWords,
        );
      }
      final results = await Future.wait([
        repository.getSavedWords(),
        repository.getReviewWords(),
      ]);

      emit(state.copyWith(
        status: WordsStatus.loaded,
        savedWords: results[0],
        reviewWords: results[1],
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: WordsStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> toggleSaved({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    await _mutateCollection(
      () => _repositoryForUse().then((repository) => repository.toggleSaved(
            english: english,
            turkish: turkish,
            kind: kind,
          )),
    );
  }

  Future<void> toggleReview({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    await _mutateCollection(
      () => _repositoryForUse().then((repository) => repository.toggleReview(
            english: english,
            turkish: turkish,
            kind: kind,
          )),
    );
  }

  Future<void> saveCustomWord({
    required String english,
    required String turkish,
    required String kind,
  }) async {
    await _mutateCollection(
      () => _repositoryForUse().then((repository) => repository.saveCustomWord(
            english: english,
            turkish: turkish,
            kind: kind,
          )),
    );
  }

  Future<void> _mutateCollection(Future<void> Function() action) async {
    try {
      await action();
      final repository = await _repositoryForUse();
      final results = await Future.wait([
        repository.getSavedWords(),
        repository.getReviewWords(),
      ]);
      emit(state.copyWith(
        status: WordsStatus.loaded,
        savedWords: results[0],
        reviewWords: results[1],
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: WordsStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
