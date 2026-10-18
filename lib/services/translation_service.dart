import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/osym_word_database.dart';
import '../models/word.dart';

class TranslationResult {
  final String original;
  final String translation;
  final String source; // 'Sınav Sözlüğü' or 'Google Çeviri' or 'Ağ Çevirisi'
  final String? partOfSpeech;
  final List<String> synonyms;
  final String? example;

  const TranslationResult({
    required this.original,
    required this.translation,
    required this.source,
    this.partOfSpeech,
    this.synonyms = const [],
    this.example,
  });
}

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // In-memory cache for fast subsequent lookups
  final Map<String, TranslationResult> _cache = {};

  Future<TranslationResult> translateWordOrPhrase(String rawText) async {
    final clean = rawText.trim();
    if (clean.isEmpty) {
      return const TranslationResult(
        original: '',
        translation: '',
        source: 'Boş',
      );
    }

    final lower = clean.toLowerCase();
    final singleWordOnly = clean.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();

    // 1. Check in-memory cache
    if (_cache.containsKey(lower)) {
      return _cache[lower]!;
    }

    // 2. Search local database (2,000+ words)
    Word? match;
    for (var w in OsymWordDatabase.words) {
      if (w.word.toLowerCase() == singleWordOnly) {
        match = w;
        break;
      }
    }

    // Stem/prefix match
    if (match == null && singleWordOnly.length > 3) {
      for (var w in OsymWordDatabase.words) {
        if (singleWordOnly.startsWith(w.word.toLowerCase()) ||
            w.word.toLowerCase().startsWith(singleWordOnly)) {
          match = w;
          break;
        }
      }
    }

    if (match != null) {
      final res = TranslationResult(
        original: match.word,
        translation: match.meaning,
        source: 'Sınav Sözlüğü',
        partOfSpeech: match.type.labelTr,
        synonyms: match.synonyms,
        example: match.examples.isNotEmpty ? match.examples.first.english : null,
      );
      _cache[lower] = res;
      return res;
    }

    // 3. Google Translate API
    try {
      final translated = await _fetchGoogleTranslate(clean);
      if (translated != null && translated.isNotEmpty) {
        final res = TranslationResult(
          original: clean,
          translation: translated,
          source: 'Google Çeviri',
          partOfSpeech: clean.contains(' ') ? 'Cümle / İfade' : 'Kelime',
        );
        _cache[lower] = res;
        return res;
      }
    } catch (e) {
      debugPrint("TranslationService Google Translate primary error: $e");
    }

    // 4. Secondary Online Fallback (MyMemory API)
    try {
      final myMemoryRes = await _fetchMyMemoryTranslate(clean);
      if (myMemoryRes != null && myMemoryRes.isNotEmpty) {
        final res = TranslationResult(
          original: clean,
          translation: myMemoryRes,
          source: 'Ağ Çevirisi',
          partOfSpeech: clean.contains(' ') ? 'Cümle / İfade' : 'Kelime',
        );
        _cache[lower] = res;
        return res;
      }
    } catch (e) {
      debugPrint("TranslationService MyMemory fallback error: $e");
    }

    // 5. Fallback if completely offline
    final fallbackRes = TranslationResult(
      original: clean,
      translation: 'Çeviri internet bağlantısı sağlandığında otomatik tamamlanacaktır.',
      source: 'Bağlantı Bekleniyor',
    );
    return fallbackRes;
  }

  Future<String?> _fetchGoogleTranslate(String text) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=tr&dt=t&q=$encoded',
      );
      final request = await client.getUrl(url);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final dynamic json = jsonDecode(responseBody);
        if (json is List && json.isNotEmpty && json[0] is List) {
          final sb = StringBuffer();
          for (var segment in json[0]) {
            if (segment is List && segment.isNotEmpty && segment[0] != null) {
              sb.write(segment[0]);
            }
          }
          final res = sb.toString().trim();
          if (res.isNotEmpty) return res;
        }
      }
      return null;
    } finally {
      client.close();
    }
  }

  Future<String?> _fetchMyMemoryTranslate(String text) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=$encoded&langpair=en|tr',
      );
      final request = await client.getUrl(url);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final dynamic json = jsonDecode(responseBody);
        if (json is Map && json['responseData'] != null) {
          final trans = json['responseData']['translatedText'];
          if (trans is String && trans.isNotEmpty) {
            return trans.trim();
          }
        }
      }
      return null;
    } finally {
      client.close();
    }
  }

  /// Live connection test for Settings screen
  Future<Map<String, dynamic>> testConnection() async {
    final stopwatch = Stopwatch()..start();
    try {
      final sampleWord = "sustainability";
      // Clear sample from cache to force live network check
      _cache.remove(sampleWord);

      // Force network translation test directly
      String? result = await _fetchGoogleTranslate(sampleWord);
      String source = "Google Çeviri";
      if (result == null || result.isEmpty) {
        result = await _fetchMyMemoryTranslate(sampleWord);
        source = "MyMemory Çeviri";
      }

      stopwatch.stop();

      if (result != null && result.isNotEmpty) {
        return {
          'success': true,
          'source': source,
          'sample': '$sampleWord ➔ $result',
          'durationMs': stopwatch.elapsedMilliseconds,
          'message': 'Çeviri sunucusu aktif ve internet bağlantısı çalışıyor!',
        };
      } else {
        return {
          'success': false,
          'source': 'Ağ Hatası',
          'sample': '$sampleWord ➔ Yanıt alınamadı',
          'durationMs': stopwatch.elapsedMilliseconds,
          'message': 'Çeviri sunucusuna erişilemedi. Lütfen internet bağlantınızı kontrol edin.',
        };
      }
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'source': 'Hata',
        'sample': '',
        'durationMs': stopwatch.elapsedMilliseconds,
        'message': 'Ağ bağlantı hatası: $e',
      };
    }
  }
}
