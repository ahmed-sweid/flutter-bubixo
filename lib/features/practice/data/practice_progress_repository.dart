import 'package:shared_preferences/shared_preferences.dart';

/// Session counters shown on the practice tab.
class PracticeProgress {
  const PracticeProgress({
    required this.sessions,
    required this.correctAnswers,
  });

  static const PracticeProgress empty = PracticeProgress(
    sessions: 0,
    correctAnswers: 0,
  );

  final int sessions;
  final int correctAnswers;

  bool get hasActivity => sessions > 0 || correctAnswers > 0;
}

/// Stores practice counters and the last opened activity locally.
///
/// These remain preferences until the practice history is modelled in the
/// database (`practice_sessions`), so the widget layer never touches storage.
class PracticeProgressRepository {
  const PracticeProgressRepository();

  static const _sessionsKey = 'bubixo.practice.sessions';
  static const _correctAnswersKey = 'bubixo.practice.correct_answers';
  static const _lastActivityTypeKey = 'bubixo.last_activity_type';
  static const _lastActivityIdKey = 'bubixo.last_activity_id';

  Future<PracticeProgress> loadProgress() async {
    final preferences = await SharedPreferences.getInstance();
    return PracticeProgress(
      sessions: preferences.getInt(_sessionsKey) ?? 0,
      correctAnswers: preferences.getInt(_correctAnswersKey) ?? 0,
    );
  }

  Future<void> rememberActivity(String activityId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_lastActivityTypeKey, 'practice');
    await preferences.setString(_lastActivityIdKey, activityId);
  }

  Future<void> recordCompletedSession({required int correctAnswers}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _sessionsKey,
      (preferences.getInt(_sessionsKey) ?? 0) + 1,
    );
    await preferences.setInt(
      _correctAnswersKey,
      (preferences.getInt(_correctAnswersKey) ?? 0) + correctAnswers,
    );
  }
}
