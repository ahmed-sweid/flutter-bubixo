import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/features/learn/data/lesson.dart';

void main() {
  test('parses a valid quiz question', () {
    final quiz = LessonQuiz.fromJson({
      'q': 'Which word means merhaba?',
      'o': ['Hello', 'Goodbye'],
      'a': 0,
      'e': 'Hello means merhaba.',
    });

    expect(quiz.question, 'Which word means merhaba?');
    expect(quiz.options, ['Hello', 'Goodbye']);
    expect(quiz.answerIndex, 0);
  });

  test('rejects an answer index outside the options', () {
    expect(
      () => LessonQuiz.fromJson({
        'q': 'Choose an answer',
        'o': ['A', 'B'],
        'a': 2,
        'e': 'Explanation',
      }),
      throwsFormatException,
    );
  });

  test('rejects a lesson with no quiz questions', () {
    expect(
      () => Lesson.fromJson({
        'id': 'u-test',
        'title': 'Test lesson',
        'mins': 5,
        'intro': 'Intro',
        'points': [
          {'en': 'Hello', 'tr': 'Merhaba'},
        ],
        'tip': 'Tip',
        'quiz': [],
      }),
      throwsFormatException,
    );
  });
}
