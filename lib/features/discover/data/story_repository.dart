import 'dart:convert';

import 'package:flutter/services.dart';

import 'story.dart';

class StoryRepository {
  const StoryRepository();

  Future<List<Story>> loadStories() async {
    final source = await rootBundle.loadString('assets/data/stories.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .map((item) => Story.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
