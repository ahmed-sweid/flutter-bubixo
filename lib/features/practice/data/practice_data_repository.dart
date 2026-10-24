import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/content_database.dart';
import 'builder_exercises.dart';
import 'game_words.dart';

class PracticeDataRepository {
  const PracticeDataRepository({this.database});

  /// Reads from the seeded database when one is available; bundled JSON is the
  /// fallback for platforms and failures without it.
  final AppDatabase? database;

  Future<List<BuilderExercise>> loadBuilderExercises() async {
    final resolved = await resolveContentDatabase(database);
    if (resolved != null) {
      try {
        final exercises = await _exercisesFromDatabase(resolved);
        if (exercises.isNotEmpty) return exercises;
      } catch (_) {
        // Fall through to the bundled dataset.
      }
    }
    return _exercisesFromAssets();
  }

  Future<List<GameWord>> loadGameWords() async {
    final resolved = await resolveContentDatabase(database);
    if (resolved != null) {
      try {
        final words = await _wordsFromDatabase(resolved);
        if (words.isNotEmpty) return words;
      } catch (_) {
        // Fall through to the bundled dataset.
      }
    }
    return _wordsFromAssets();
  }

  Future<PracticeData> loadAll() async {
    final results = await Future.wait<Object>([
      loadBuilderExercises(),
      loadGameWords(),
    ]);
    return PracticeData(
      exercises: results[0] as List<BuilderExercise>,
      words: results[1] as List<GameWord>,
    );
  }

  Future<List<BuilderExercise>> _exercisesFromDatabase(
    AppDatabase database,
  ) async {
    final rows = await database
        .customSelect(
          'SELECT category, level, turkish, english, note, distractors_json '
          'FROM sentence_exercises WHERE is_active = 1 '
          'ORDER BY source_position',
        )
        .get();

    return rows
        .map(
          (row) => BuilderExercise(
            category: row.read<String>('category'),
            level: row.read<int>('level'),
            turkish: row.read<String>('turkish'),
            english: row.read<String>('english'),
            distractors: decodeStringList(
              row.read<Object?>('distractors_json'),
            ),
            note: row.read<String>('note'),
          ),
        )
        .toList(growable: false);
  }

  Future<List<GameWord>> _wordsFromDatabase(AppDatabase database) async {
    final rows = await database
        .customSelect(
          'SELECT english, turkish, theme FROM game_words '
          'WHERE is_active = 1 ORDER BY source_position',
        )
        .get();

    return rows
        .map(
          (row) => GameWord(
            english: row.read<String>('english'),
            turkish: row.read<String>('turkish'),
            theme: row.read<String>('theme'),
          ),
        )
        .toList(growable: false);
  }

  Future<List<BuilderExercise>> _exercisesFromAssets() async {
    final source = await rootBundle.loadString(
      'assets/data/sentence_builder.json',
    );
    final rows = jsonDecode(source) as List<dynamic>;
    return rows
        .map((row) => BuilderExercise.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<GameWord>> _wordsFromAssets() async {
    final source = await rootBundle.loadString('assets/data/game_words.json');
    final rows = jsonDecode(source) as List<dynamic>;
    return rows
        .map((row) => GameWord.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }
}

class PracticeData {
  const PracticeData({required this.exercises, required this.words});
  final List<BuilderExercise> exercises;
  final List<GameWord> words;
}
