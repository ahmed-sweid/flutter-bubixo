import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Shared English text-to-speech service used by stories and lessons.
///
/// Speech is an enhancement: a device without a usable voice engine, or a
/// platform channel failure, must never break reading a story or a lesson.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  Future<void>? _configuration;

  Future<void> _configure() {
    return _configuration ??= _configureTts();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('en-GB');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (error, stackTrace) {
      // Allow a later utterance to retry the setup.
      _configuration = null;
      debugPrint('Bubixo speech setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Speaks non-empty English text, interrupting any previous utterance.
  /// Failures are logged, never surfaced to the reader.
  Future<void> speakEnglish(String text) async {
    final sentence = text.trim();
    if (sentence.isEmpty) return;

    try {
      await _tts.stop();
      await _configure();
      await _tts.speak(sentence);
    } catch (error) {
      debugPrint('Bubixo could not speak "$sentence": $error');
    }
  }

  /// Stops the current utterance, if any.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (error) {
      debugPrint('Bubixo could not stop speech: $error');
    }
  }
}
