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

  factory BuilderExercise.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final level = json['level'];
    final turkish = json['turkish'];
    final english = json['english'];
    final distractors = json['distractors'];
    final note = json['note'];

    if (category is! String ||
        category.trim().isEmpty ||
        level is! int ||
        level < 1 ||
        turkish is! String ||
        turkish.trim().isEmpty ||
        english is! String ||
        english.trim().isEmpty ||
        distractors is! List ||
        !distractors.every((item) => item is String) ||
        note is! String ||
        note.trim().isEmpty) {
      throw const FormatException('Cümle alıştırmasında geçersiz veri bulundu.');
    }

    return BuilderExercise(
      category: category,
      level: level,
      turkish: turkish,
      english: english,
      distractors: distractors.cast<String>(),
      note: note,
    );
  }
}
