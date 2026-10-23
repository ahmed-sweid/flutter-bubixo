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
    if (pointsJson is! List || quizzesJson is! List) {
      throw const FormatException('Ders içeriğinde points veya quiz listesi eksik.');
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
    if (optionsJson is! List) {
      throw const FormatException('Ders sınavında seçenek listesi eksik.');
    }
    return LessonQuiz(
      question: json['q'] as String,
      options: optionsJson.cast<String>(),
      answerIndex: json['a'] as int,
      explanation: json['e'] as String,
    );
  }
}
