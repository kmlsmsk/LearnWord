import 'package:flutter/material.dart';
import '../data/osym_word_database.dart';
import '../models/word.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'flashcard_screen.dart';
import 'word_list_screen.dart';
import 'word_family_screen.dart';
import 'quiz_screen.dart';
import 'word_detail_screen.dart';
import 'review_screen.dart';
import 'conjunctions_screen.dart';
import 'reading_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Word get _wordOfTheDay {
    return OsymWordDatabase.words.isNotEmpty
        ? OsymWordDatabase.words.first
        : const Word(
            id: 'fallback',
            word: 'mitigate',
            type: WordType.verb,
            level: 'C1',
            tags: ['YDS'],
            meaning: 'hafifletmek, azaltmak',
            root: WordRoot(rootWord: 'mitis', rootMeaning: 'yumuşak', explanation: ''),
            derivatives: [],
            synonyms: ['alleviate'],
            antonyms: ['exacerbate'],
            examples: [],
          );
  }

  @override
  Widget build(BuildContext context) {
    final learnedCount = _progressService.learnedCount;
    final totalWords = OsymWordDatabase.words.length;
    final progressRatio = totalWords > 0 ? (learnedCount / totalWords).clamp(0.0, 1.0) : 0.0;
    final repeatCount = _progressService.repeatCount;
    final quizPercentage = _progressService.quizTotal > 0
        ? ((_progressService.quizCorrect / _progressService.quizTotal) * 100).round()
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with 3D Logo & Streak
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).cardTheme.color,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LearnWord',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentYellow.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${_progressService.streakDays} Gün Seri',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header: Günlük Hedef & Hızlı Başla
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ÖSYM YDS • e-YDS • YÖKDİL',
                                  style: TextStyle(
                                    color: Color(0xFFFEF3C7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Akıllı Kelime Hazinesi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Öğrenilen: $learnedCount / $totalWords Kelime',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '%${(progressRatio * 100).round()}',
                              style: const TextStyle(color: AppTheme.accentYellow, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentYellow,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 24),
                            label: const Text(
                              'Hızlı Çalışmaya Başla',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlashcardScreen(
                                    words: OsymWordDatabase.words,
                                    title: 'ÖSYM Kelime Ezberi',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature Navigation Cards Grid
                  // Row 1: Flashcards & Kelime Havuzu
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavCard(
                          title: 'Flashcards',
                          subtitle: '3D Kart Çevirme',
                          icon: Icons.style_rounded,
                          color: Colors.deepPurple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlashcardScreen(words: OsymWordDatabase.words),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavCard(
                          title: 'Kelime Havuzu',
                          subtitle: '$totalWords Kelime & Arama',
                          icon: Icons.menu_book_rounded,
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WordListScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Tekrar Modülü & Bağlaçlar Modülü
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavCard(
                          title: 'Tekrar Modülü',
                          subtitle: repeatCount > 0 ? '$repeatCount Kelime Bekliyor' : 'Tazeleme & Tekrar',
                          icon: Icons.refresh_rounded,
                          color: Colors.amber.shade800,
                          badge: repeatCount > 0 ? '$repeatCount' : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReviewScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavCard(
                          title: 'Bağlaçlar Modülü',
                          subtitle: '94+ ÖSYM Bağlacı',
                          icon: Icons.link_rounded,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ConjunctionsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Okuma Parçaları & Kökten Türetme
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavCard(
                          title: 'Okuma Parçaları',
                          subtitle: 'Sesli & Baloncuk Çeviri',
                          icon: Icons.chrome_reader_mode_rounded,
                          color: Colors.blue.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReadingListScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavCard(
                          title: 'Kök & Aileler',
                          subtitle: 'Word Families',
                          icon: Icons.account_tree_rounded,
                          color: Colors.purple.shade700,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WordFamilyScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 4: ÖSYM Sınav Denemesi
                  _buildWideNavCard(
                    title: 'ÖSYM Deneme & Test Modu',
                    subtitle: 'Eş Anlamlı, Cümle İçi Boşluk Doldurma ve Türkçe Anlam Testleri',
                    icon: Icons.quiz_rounded,
                    color: Colors.orange.shade900,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Günün Kelimesi
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ÖSYM Günün Kelimesi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryPurple),
                                onPressed: () => _ttsService.speak(_wordOfTheDay.word),
                              ),
                            ],
                          ),
                          const Divider(height: 12),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _wordOfTheDay.word,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _wordOfTheDay.type.labelTr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _wordOfTheDay.meaning,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => WordDetailScreen(word: _wordOfTheDay)),
                              );
                            },
                            child: const Text('Kelime Detaylarını & Cümleyi İncele'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Öğrenilen', '$learnedCount', Icons.check_circle_rounded, AppTheme.successGreen),
                        _buildStatItem('Tekrarda', '$repeatCount', Icons.refresh_rounded, Colors.amber.shade800),
                        _buildStatItem('Test Başarısı', '%$quizPercentage', Icons.military_tech_rounded, AppTheme.primaryPurple),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Developer Signature Card (Kemal ŞİMŞEK)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LearnWord • ÖSYM Hazırlık Sistemi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Geliştirici & Tasarım: Kemal ŞİMŞEK',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'YDS • e-YDS • YÖKDİL (Sağlık, Sosyal, Fen) Kapsamı',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
