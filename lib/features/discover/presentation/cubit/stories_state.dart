import '../data/story.dart';

enum StoriesStatus { initial, loading, success, failure }

class StoriesState {
  const StoriesState({
    this.status = StoriesStatus.initial,
    this.stories = const <Story>[],
    this.selectedLevel,
    this.errorMessage,
  });

  final StoriesStatus status;
  final List<Story> stories;
  final int? selectedLevel;
  final String? errorMessage;

  List<Story> get visibleStories {
    final level = selectedLevel;
    if (level == null) return stories;
    return stories
        .where((story) => story.level == level)
        .toList(growable: false);
  }

  StoriesState copyWith({
    StoriesStatus? status,
    List<Story>? stories,
    int? selectedLevel,
    String? errorMessage,
    bool clearSelectedLevel = false,
    bool clearError = false,
  }) {
    return StoriesState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      selectedLevel:
          clearSelectedLevel ? null : selectedLevel ?? this.selectedLevel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
