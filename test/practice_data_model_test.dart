import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/features/practice/data/builder_exercises.dart';
import 'package:bubixo/features/practice/data/game_words.dart';

void main() {
  group('BuilderExercise.fromJson', () {
    const validExercise = <String, dynamic>{
      'category': 'present',
      'level': 1,
      'turkish': 'Ben her gün kitap okurum.',
      'english': 'I read a book every day',
      'distractors': ['every', 'day'],
      'note': 'Simple present örneği.',
    };

    test('parses valid exercise data', () {
      final exercise = BuilderExercise.fromJson(validExercise);

      expect(exercise.english, 'I read a book every day');
      expect(exercise.level, 1);
      expect(exercise.distractors, ['every', 'day']);
    });

    test('rejects invalid level and distractor types', () {
      expect(
        () => BuilderExercise.fromJson({...validExercise, 'level': 0}),
        throwsFormatException,
      );
      expect(
        () => BuilderExercise.fromJson({
          ...validExercise,
          'distractors': ['every', 4],
        }),
        throwsFormatException,
      );
    });
  });

  group('GameWord.fromJson', () {
    test('parses valid word data', () {
      final word = GameWord.fromJson({
        'english': 'apple',
        'turkish': 'elma',
        'theme': 'food',
      });

      expect(word.english, 'apple');
      expect(word.turkish, 'elma');
      expect(word.theme, 'food');
    });

    test('rejects missing or blank word fields', () {
      expect(
        () => GameWord.fromJson({
          'english': 'apple',
          'turkish': 'elma',
        }),
        throwsFormatException,
      );
      expect(
        () => GameWord.fromJson({
          'english': ' ',
          'turkish': 'elma',
          'theme': 'food',
        }),
        throwsFormatException,
      );
    });
  });
}
