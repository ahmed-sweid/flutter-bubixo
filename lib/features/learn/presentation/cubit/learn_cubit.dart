import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../discover/data/story_repository.dart';
import 'learn_state.dart';

class LearnCubit extends Cubit<LearnState> {
  LearnCubit({
    SharedPreferences? preferences,
    StoryRepository storyRepository = const StoryRepository(),
  })  : _preferences = preferences,
        _storyRepository = storyRepository,
        super(const LearnState());

  final SharedPreferences? _preferences;
  final StoryRepository _storyRepository;

  Future<void> load() async {
    emit(state.copyWith(status: LearnStatus.loading, clearError: true));

    try {
      final preferences = _preferences ?? await SharedPreferences.getInstance();
      final stories = await _storyRepository.loadStories();
      final progress = LearnProgress(
        totalStories: stories.length,
        startedStoryIds: (preferences.getStringList('bubixo.read_story_ids') ??
                const <String>[])
            .toSet(),
        savedWords:
            preferences.getStringList('bubixo.saved_words')?.length ?? 0,
        practiceSessions: preferences.getInt('bubixo.practice.sessions') ?? 0,
        correctAnswers:
            preferences.getInt('bubixo.practice.correct_answers') ?? 0,
      );

      emit(state.copyWith(
        status: LearnStatus.success,
        progress: progress,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: LearnStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
