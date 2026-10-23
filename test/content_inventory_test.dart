import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final expectedCounts = <String, int>{
    'assets/data/lessons.json': 10,
    'assets/data/words.json': 3000,
    'assets/data/grammar.json': 6,
    'assets/data/stories.json': 12,
    'assets/data/sentence_builder.json': 120,
    'assets/data/game_words.json': 240,
  };

  for (final entry in expectedCounts.entries) {
    test('${entry.key} contains ${entry.value} records', () async {
      final source = await rootBundle.loadString(entry.key);
      final decoded = jsonDecode(source);
      expect(decoded, isA<List<dynamic>>());
      expect((decoded as List<dynamic>).length, entry.value);
    });
  }
}
