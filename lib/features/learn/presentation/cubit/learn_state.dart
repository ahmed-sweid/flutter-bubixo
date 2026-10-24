enum LearnStatus { initial, loading, success, failure }

class LearnProgress {
  const LearnProgress({
    required this.totalStories,
    required this.startedStoryIds,
    required this.savedWords,
    required this.practiceSessions,
    required this.correctAnswers,
  });

  factory LearnProgress.empty() => const LearnProgress(
        totalStories: 0,
        startedStoryIds: <String>{},
        savedWords: 0,
        practiceSessions: 0,
        correctAnswers: 0,
      );

  final int totalStories;
  final Set<String> startedStoryIds;
  final int savedWords;
  final int practiceSessions;
  final int correctAnswers;

  int get startedStoryCount =>
      startedStoryIds.length.clamp(0, totalStories).toInt();
}

class LearnState {
  const LearnState({
    this.status = LearnStatus.initial,
    this.progress,
    this.errorMessage,
  });

  final LearnStatus status;
  final LearnProgress? progress;
  final String? errorMessage;

  LearnState copyWith({
    LearnStatus? status,
    LearnProgress? progress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LearnState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
