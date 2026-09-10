import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

enum SpeechEngine { google, system }

/// The Google Translate TTS endpoint for [text] in [languageCode].
///
/// Free of plugin dependencies so it can be unit tested directly.
Uri googleTtsUri(String text, String languageCode) =>
    Uri.https('translate.google.com', '/translate_tts', {
      'ie': 'UTF-8',
      'client': 'tw-ob',
      'ttsspeed': '1',
      'tl': languageCode,
      'q': text,
    });

class SpeechException implements Exception {
  SpeechException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Speaks numbers aloud.
///
/// Google Translate's voice is preferred because it sounds markedly better than
/// the bundled system voices. It expands a bare numeral into words in the target
/// language itself, so no per-language spelling table is needed. When it cannot
/// be reached the on-device engine takes over.
class SpeechService {
  SpeechService({http.Client? client, AudioPlayer? player, FlutterTts? tts})
    : _client = client ?? http.Client(),
      _player = player ?? AudioPlayer(),
      _tts = tts ?? FlutterTts();

  static const _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0 Safari/537.36';

  final http.Client _client;
  final AudioPlayer _player;
  final FlutterTts _tts;

  Uri buildGoogleUri(String text, String languageCode) =>
      googleTtsUri(text, languageCode);

  Future<Uint8List> _fetchGoogleAudio(String text, String languageCode) async {
    final response = await _client
        .get(
          buildGoogleUri(text, languageCode),
          headers: const {
            'User-Agent': _userAgent,
            'Referer': 'https://translate.google.com/',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw SpeechException(
        'Google voice returned HTTP ${response.statusCode}.',
      );
    }
    if (response.bodyBytes.isEmpty) {
      throw SpeechException('Google voice returned no audio.');
    }
    return response.bodyBytes;
  }

  Future<void> _speakWithSystem(String text, String languageCode) async {
    await _tts.stop();
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  /// Best effort: stopping must never be the thing that breaks a screen, so a
  /// missing or unhappy platform plugin is ignored rather than propagated.
  Future<void> stop() async {
    try {
      await _player.stop().timeout(const Duration(seconds: 2));
    } catch (_) {
      // ignored
    }
    try {
      await _tts.stop().timeout(const Duration(seconds: 2));
    } catch (_) {
      // ignored
    }
  }

  /// Returns the engine that actually spoke, so the UI can say when it fell back.
  Future<SpeechEngine> speak(String text, String languageCode) async {
    try {
      final bytes = await _fetchGoogleAudio(text, languageCode);
      await _player.stop();
      await _player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
      return SpeechEngine.google;
    } catch (_) {
      try {
        await _speakWithSystem(text, languageCode);
        return SpeechEngine.system;
      } catch (_) {
        throw SpeechException(
          'Could not play the number. Check your connection.',
        );
      }
    }
  }

  void dispose() {
    try {
      _player.dispose();
    } catch (_) {
      // ignored
    }
    _client.close();
  }
}
