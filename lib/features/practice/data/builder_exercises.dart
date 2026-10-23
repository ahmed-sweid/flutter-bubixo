import 'package:flutter/foundation.dart';

@immutable
class BuilderExercise {
  const BuilderExercise({required this.category, required this.level, required this.turkish, required this.english, required this.distractors, required this.note});
  final String category;
  final int level;
  final String turkish;
  final String english;
  final List<String> distractors;
  final String note;

  factory BuilderExercise.fromJson(Map<String, dynamic> json) => BuilderExercise(
    category: json['category'] as String,
    level: json['level'] as int,
    turkish: json['turkish'] as String,
    english: json['english'] as String,
    distractors: (json['distractors'] as List<dynamic>).cast<String>(),
    note: json['note'] as String,
  );
}
