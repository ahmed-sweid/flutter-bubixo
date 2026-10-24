import '../../data/practice_data_repository.dart';
import '../../data/practice_progress_repository.dart';

enum PracticeStatus { initial, loading, ready, failure }

class PracticeState {
  const PracticeState({
    this.status = PracticeStatus.initial,
    this.progress = PracticeProgress.empty,
    this.content,
    this.errorMessage,
  });

  final PracticeStatus status;
  final PracticeProgress progress;

  /// Exercises and word pool for the activity the learner just opened.
  final PracticeData? content;
  final String? errorMessage;

  PracticeState copyWith({
    PracticeStatus? status,
    PracticeProgress? progress,
    PracticeData? content,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PracticeState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      content: content ?? this.content,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
