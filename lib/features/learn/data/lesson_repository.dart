import 'dart:convert';

import 'package:flutter/services.dart';

import 'lesson.dart';

class LessonRepository {
  const LessonRepository();

  Future<List<Lesson>> loadLessons() async {
    final source = await rootBundle.loadString('assets/data/lessons.json');
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Ders dosyasının üst düzey yapısı liste olmalı.');
    }

    return decoded
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Ders listesinde geçersiz kayıt bulundu.');
          }
          return Lesson.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }
}
