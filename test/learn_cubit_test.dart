import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubixo/features/learn/presentation/cubit/learn_cubit.dart';
import 'package:bubixo/features/learn/presentation/cubit/learn_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LearnCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'bubixo.read_story_ids': <String>['story-1', 'story-2'],
      'bubixo.saved_words': <String>['hello', 'world'],
      'bubixo.practice.sessions': 3,
      'bubixo.practice.correct_answers': 7,
    });
    cubit = LearnCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads dashboard progress from stories and learner preferences', () async {
    await cubit.load();

    expect(cubit.state.status, LearnStatus.success);
    expect(cubit.state.progress, isNotNull);
    expect(cubit.state.progress!.totalStories, 12);
    expect(cubit.state.progress!.startedStoryCount, 2);
    expect(cubit.state.progress!.savedWords, 2);
    expect(cubit.state.progress!.practiceSessions, 3);
    expect(cubit.state.progress!.correctAnswers, 7);
  });
}
