import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubixo/features/learn/data/learning_progress_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LearningProgressRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = const LearningProgressRepository();
  });

  test('remembers the last opened lesson', () async {
    await repository.rememberLesson('u3');

    expect(await repository.loadLastLessonId(), 'u3');
  });

  test('stores completed lessons without duplicates', () async {
    await repository.markLessonCompleted('u2');
    await repository.markLessonCompleted('u1');
    await repository.markLessonCompleted('u2');

    expect(await repository.loadCompletedLessons(), {'u1', 'u2'});
  });

  test('tracks quiz attempts and correct answers', () async {
    await repository.recordQuizAnswer(correct: true);
    await repository.recordQuizAnswer(correct: false);
    await repository.recordQuizAnswer(correct: true);

    expect(await repository.loadQuizStats(), {'attempts': 3, 'correct': 2});
  });
}
