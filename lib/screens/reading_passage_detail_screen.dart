import 'package:flutter/material.dart';
import '../models/reading_passage.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../services/translation_service.dart';
import '../theme/app_theme.dart';

class ReadingPassageDetailScreen extends StatefulWidget {
  final ReadingPassage passage;

  const ReadingPassageDetailScreen({
    super.key,
    required this.passage,
  });

  @override
  State<ReadingPassageDetailScreen> createState() => _ReadingPassageDetailScreenState();
}

class _ReadingPassageDetailScreenState extends State<ReadingPassageDetailScreen> {
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();
  final TranslationService _translationService = TranslationService();

  bool _isPlaying = false;
  int _activeSentenceIndex = -1;
  double _speechRate = 0.45;
  bool _showTranslation = false;

  late List<String> _sentences;

  @override
  void initState() {
    super.initState();
    _sentences = _splitIntoSentences(widget.passage.content);
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  List<String> _splitIntoSentences(String text) {
    final cleaned = text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    final rawSentences = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
    return rawSentences.where((s) => s.trim().isNotEmpty).toList();
  }

  Future<void> _startReadingFrom(int startIndex) async {
    setState(() {
      _isPlaying = true;
    });

    for (int i = startIndex; i < _sentences.length; i++) {
      if (!_isPlaying) break;

      setState(() {
        _activeSentenceIndex = i;
      });

      final sentence = _sentences[i];
      await _ttsService.speakEnglish(sentence);

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

  void _showWordLookupModal(String tappedWord, {String? sentenceContext}) {
    final cleanWord = tappedWord.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    if (cleanWord.isEmpty) return;

    final isRepeat = _progressService.isRepeat(cleanWord);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<TranslationResult>(
          future: _translationService.translateWordOrPhrase(cleanWord),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final result = snapshot.data;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header with word and TTS speaker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cleanWord,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                                if (result?.partOfSpeech != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      result!.partOfSpeech!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                            ),
                            icon: const Icon(Icons.volume_up, color: Colors.white, size: 22),
                            onPressed: () => _ttsService.speakWord(cleanWord),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Translation Body
                      if (isLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Türkçe çeviri yükleniyor...',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // Turkish Meaning Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.lightYellow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.accentYellow.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      '🇹🇷 Türkçe Anlamı:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: result?.source == 'Sınav Sözlüğü'
                                          ? Colors.green.shade100
                                          : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      result?.source ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: result?.source == 'Sınav Sözlüğü'
                                            ? Colors.green.shade800
                                            : Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result?.translation ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Synonyms
                        if (result != null && result.synonyms.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Eş Anlamlılar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Expanded(
                                child: Text(
                                  result.synonyms.take(4).join(', '),
                                  style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          // Add to repeat button
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRepeat ? Colors.grey.shade400 : AppTheme.primaryPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Icon(
                                isRepeat ? Icons.check_circle : Icons.bookmark_add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                isRepeat ? 'Tekrar Listesinde' : 'Tekrara Ekle',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onPressed: () async {
                                await _progressService.toggleRepeat(cleanWord);
                                setModalState(() {});
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _progressService.isRepeat(cleanWord)
                                            ? '"$cleanWord" Tekrar Listesi\'ne eklendi.'
                                            : '"$cleanWord" Tekrar Listesi\'nden çıkarıldı.',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _translateFullSentence(String sentence) async {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<TranslationResult>(
        future: _translationService.translateWordOrPhrase(sentence),
        builder: (ctx, snap) {
          final isWaiting = snap.connectionState == ConnectionState.waiting;
          final tr = snap.data?.translation ?? 'Çeviri yapılıyor...';

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.translate_rounded, color: AppTheme.primaryPurple, size: 22),
                SizedBox(width: 8),
                Text('Cümle Çevirisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sentence, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                const Divider(height: 20),
                if (isWaiting)
                  const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                else
                  Text('🇹🇷 $tr', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.teal)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.passage.title),
        actions: [
          IconButton(
            tooltip: _showTranslation ? 'Türkçe Çeviriyi Gizle' : 'Türkçe Çeviriyi Göster',
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.g_translate_rounded,
              color: _showTranslation ? AppTheme.accentYellow : null,
            ),
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Player Controls Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Play / Pause button
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                  icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () {
                    if (_isPlaying) {
                      _pauseReading();
                    } else {
                      final start = _activeSentenceIndex >= 0 ? _activeSentenceIndex : 0;
                      _startReadingFrom(start);
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
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.touch_app_rounded, size: 16, color: AppTheme.primaryPurple),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'İpucu: Kelimeye dokunarak anında Türkçe çevirisini (Sözlük & Google Çeviri) görün.',
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
                            ? AppTheme.accentYellow.withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrent
                            ? Border.all(color: AppTheme.accentYellow, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: wordsInSentence.map((w) {
                              return InkWell(
                                onTap: () => _showWordLookupModal(w, sentenceContext: sentence),
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
                          if (isCurrent)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.translate, size: 14),
                                label: const Text('Cümleyi Çevir', style: TextStyle(fontSize: 11)),
                                onPressed: () => _translateFullSentence(sentence),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Optional Turkish Translation Section
                  if (_showTranslation && widget.passage.turkishTranslation.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
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
                          const SizedBox(height: 10),
                          Text(
                            widget.passage.turkishTranslation,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
