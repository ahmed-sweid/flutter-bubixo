import '../../data/lesson.dart';

enum LessonsStatus { initial, loading, success, failure }

class LessonsState {
  const LessonsState({
    this.status = LessonsStatus.initial,
    this.lessons = const <Lesson>[],
    this.completedLessonIds = const <String>{},
    this.errorMessage,
  });

  final LessonsStatus status;
  final List<Lesson> lessons;
  final Set<String> completedLessonIds;
  final String? errorMessage;

  LessonsState copyWith({
    LessonsStatus? status,
    List<Lesson>? lessons,
    Set<String>? completedLessonIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LessonsState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
