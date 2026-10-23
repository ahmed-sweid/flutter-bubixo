import 'package:flutter_test/flutter_test.dart';
import 'package:bubixo/core/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ignores blank text without invoking the native speech plugin', () async {
    await SpeechService.instance.speakEnglish('   \n  ');
  });
}
