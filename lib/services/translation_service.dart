import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/osym_word_database.dart';
import '../models/word.dart';

class TranslationResult {
  final String original;
  final String translation;
  final String source; // 'ÖSYM Sözlüğü' or 'Google Çeviri'
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

    // 2. Search local ÖSYM word database (1720+ words)
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
        source: 'ÖSYM Sözlüğü',
        partOfSpeech: match.type.labelTr,
        synonyms: match.synonyms,
        example: match.examples.isNotEmpty ? match.examples.first.english : null,
      );
      _cache[lower] = res;
      return res;
    }

    // 3. Fallback to Google Translate API for words, idioms, or sentences
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
      debugPrint("TranslationService Google Translate error: $e");
    }

    // 4. Fallback if offline and not in dictionary
    final fallbackRes = TranslationResult(
      original: clean,
      translation: 'Çeviri internet bağlantısı sağlandığında otomatik tamamlanacaktır.',
      source: 'Bağlantı Bekleniyor',
    );
    return fallbackRes;
  }

  Future<String?> _fetchGoogleTranslate(String text) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
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
          return sb.toString();
        }
      }
      return null;
    } finally {
      client.close();
    }
  }
}
