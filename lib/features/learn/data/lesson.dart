class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.intro,
    required this.points,
    required this.tip,
    required this.quizzes,
  });

  final String id;
  final String title;
  final int minutes;
  final String intro;
  final List<LessonPoint> points;
  final String tip;
  final List<LessonQuiz> quizzes;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final pointsJson = json['points'];
    final quizzesJson = json['quiz'];
    if (pointsJson is! List || quizzesJson is! List || quizzesJson.isEmpty) {
      throw const FormatException(
        'Ders içeriğinde points veya geçerli bir quiz listesi eksik.',
      );
    }

    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      minutes: json['mins'] as int,
      intro: json['intro'] as String,
      points: pointsJson
          .map((item) => LessonPoint.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      tip: json['tip'] as String,
      quizzes: quizzesJson
          .map((item) => LessonQuiz.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
    );
  }
}

class LessonPoint {
  const LessonPoint({required this.english, required this.turkish});

  final String english;
  final String turkish;

  factory LessonPoint.fromJson(Map<String, dynamic> json) => LessonPoint(
        english: json['en'] as String,
        turkish: json['tr'] as String,
      );
}

class LessonQuiz {
  const LessonQuiz({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['o'];
    final question = json['q'];
    final answerIndex = json['a'];
    final explanation = json['e'];

    if (optionsJson is! List ||
        optionsJson.length < 2 ||
        !optionsJson.every((option) => option is String) ||
        question is! String ||
        question.trim().isEmpty ||
        answerIndex is! int ||
        answerIndex < 0 ||
        answerIndex >= optionsJson.length ||
        explanation is! String) {
      throw const FormatException('Ders sınavında geçersiz soru verisi bulundu.');
    }

    return LessonQuiz(
      question: question,
      options: optionsJson.cast<String>(),
      answerIndex: answerIndex,
      explanation: explanation,
    );
  }
}
