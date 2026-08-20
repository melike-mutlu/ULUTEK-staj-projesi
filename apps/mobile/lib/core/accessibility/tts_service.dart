import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around [FlutterTts] so the rest of the app never touches the
/// plugin directly. UI/viewmodels pass in plain text and a locale; this owns
/// engine setup, language selection and the speak/stop lifecycle.
///
/// Reusable: any screen that needs to voice text (product detail, future
/// onboarding, etc.) depends on this single service, not on flutter_tts.
class TtsService {
  TtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    _configure();
  }

  final FlutterTts _tts;
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    _configured = true;
    try {
      // Wait for each utterance to finish before the next starts so queued
      // segments (verdict, then reason) are spoken in order.
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('[TtsService] configure error: $e');
    }
  }

  /// Speaks [text] in [localeName] ('tr' or 'en'). No-op for blank text.
  /// Callers await sequential calls to read multiple segments in order.
  Future<void> speak(String text, {required String localeName}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      await _configure();
      await _tts.setLanguage(_languageTag(localeName));
      await _tts.speak(trimmed);
    } catch (e) {
      debugPrint('[TtsService] speak error: $e');
    }
  }

  /// Stops any ongoing or queued speech. Call when leaving the screen.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TtsService] stop error: $e');
    }
  }

  String _languageTag(String localeName) {
    return localeName.toLowerCase().startsWith('en') ? 'en-US' : 'tr-TR';
  }
}
