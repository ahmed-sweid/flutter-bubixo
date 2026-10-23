import 'dart:convert';

import 'package:flutter/services.dart';

import 'grammar_topic.dart';

class GrammarRepository {
  const GrammarRepository();

  Future<List<GrammarTopic>> loadTopics() async {
    final raw = await rootBundle.loadString('assets/data/grammar.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Dil bilgisi verisi beklenen biçimde değil.');
    }
    return decoded
        .map((item) => GrammarTopic.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }
}
