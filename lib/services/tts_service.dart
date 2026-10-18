import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  String _currentLanguage = "en-US";

  String get currentLanguage => _currentLanguage;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();

      // Configure Android TTS engine
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          final engines = await _flutterTts?.getEngines;
          if (engines is List && engines.contains("com.google.android.tts")) {
            await _flutterTts?.setEngine("com.google.android.tts");
          }
        } catch (_) {}
      }

      await _setupEnglishLanguage();
      await _flutterTts?.setSpeechRate(0.48); // Natural, clear English learning pace
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  Future<void> _setupEnglishLanguage() async {
    try {
      // Test en-US first
      final isUsAvailable = await _flutterTts?.isLanguageAvailable("en-US") ?? false;
      if (isUsAvailable) {
        _currentLanguage = "en-US";
      } else {
        final isGbAvailable = await _flutterTts?.isLanguageAvailable("en-GB") ?? false;
        if (isGbAvailable) {
          _currentLanguage = "en-GB";
        } else {
          _currentLanguage = "en";
        }
      }
      await _flutterTts?.setLanguage(_currentLanguage);

      // Try finding high-quality English voice
      final voices = await _flutterTts?.getVoices;
      if (voices is List) {
        for (var voice in voices) {
          if (voice is Map) {
            final locale = voice['locale']?.toString().toLowerCase() ?? '';
            if (locale.startsWith('en-us') || locale.startsWith('en_us')) {
              await _flutterTts?.setVoice({
                'name': voice['name'].toString(),
                'locale': voice['locale'].toString(),
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error setting English voice: $e");
    }
  }

  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      // Re-enforce English before speaking to prevent system from reverting to Turkish
      await _flutterTts?.setLanguage(_currentLanguage);
      await _flutterTts?.stop();

      if (text.trim().isNotEmpty) {
        await _flutterTts?.speak(text.trim());
      }
    } catch (e) {
      debugPrint("TTS speak error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts?.stop();
    } catch (e) {
      debugPrint("TTS stop error: $e");
    }
  }
}
