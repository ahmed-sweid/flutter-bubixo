import 'package:flutter_tts/flutter_tts.dart';

/// Small English text-to-speech service for story reading.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();

  Future<void> speakEnglish(String text) async {
    final sentence = text.trim();
    if (sentence.isEmpty) return;

    await _tts.stop();
    await _tts.setLanguage('en-GB');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.speak(sentence);
  }

  Future<void> stop() => _tts.stop();
}
