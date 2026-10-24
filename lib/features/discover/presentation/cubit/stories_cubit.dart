import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/story_repository.dart';
import 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit({this._repository = const StoryRepository()})
    : super(const StoriesState());

  final StoryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: StoriesStatus.loading, clearError: true));
    try {
      final stories = await _repository.loadStories();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoriesStatus.success,
          stories: stories,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoriesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void selectLevel(int? level) {
    emit(
      state.copyWith(selectedLevel: level, clearSelectedLevel: level == null),
    );
  }

  void clearLevelFilter() {
    emit(state.copyWith(clearSelectedLevel: true));
  }
}
