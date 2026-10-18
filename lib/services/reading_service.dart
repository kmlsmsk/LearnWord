import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_passage.dart';
import '../data/osym_reading_passages.dart';

class ReadingService extends ChangeNotifier {
  static final ReadingService _instance = ReadingService._internal();
  factory ReadingService() => _instance;
  ReadingService._internal();

  List<ReadingPassage> _passages = [];

  List<ReadingPassage> get passages => _passages;

  Future<void> init() async {
    _passages = List.from(OsymReadingPassages.defaultPassages);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJsonList = prefs.getStringList('custom_reading_passages') ?? [];
      for (var jsonStr in savedJsonList) {
        try {
          final Map<String, dynamic> map = jsonDecode(jsonStr);
          _passages.add(ReadingPassage.fromJson(map));
        } catch (e) {
          debugPrint("Error parsing custom passage: $e");
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("ReadingService init error: $e");
    }
  }

  Future<void> addCustomPassage({
    required String title,
    required String content,
    String turkishTranslation = '',
    String category = 'Kendi Metnim',
  }) async {
    final newPassage = ReadingPassage(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Özel Okuma Parçası' : title.trim(),
      category: category,
      content: content.trim(),
      turkishTranslation: turkishTranslation.trim(),
      isCustom: true,
      createdAt: DateTime.now(),
    );

    _passages.insert(0, newPassage);
    notifyListeners();
    await _saveCustomPassages();
  }

  Future<void> deletePassage(String id) async {
    _passages.removeWhere((p) => p.id == id && p.isCustom);
    notifyListeners();
    await _saveCustomPassages();
  }

  Future<void> _saveCustomPassages() async {
    final prefs = await SharedPreferences.getInstance();
    final customList = _passages
        .where((p) => p.isCustom)
        .map((p) => jsonEncode(p.toJson()))
        .toList();
    await prefs.setStringList('custom_reading_passages', customList);
  }
}
