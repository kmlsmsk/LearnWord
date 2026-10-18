import 'package:flutter/material.dart';
import '../models/word.dart';
import '../data/osym_word_database.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'word_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ProgressService _progressService = ProgressService();
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _progressService.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    _progressService.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  List<Word> get _repeatWords {
    final repeatIds = _progressService.repeatWordIds;
    return OsymWordDatabase.words.where((w) => repeatIds.contains(w.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repeatList = _repeatWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tekrar Modülü (Spaced Repetition)'),
      ),
      body: repeatList.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Banner Card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${repeatList.length} Kelime Tekrar Bekliyor',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Zorlandığınız veya testte yanlış yaptığınız kelimeler hafızanızı tazelemek için burada toplanır.',
                                    style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.brown.shade900,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.style_rounded, size: 20),
                                label: const Text('Tekrar Kartları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FlashcardScreen(
                                        words: repeatList,
                                        title: 'Özel Tekrar Oturumu',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.quiz_rounded, size: 20),
                                label: const Text('Tekrar Testi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const QuizScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pekiştirmek İstediğiniz Kelimeler',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700),
                      ),
                      Text(
                        '${repeatList.length} Adet',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // List of Words
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: repeatList.length,
                    itemBuilder: (context, index) {
                      final word = repeatList[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Pronounce Button
                                InkWell(
                                  onTap: () => _ttsService.speak(word.word),
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryPurple, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Word Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            word.word,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          if (word.pronunciation != null && word.pronunciation!.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              '[${word.pronunciation}]',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        word.meaning,
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Graduate / Learned Button
                                IconButton(
                                  icon: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 26),
                                  tooltip: 'Pekiştirdim (Tekrardan Kaldır)',
                                  onPressed: () {
                                    _progressService.removeFromRepeat(word.id);
                                    _progressService.toggleLearned(word.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('"${word.word}" başarıyla pekiştirildi ve öğrenilenlere eklendi!'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.lightYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.thumb_up_alt_rounded, size: 64, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tekrar Listesi Boş!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'Harika gidiyorsunuz! Çalışırken zorlandığınız kartlarda "Tekrar Et" butonuna dokunduğunuzda kelimeler buraya eklenir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Kelime Havuzuna Git', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
