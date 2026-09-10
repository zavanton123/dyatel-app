import 'package:dyatel/services/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds the Google TTS url for the selected language', () {
    final uri = googleTtsUri('42', 'pt-BR');

    expect(uri.host, 'translate.google.com');
    expect(uri.path, '/translate_tts');
    expect(uri.queryParameters['q'], '42');
    expect(uri.queryParameters['tl'], 'pt-BR');
    expect(uri.queryParameters['client'], 'tw-ob');
  });

  test('escapes values rather than injecting them raw', () {
    final uri = googleTtsUri('1 000', 'zh-CN');

    expect(uri.queryParameters['q'], '1 000');
    expect(uri.toString(), contains('tl=zh-CN'));
    expect(uri.toString(), isNot(contains('q=1 000')));
  });

  test('covers every offered language', () {
    for (final code in ['pt-BR', 'en-US', 'ru', 'ja', 'zh-CN']) {
      expect(googleTtsUri('7', code).queryParameters['tl'], code);
    }
  });
}
