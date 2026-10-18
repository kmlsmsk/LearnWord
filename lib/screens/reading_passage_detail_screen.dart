import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reading_passage.dart';
import '../models/word.dart';
import '../data/osym_word_database.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class ReadingPassageDetailScreen extends StatefulWidget {
  final ReadingPassage passage;

  const ReadingPassageDetailScreen({super.key, required this.passage});

  @override
  State<ReadingPassageDetailScreen> createState() => _ReadingPassageDetailScreenState();
}

class _ReadingPassageDetailScreenState extends State<ReadingPassageDetailScreen> {
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();

  late List<String> _sentences;
  int _activeSentenceIndex = -1;
  bool _isPlaying = false;
  double _speechRate = 0.45;
  bool _showTranslation = false;

  @override
  void initState() {
    super.initState();
    // Split content into clean sentences
    final regex = RegExp(r'(?<=[.!?])\s+');
    _sentences = widget.passage.content.split(regex).where((s) => s.trim().isNotEmpty).toList();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _startReading([int startIndex = 0]) async {
    setState(() {
      _isPlaying = true;
      _activeSentenceIndex = startIndex;
    });

    for (int i = startIndex; i < _sentences.length; i++) {
      if (!_isPlaying) break;

      setState(() {
        _activeSentenceIndex = i;
      });

      final sentence = _sentences[i];
      await _ttsService.speak(sentence);

      // Estimated duration based on word count & speech rate
      final wordCount = sentence.split(' ').length;
      final durationMs = (wordCount * 450 * (0.5 / _speechRate)).round();
      await Future.delayed(Duration(milliseconds: durationMs));
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _activeSentenceIndex = -1;
      });
    }
  }

  void _pauseReading() {
    _ttsService.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _showWordLookupModal(String tappedWord) {
    // Clean punctuation from word
    final cleanWord = tappedWord.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    if (cleanWord.isEmpty) return;

    // Search in our 1720+ ÖSYM word database
    Word? match;
    for (var w in OsymWordDatabase.words) {
      if (w.word.toLowerCase() == cleanWord) {
        match = w;
        break;
      }
    }

    // If not exact match, search stem / root or contains
    if (match == null) {
      for (var w in OsymWordDatabase.words) {
        if (cleanWord.startsWith(w.word.toLowerCase()) || w.word.toLowerCase().startsWith(cleanWord)) {
          match = w;
          break;
        }
      }
    }

    final isRepeat = match != null ? _progressService.isRepeat(match.id) : false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Word and Pronunciation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match != null ? match.word : tappedWord,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          if (match?.pronunciation != null && match!.pronunciation!.isNotEmpty)
                            Text(
                              '[${match.pronunciation}]',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.accentYellow,
                          foregroundColor: Colors.black87,
                        ),
                        icon: const Icon(Icons.volume_up_rounded, size: 24),
                        onPressed: () => _ttsService.speak(match != null ? match.word : cleanWord),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Meaning Container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                match != null ? match.type.labelTr : 'Kelime',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          match != null ? match.meaning : 'Bu kelime metin bağlamında akademik olarak kullanılmaktadır.',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),

                  if (match != null && match.synonyms.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Eş Anlamlılar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Expanded(
                          child: Text(
                            match.synonyms.take(4).join(', '),
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Button: Add to Repeat list
                  if (match != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRepeat ? Colors.orange.shade800 : AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(isRepeat ? Icons.check_rounded : Icons.refresh_rounded),
                      label: Text(
                        isRepeat ? 'Tekrar Modülüne Eklendi' : 'Tekrar Modülüme Ekle',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setModalState(() {
                          _progressService.toggleRepeat(match!.id);
                        });
                        setState(() {});
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.passage.title),
        actions: [
          IconButton(
            icon: Icon(
              _showTranslation ? Icons.translate_rounded : Icons.g_translate_outlined,
              color: _showTranslation ? Colors.teal : null,
            ),
            tooltip: 'Türkçe Çeviriyi Göster/Gizle',
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Audio Speed and Control Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  // Play / Pause Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.orange : AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    onPressed: () {
                      if (_isPlaying) {
                        _pauseReading();
                      } else {
                        _startReading(_activeSentenceIndex >= 0 ? _activeSentenceIndex : 0);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.stop_rounded),
                    onPressed: () {
                      _pauseReading();
                      setState(() {
                        _activeSentenceIndex = -1;
                      });
                    },
                  ),
                  const Spacer(),
                  // Speed selector
                  const Text('Hız:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 4),
                  DropdownButton<double>(
                    value: _speechRate,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0.35, child: Text('0.35x (Yavaş)', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 0.45, child: Text('0.45x (Öğrenme)', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 0.60, child: Text('0.60x (Akıcı)', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 0.75, child: Text('0.75x (Hızlı)', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _speechRate = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // Main Interactive Passage Reader Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reading helper tip
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.primaryPurple),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'İpucu: Anlamını ve eş anlamlısını görmek istediğiniz kelimenin üzerine dokunun.',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sentences with step-by-step active highlighting
                    ..._sentences.asMap().entries.map((entry) {
                      final sIndex = entry.key;
                      final sentence = entry.value;
                      final isCurrent = (sIndex == _activeSentenceIndex);

                      final wordsInSentence = sentence.split(' ');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppTheme.accentYellow.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent
                              ? Border.all(color: AppTheme.accentYellow, width: 1.5)
                              : null,
                        ),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: wordsInSentence.map((w) {
                            return InkWell(
                              onTap: () => _showWordLookupModal(w),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                child: Text(
                                  w,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                    color: isCurrent ? Colors.brown.shade900 : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),

                    // Optional Turkish Translation Section
                    if (_showTranslation && widget.passage.turkishTranslation.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.translate_rounded, color: Colors.teal, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Türkçe Çevirisi',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text(
                              widget.passage.turkishTranslation,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
