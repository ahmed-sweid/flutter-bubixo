import 'dart:convert';
import 'package:flutter/services.dart';
import 'builder_exercises.dart';
import 'game_words.dart';

class PracticeDataRepository {
  const PracticeDataRepository();

  Future<List<BuilderExercise>> loadBuilderExercises() async {
    final source = await rootBundle.loadString('assets/data/sentence_builder.json');
    final rows = jsonDecode(source) as List<dynamic>;
    return rows.map((row) => BuilderExercise.fromJson(row as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<GameWord>> loadGameWords() async {
    final source = await rootBundle.loadString('assets/data/game_words.json');
    final rows = jsonDecode(source) as List<dynamic>;
    return rows.map((row) => GameWord.fromJson(row as Map<String, dynamic>)).toList(growable: false);
  }

  Future<PracticeData> loadAll() async {
    final results = await Future.wait<Object>([loadBuilderExercises(), loadGameWords()]);
    return PracticeData(exercises: results[0] as List<BuilderExercise>, words: results[1] as List<GameWord>);
  }
}

class PracticeData {
  const PracticeData({required this.exercises, required this.words});
  final List<BuilderExercise> exercises;
  final List<GameWord> words;
}
