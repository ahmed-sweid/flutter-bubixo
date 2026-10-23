import 'package:flutter/foundation.dart';

@immutable
class GameWord {
  const GameWord({required this.english, required this.turkish, required this.theme});
  final String english;
  final String turkish;
  final String theme;

  factory GameWord.fromJson(Map<String, dynamic> json) {
    final english = json['english'];
    final turkish = json['turkish'];
    final theme = json['theme'];

    if (english is! String ||
        english.trim().isEmpty ||
        turkish is! String ||
        turkish.trim().isEmpty ||
        theme is! String ||
        theme.trim().isEmpty) {
      throw const FormatException('Kelime oyununda geçersiz veri bulundu.');
    }

    return GameWord(
      english: english,
      turkish: turkish,
      theme: theme,
    );
  }
}
