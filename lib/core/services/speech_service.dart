import 'package:flutter_tts/flutter_tts.dart';

/// Shared English text-to-speech service used by stories and lessons.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  Future<void>? _configuration;

  Future<void> _configure() {
    return _configuration ??= _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-GB');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  /// Speaks non-empty English text, interrupting any previous utterance.
  Future<void> speakEnglish(String text) async {
    final sentence = text.trim();
    if (sentence.isEmpty) return;

    await _tts.stop();
    await _configure();
    await _tts.speak(sentence);
  }

  /// Stops the current utterance, if any.
  Future<void> stop() => _tts.stop();
}
