import 'package:flutter/foundation.dart';

@immutable
class GameWord {
  const GameWord({required this.english, required this.turkish, required this.theme});
  final String english;
  final String turkish;
  final String theme;

  factory GameWord.fromJson(Map<String, dynamic> json) => GameWord(
    english: json['english'] as String,
    turkish: json['turkish'] as String,
    theme: json['theme'] as String,
  );
}
