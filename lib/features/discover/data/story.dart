class Story {
  const Story({
    required this.id,
    required this.level,
    required this.title,
    required this.titleTr,
    required this.intro,
    required this.lines,
  });

  final String id;
  final int level;
  final String title;
  final String titleTr;
  final String intro;
  final List<StoryLine> lines;

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      level: json['level'] as int,
      title: json['title'] as String,
      titleTr: json['titleTr'] as String,
      intro: json['intro'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((line) => StoryLine.fromJson(line as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class StoryLine {
  const StoryLine({
    required this.en,
    required this.tr,
    required this.words,
  });

  final String en;
  final String tr;
  final List<WordMapping> words;

  factory StoryLine.fromJson(Map<String, dynamic> json) {
    return StoryLine(
      en: json['en'] as String,
      tr: json['tr'] as String,
      words: (json['words'] as List<dynamic>)
          .map((pair) {
            final values = pair as List<dynamic>;
            return WordMapping(
              english: values[0] as String,
              turkish: values[1] as String,
            );
          })
          .toList(growable: false),
    );
  }
}

class WordMapping {
  const WordMapping({required this.english, required this.turkish});

  final String english;
  final String turkish;
}
