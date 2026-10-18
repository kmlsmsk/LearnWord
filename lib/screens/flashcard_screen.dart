import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Word> words;
  final String title;

  const FlashcardScreen({
    super.key,
    required this.words,
    this.title = 'Günlük Kelime Ezberi',
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();

  int _currentIndex = 0;
  bool _isFront = true;
  late List<Word> _studyList;

  @override
  void initState() {
    super.initState();
    _studyList = List.from(widget.words);
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);

    // Speak initial word
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_studyList.isNotEmpty) {
        _ttsService.speak(_studyList[_currentIndex].word);
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _nextWord(bool learned) {
    if (_studyList.isEmpty) return;

    final currentWord = _studyList[_currentIndex];
    if (learned) {
      if (!_progressService.isLearned(currentWord.id)) {
        _progressService.toggleLearned(currentWord.id);
      }
    } else {
      _progressService.addToRepeat(currentWord.id);
    }

    if (_currentIndex < _studyList.length - 1) {
      if (!_isFront) {
        _flipController.reverse();
        _isFront = true;
      }
      setState(() {
        _currentIndex++;
      });
      _ttsService.speak(_studyList[_currentIndex].word);
    } else {
      // Completed round
      _showCompletionDialog();
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      if (!_isFront) {
        _flipController.reverse();
        _isFront = true;
      }
      setState(() {
        _currentIndex--;
      });
      _ttsService.speak(_studyList[_currentIndex].word);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Tebrikler!'),
          ],
        ),
        content: const Text(
          'Bu çalışma oturumundaki tüm kelimeleri tamamladınız. Günlük serinizi korudunuz!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _studyList.shuffle();
                if (!_isFront) {
                  _flipController.reverse();
                  _isFront = true;
                }
              });
              _ttsService.speak(_studyList[0].word);
            },
            child: const Text('Yeniden Karıştır & Çalış'),
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
    if (_studyList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Çalışılacak kelime bulunamadı.')),
      );
    }

    final currentWord = _studyList[_currentIndex];
    final isFavorite = _progressService.isFavorite(currentWord.id);
    final isLearned = _progressService.isLearned(currentWord.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _progressService.toggleFavorite(currentWord.id);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Karıştır',
            onPressed: () {
              setState(() {
                _studyList.shuffle();
                _currentIndex = 0;
                if (!_isFront) {
                  _flipController.reverse();
                  _isFront = true;
                }
              });
              _ttsService.speak(_studyList[0].word);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kelime ${_currentIndex + 1} / ${_studyList.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLearned ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLearned ? 'Öğrenildi' : 'Çalışılıyor',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isLearned ? Colors.green : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _studyList.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),

            // 3D Flipping Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isUnder = angle > (pi / 2);

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 3D Perspective
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isUnder
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildCardBack(currentWord),
                              )
                            : _buildCardFront(currentWord),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Action Controls with responsive icon buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Önceki Kelime Button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: _currentIndex > 0 ? _previousWord : null,
                    tooltip: 'Önceki Kelime',
                  ),

                  // Tekrar Et (Repeat) Icon Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 26),
                    tooltip: 'Tekrar Et',
                    onPressed: () => _nextWord(false),
                  ),

                  // Seslendir (Audio) Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.accentYellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.all(16),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.volume_up_rounded, size: 28),
                    tooltip: 'Telaffuz',
                    onPressed: () => _ttsService.speak(currentWord.word),
                  ),

                  // Öğrendim (Learned) Icon Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 26),
                    tooltip: 'Öğrendim',
                    onPressed: () => _nextWord(true),
                  ),

                  // Sonraki Kelime Button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    onPressed: _currentIndex < _studyList.length - 1 ? () => _nextWord(true) : null,
                    tooltip: 'Sonraki Kelime',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Front Widget
  Widget _buildCardFront(Word word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word.type.labelTr,
                  style: const TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                word.level,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          // Main Word Display
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          // Audio icon prompt
          InkWell(
            onTap: () => _ttsService.speak(word.word),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: AppTheme.primaryPurple, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Telaffuzu Dinle',
                    style: TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Root clue on front (non-overflowing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_tree_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    word.root.rootMeaning.isNotEmpty
                        ? 'Kök: ${word.root.rootWord} (${word.root.rootMeaning})'
                        : 'Kök: ${word.root.rootWord}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tap to flip prompt
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded, size: 18, color: Colors.grey),
              SizedBox(width: 6),
              Text(
                'Anlamı ve türevleri görmek için dokunun',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card Back Widget
  Widget _buildCardBack(Word word) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppTheme.accentYellow,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Anlam & Analiz',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Meaning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                word.meaning,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Derivatives / Word Family Box
            const Text(
              'Türeyen Kelimeler (Word Family):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 4),
            ...word.derivatives.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right_rounded, size: 16, color: AppTheme.primaryPurple),
                    Text(
                      '${d.word} (${d.partOfSpeech}): ',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        d.meaning,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Synonyms & Antonyms
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Eş Anlamlılar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue)),
                      const SizedBox(height: 2),
                      Text(word.synonyms.take(3).join(', '), style: const TextStyle(fontSize: 11, color: Colors.blue)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Zıt Anlamlılar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.redAccent)),
                      const SizedBox(height: 2),
                      Text(word.antonyms.take(3).join(', '), style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Example Sentence
            if (word.examples.isNotEmpty) ...[
              Text(
                'Örnek: "${word.examples.first.english}"',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Çeviri: ${word.examples.first.turkish}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
