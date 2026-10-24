import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/practice_data_repository.dart';
import '../../data/practice_progress_repository.dart';
import 'practice_state.dart';

/// Owns the practice tab's counters and the content loaded for an activity.
class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({
    PracticeProgressRepository? progressRepository,
    PracticeDataRepository? contentRepository,
  }) : _progressRepository =
           progressRepository ?? const PracticeProgressRepository(),
       _contentRepository = contentRepository ?? const PracticeDataRepository(),
       super(const PracticeState());

  final PracticeProgressRepository _progressRepository;
  final PracticeDataRepository _contentRepository;

  Future<void> loadProgress() async {
    try {
      final progress = await _progressRepository.loadProgress();
      if (isClosed) return;
      emit(state.copyWith(progress: progress));
    } catch (error) {
      // The exercises stay usable when the local counters cannot be read.
      debugPrint('Bubixo practice progress could not be read: $error');
      if (isClosed) return;
      emit(state.copyWith(progress: PracticeProgress.empty));
    }
  }

  /// Loads the exercise pool for the tapped activity.
  ///
  /// Returns null when the content could not be loaded, so the screen can show
  /// a retryable failure instead of opening an empty activity.
  Future<PracticeData?> prepareActivity(String activityId) async {
    emit(state.copyWith(status: PracticeStatus.loading, clearError: true));

    try {
      await _progressRepository.rememberActivity(activityId);
      final content = await _contentRepository.loadAll();
      if (isClosed) return content;
      emit(state.copyWith(status: PracticeStatus.ready, content: content));
      return content;
    } catch (error) {
      debugPrint('Bubixo practice content could not be loaded: $error');
      if (isClosed) return null;
      emit(
        state.copyWith(
          status: PracticeStatus.failure,
          errorMessage: 'Alıştırmalar yüklenemedi. Tekrar dene.',
        ),
      );
      return null;
    }
  }

  Future<void> recordCompletedSession({required int correctAnswers}) async {
    try {
      await _progressRepository.recordCompletedSession(
        correctAnswers: correctAnswers,
      );
    } catch (error) {
      debugPrint('Bubixo could not store the completed session: $error');
    }
    if (isClosed) return;
    await loadProgress();
  }
}
