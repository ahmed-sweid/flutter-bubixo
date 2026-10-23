import 'package:shared_preferences/shared_preferences.dart';

class LearningProgressRepository {
  const LearningProgressRepository();

  static const _completedLessonsKey = 'bubixo.learning.completed_lessons';
  static const _lastLessonIdKey = 'bubixo.learning.last_lesson_id';
  static const _quizAttemptsKey = 'bubixo.learning.quiz_attempts';
  static const _quizCorrectKey = 'bubixo.learning.quiz_correct';

  Future<Set<String>> loadCompletedLessons() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_completedLessonsKey) ?? const <String>[]).toSet();
  }

  Future<String?> loadLastLessonId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_lastLessonIdKey);
  }

  Future<void> rememberLesson(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_lastLessonIdKey, lessonId);
  }

  Future<void> recordQuizAnswer({required bool correct}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_quizAttemptsKey, (preferences.getInt(_quizAttemptsKey) ?? 0) + 1);
    if (correct) {
      await preferences.setInt(_quizCorrectKey, (preferences.getInt(_quizCorrectKey) ?? 0) + 1);
    }
  }

  Future<void> markLessonCompleted(String lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final completed = (preferences.getStringList(_completedLessonsKey) ?? <String>[]).toSet();
    completed.add(lessonId);
    await preferences.setStringList(_completedLessonsKey, completed.toList()..sort());
  }

  Future<Map<String, int>> loadQuizStats() async {
    final preferences = await SharedPreferences.getInstance();
    return {
      'attempts': preferences.getInt(_quizAttemptsKey) ?? 0,
      'correct': preferences.getInt(_quizCorrectKey) ?? 0,
    };
  }
}
