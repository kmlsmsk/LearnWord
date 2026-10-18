import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  Set<String> _learnedWordIds = {};
  Set<String> _favoriteWordIds = {};
  Set<String> _repeatWordIds = {};
  int _streakDays = 1;
  int _dailyGoal = 15;
  int _quizCorrect = 0;
  int _quizTotal = 0;

  Set<String> get learnedWordIds => _learnedWordIds;
  Set<String> get favoriteWordIds => _favoriteWordIds;
  Set<String> get repeatWordIds => _repeatWordIds;
  int get streakDays => _streakDays;
  int get dailyGoal => _dailyGoal;
  int get quizCorrect => _quizCorrect;
  int get quizTotal => _quizTotal;

  int get learnedCount => _learnedWordIds.length;
  int get favoriteCount => _favoriteWordIds.length;
  int get repeatCount => _repeatWordIds.length;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final learned = prefs.getStringList('learned_words') ?? [];
      final favorites = prefs.getStringList('favorite_words') ?? [];
      final repeats = prefs.getStringList('repeat_words') ?? [];
      _learnedWordIds = learned.toSet();
      _favoriteWordIds = favorites.toSet();
      _repeatWordIds = repeats.toSet();
      _streakDays = prefs.getInt('streak_days') ?? 1;
      _dailyGoal = prefs.getInt('daily_goal') ?? 15;
      _quizCorrect = prefs.getInt('quiz_correct') ?? 0;
      _quizTotal = prefs.getInt('quiz_total') ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint("ProgressService init error: $e");
    }
  }

  bool isLearned(String wordId) => _learnedWordIds.contains(wordId);
  bool isFavorite(String wordId) => _favoriteWordIds.contains(wordId);
  bool isRepeat(String wordId) => _repeatWordIds.contains(wordId);

  Future<void> toggleLearned(String wordId) async {
    if (_learnedWordIds.contains(wordId)) {
      _learnedWordIds.remove(wordId);
    } else {
      _learnedWordIds.add(wordId);
      // If learned, remove from repeat list
      _repeatWordIds.remove(wordId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('repeat_words', _repeatWordIds.toList());
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learned_words', _learnedWordIds.toList());
  }

  Future<void> toggleFavorite(String wordId) async {
    if (_favoriteWordIds.contains(wordId)) {
      _favoriteWordIds.remove(wordId);
    } else {
      _favoriteWordIds.add(wordId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_words', _favoriteWordIds.toList());
  }

  Future<void> addToRepeat(String wordId) async {
    if (!_repeatWordIds.contains(wordId)) {
      _repeatWordIds.add(wordId);
      _learnedWordIds.remove(wordId);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('repeat_words', _repeatWordIds.toList());
      await prefs.setStringList('learned_words', _learnedWordIds.toList());
    }
  }

  Future<void> removeFromRepeat(String wordId) async {
    if (_repeatWordIds.contains(wordId)) {
      _repeatWordIds.remove(wordId);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('repeat_words', _repeatWordIds.toList());
    }
  }

  Future<void> toggleRepeat(String wordId) async {
    if (_repeatWordIds.contains(wordId)) {
      _repeatWordIds.remove(wordId);
    } else {
      _repeatWordIds.add(wordId);
      _learnedWordIds.remove(wordId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('repeat_words', _repeatWordIds.toList());
    await prefs.setStringList('learned_words', _learnedWordIds.toList());
  }

  Future<void> recordQuizResult(bool correct, {String? wordId}) async {
    _quizTotal++;
    if (correct) {
      _quizCorrect++;
    } else if (wordId != null) {
      // Add wrong answered word to repeat list automatically!
      await addToRepeat(wordId);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_correct', _quizCorrect);
    await prefs.setInt('quiz_total', _quizTotal);
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', _dailyGoal);
  }
}
