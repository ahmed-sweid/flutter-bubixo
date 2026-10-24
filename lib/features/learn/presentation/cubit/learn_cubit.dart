import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../discover/data/story_repository.dart';
import '../../../words/data/words_repository.dart';
import 'learn_state.dart';

class LearnCubit extends Cubit<LearnState> {
  LearnCubit({
    this._preferences,
    this._storyRepository = const StoryRepository(),
    this._databaseProvider,
  }) : super(const LearnState());

  final SharedPreferences? _preferences;
  final StoryRepository _storyRepository;

  /// Provides the local database for the saved-word count. Where it is absent
  /// (web, or a screen running before bootstrap), the legacy preference
  /// mirror is used instead.
  final Future<AppDatabase> Function()? _databaseProvider;

  Future<void> load() async {
    emit(state.copyWith(status: LearnStatus.loading, clearError: true));

    try {
      final preferences = _preferences ?? await SharedPreferences.getInstance();
      final stories = await _storyRepository.loadStories();
      final savedWords = await _savedWordCount(preferences);
      final progress = LearnProgress(
        totalStories: stories.length,
        startedStoryIds:
            (preferences.getStringList('bubixo.read_story_ids') ??
                    const <String>[])
                .toSet(),
        savedWords: savedWords,
        practiceSessions: preferences.getInt('bubixo.practice.sessions') ?? 0,
        correctAnswers:
            preferences.getInt('bubixo.practice.correct_answers') ?? 0,
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          status: LearnStatus.success,
          progress: progress,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LearnStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<int> _savedWordCount(SharedPreferences preferences) async {
    final provider = _databaseProvider;
    if (provider == null) {
      return preferences.getStringList('bubixo.saved_words')?.length ?? 0;
    }
    try {
      final saved = await WordsRepository(await provider()).getSavedWords();
      return saved.length;
    } catch (_) {
      // A database that cannot be read must not hide the learner's summary.
      return preferences.getStringList('bubixo.saved_words')?.length ?? 0;
    }
  }
}
