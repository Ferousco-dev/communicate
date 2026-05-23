import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around flutter_tts. Uses the device's built-in voices, so it
/// works fully offline. Later you can add a cloud voice and fall back to this.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool soundOn = true; // sensory mode can switch this off

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // a little slower, easier for kids
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    if (!soundOn) return;
    final t = text.trim();
    if (t.isEmpty) return;
    await _tts.stop();
    await _tts.speak(t);
  }

  Future<void> stop() => _tts.stop();
}

/// Single shared instance used across the app.
final ttsService = TtsService();
