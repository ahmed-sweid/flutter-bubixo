import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_bootstrap.dart';
import '../../data/words_repository.dart';
import 'words_state.dart';

/// Loads the saved and review collections from SQLite.
class WordsCubit extends Cubit<WordsState> {
  WordsCubit({WordsRepository? repository})
      : _repository = repository,
        super(const WordsState());

  final WordsRepository? _repository;

  Future<void> load() async {
    emit(state.copyWith(
      status: WordsStatus.loading,
      clearError: true,
    ));

    try {
      final repository = _repository ??
          WordsRepository(await DatabaseBootstrap.initialize());
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
