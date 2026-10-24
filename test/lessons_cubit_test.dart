import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubixo/features/learn/presentation/cubit/lessons_cubit.dart';
import 'package:bubixo/features/learn/presentation/cubit/lessons_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonsCubit cubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'bubixo.learning.completed_lessons': <String>['lesson-1'],
    });
    cubit = LessonsCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loads lessons and completed lesson progress', () async {
    await cubit.load();

    expect(cubit.state.status, LessonsStatus.success);
    expect(cubit.state.lessons, hasLength(10));
    expect(cubit.state.completedLessonIds, contains('lesson-1'));
  });

  test('remembers the opened lesson through the progress repository', () async {
    await cubit.rememberLesson('lesson-2');

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('bubixo.learning.last_lesson_id'), 'lesson-2');
  });
}
