class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.title,
    required this.badge,
    required this.formula,
    required this.explanation,
    required this.examples,
    required this.quizzes,
  });

  final String id;
  final String title;
  final String badge;
  final String formula;
  final String explanation;
  final List<GrammarExample> examples;
  final List<GrammarQuiz> quizzes;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    final examplesJson = json['ex'];
    final quizzesJson = json['quiz'];
    if (examplesJson is! List || quizzesJson is! List) {
      throw const FormatException('Dil bilgisi konusu örnek veya test içeriği içermiyor.');
    }
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      badge: json['badge'] as String,
      formula: json['formula'] as String,
      explanation: json['when'] as String,
      examples: examplesJson
          .map((item) => GrammarExample.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      quizzes: quizzesJson
          .map((item) => GrammarQuiz.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
    );
  }
}

class GrammarExample {
  const GrammarExample({required this.english, required this.turkish});

  final String english;
  final String turkish;

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
        english: json['en'] as String,
        turkish: json['tr'] as String,
      );
}

class GrammarQuiz {
  const GrammarQuiz({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  factory GrammarQuiz.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['o'];
    if (optionsJson is! List) {
      throw const FormatException('Dil bilgisi testinde seçenek listesi eksik.');
    }
    return GrammarQuiz(
      question: json['q'] as String,
      options: optionsJson.cast<String>(),
      answerIndex: json['a'] as int,
      explanation: json['e'] as String,
    );
  }
}
