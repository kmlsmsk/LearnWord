import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../data/osym_word_database.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class QuizQuestion {
  final String questionText;
  final String? audioWord;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.questionText,
    this.audioWord,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();

  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generateQuizQuestions();
  }

  void _generateQuizQuestions() {
    final words = List<Word>.from(OsymWordDatabase.words)..shuffle();
    final random = Random();
    final List<QuizQuestion> list = [];

    for (int i = 0; i < min(10, words.length); i++) {
      final target = words[i];
      final qType = random.nextInt(3); // 0: Meaning, 1: Synonym, 2: Sentence

      if (qType == 0) {
        // Turkish meaning question
        final otherWords = words.where((w) => w.id != target.id).toList()..shuffle();
        final options = [
          target.meaning,
          otherWords[0].meaning,
          otherWords[1].meaning,
          otherWords[2].meaning,
        ]..shuffle();

        final correctIdx = options.indexOf(target.meaning);
        list.add(QuizQuestion(
          questionText: '"${target.word}" kelimesinin Türkçe karşılığı hangisidir?',
          audioWord: target.word,
          options: options,
          correctIndex: correctIdx,
          explanation: '${target.word} (${target.type.labelTr}): ${target.meaning}. Kök: ${target.root.rootWord}.',
        ));
      } else if (qType == 1 && target.synonyms.isNotEmpty) {
        // Synonym question
        final correctSyn = target.synonyms.first;
        final otherWords = words.where((w) => w.id != target.id).toList()..shuffle();
        final distractor1 = otherWords[0].synonyms.isNotEmpty ? otherWords[0].synonyms.first : otherWords[0].word;
        final distractor2 = otherWords[1].synonyms.isNotEmpty ? otherWords[1].synonyms.first : otherWords[1].word;
        final distractor3 = otherWords[2].synonyms.isNotEmpty ? otherWords[2].synonyms.first : otherWords[2].word;

        final options = [correctSyn, distractor1, distractor2, distractor3]..shuffle();
        final correctIdx = options.indexOf(correctSyn);

        list.add(QuizQuestion(
          questionText: 'Aşağıdakilerden hangisi "${target.word}" kelimesinin EŞ ANLAMLISIDIR?',
          audioWord: target.word,
          options: options,
          correctIndex: correctIdx,
          explanation: '"${target.word}" eş anlamlıları: ${target.synonyms.join(", ")}.',
        ));
      } else if (target.examples.isNotEmpty) {
        // Sentence cloze test question
        final ex = target.examples.first;
        final blanked = ex.english.replaceAll(RegExp(target.word, caseSensitive: false), '_______');
        final otherWords = words.where((w) => w.id != target.id && w.type == target.type).toList()..shuffle();
        
        List<String> options = [target.word];
        for (var ow in otherWords) {
          if (options.length < 4) options.add(ow.word);
        }
        while (options.length < 4 && otherWords.isNotEmpty) {
          options.add(words[random.nextInt(words.length)].word);
        }
        options.shuffle();
        final correctIdx = options.indexOf(target.word);

        list.add(QuizQuestion(
          questionText: 'Cümledeki boşluğa en uygun kelimeyi seçiniz:\n\n"$blanked"',
          options: options,
          correctIndex: correctIdx,
          explanation: 'Doğru cevap: "${target.word}" (${target.meaning}).\nÇeviri: ${ex.turkish}',
        ));
      } else {
        // Fallback to meaning
        final otherWords = words.where((w) => w.id != target.id).toList()..shuffle();
        final options = [
          target.meaning,
          otherWords[0].meaning,
          otherWords[1].meaning,
          otherWords[2].meaning,
        ]..shuffle();

        final correctIdx = options.indexOf(target.meaning);
        list.add(QuizQuestion(
          questionText: '"${target.word}" kelimesinin Türkçe anlamı nedir?',
          audioWord: target.word,
          options: options,
          correctIndex: correctIdx,
          explanation: '${target.word}: ${target.meaning}',
        ));
      }
    }

    _questions = list;
  }

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    final currentQ = _questions[_currentIndex];
    final isCorrect = (index == currentQ.correctIndex);

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) _score++;
    });

    _progressService.recordQuizResult(isCorrect);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final percentage = ((_score / _questions.length) * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.military_tech_rounded, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text('Sınav Tamamlandı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skorunuz: $_score / ${_questions.length}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'Başarı Oranı: %$percentage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: percentage >= 70 ? AppTheme.successGreen : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _selectedOptionIndex = null;
                _hasAnswered = false;
                _score = 0;
                _generateQuizQuestions();
              });
            },
            child: const Text('Yeni Test Çöz'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Ana Sayfaya Dön'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('ÖSYM Sınav Pratiği')),
        body: const Center(child: Text('Soru oluşturulamadı.')),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ÖSYM Sınav Modu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress and Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soru ${_currentIndex + 1} / ${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Puan: $_score',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                ),
              ),

              const SizedBox(height: 16),

              // Question Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (q.audioWord != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple.withOpacity(0.12),
                                foregroundColor: AppTheme.primaryPurple,
                              ),
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: () => _ttsService.speak(q.audioWord!),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kelimeyi Dinle',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        q.questionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: q.options.length,
                  itemBuilder: (context, idx) {
                    final optionText = q.options[idx];
                    Color cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.black87;

                    if (_hasAnswered) {
                      if (idx == q.correctIndex) {
                        cardColor = AppTheme.successGreen.withOpacity(0.15);
                        borderColor = AppTheme.successGreen;
                        textColor = AppTheme.successGreen;
                      } else if (idx == _selectedOptionIndex) {
                        cardColor = AppTheme.errorRed.withOpacity(0.15);
                        borderColor = AppTheme.errorRed;
                        textColor = AppTheme.errorRed;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => _handleOptionSelect(idx),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(0.12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + idx), // A, B, C, D
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (_hasAnswered) ...[
                                if (idx == q.correctIndex)
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen)
                                else if (idx == _selectedOptionIndex)
                                  const Icon(Icons.cancel_rounded, color: AppTheme.errorRed),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Explanation Box when answered
              if (_hasAnswered) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accentYellow),
                  ),
                  child: Text(
                    q.explanation,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Sıradaki Soruya Geç' : 'Sonuçları Gör',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
