import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/learning_progress_repository.dart';
import '../../data/lesson_repository.dart';
import 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({
    this._lessonRepository = const LessonRepository(),
    this._progressRepository = const LearningProgressRepository(),
  }) : super(const LessonsState());

  final LessonRepository _lessonRepository;
  final LearningProgressRepository _progressRepository;

  Future<void> load() async {
    emit(state.copyWith(status: LessonsStatus.loading, clearError: true));
    try {
      final lessons = await _lessonRepository.loadLessons();
      final completed = await _progressRepository.loadCompletedLessons();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LessonsStatus.success,
          lessons: lessons,
          completedLessonIds: completed,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LessonsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> rememberLesson(String lessonId) =>
      _progressRepository.rememberLesson(lessonId);

  Future<void> refreshProgress() async {
    try {
      final completed = await _progressRepository.loadCompletedLessons();
      if (isClosed) return;
      emit(state.copyWith(completedLessonIds: completed));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }
}
