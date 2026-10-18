import 'package:flutter/material.dart';
import '../data/osym_word_database.dart';
import '../data/osym_conjunctions_database.dart';
import '../models/word.dart';
import '../models/conjunction.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'word_list_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';
import 'conjunctions_screen.dart';
import 'reading_list_screen.dart';
import 'grammar_screen.dart';
import 'settings_screen.dart';
import 'word_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
  final TtsService _ttsService = TtsService();

  int _selectedNavIndex = 0;

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
            tags: ['YDS', 'YÖKDİL'],
            meaning: 'hafifletmek, azaltmak',
            root: WordRoot(rootWord: 'mitis', rootMeaning: 'yumuşak', explanation: ''),
            derivatives: [],
            synonyms: ['alleviate'],
            antonyms: ['exacerbate'],
            examples: [],
          );
  }

  Word get _randomRepeatWord {
    final repeatIds = _progressService.repeatWordIds;
    if (repeatIds.isNotEmpty) {
      final match = OsymWordDatabase.words.firstWhere(
        (w) => repeatIds.contains(w.id),
        orElse: () => OsymWordDatabase.words.length > 3 ? OsymWordDatabase.words[3] : _wordOfTheDay,
      );
      return match;
    }
    // If repeat is empty, show a recommended high-frequency word
    if (OsymWordDatabase.words.length > 10) {
      return OsymWordDatabase.words[10];
    }
    return _wordOfTheDay;
  }

  Conjunction get _featuredConjunction {
    return OsymConjunctionsDatabase.conjunctions.isNotEmpty
        ? OsymConjunctionsDatabase.conjunctions.first
        : const Conjunction(
            id: 'conj_although',
            conjunction: 'although',
            meaning: '-e rağmen, -se de, karşın',
            category: 'Zıtlık & Karşıtlık',
            type: 'Bağlaç',
            grammarRule: '+ Tam Cümle (S + V) alır.',
            synonyms: ['even though', 'though'],
            examples: [],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryPurple),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryPurple),
            label: 'Kelimeler',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded, color: Color(0xFF0D9488)),
            label: 'Bağlaçlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded, color: Colors.blue),
            label: 'Okuma',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_folder_outlined),
            selectedIcon: Icon(Icons.rule_folder_rounded, color: Color(0xFF1E3A8A)),
            label: 'Gramer',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedNavIndex) {
      case 1:
        return const WordListScreen();
      case 2:
        return const ConjunctionsScreen();
      case 3:
        return const ReadingListScreen();
      case 4:
        return const GrammarScreen();
      case 0:
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    final learnedCount = _progressService.learnedCount;
    final totalWords = OsymWordDatabase.words.length;
    final repeatCount = _progressService.repeatCount;
    final streakDays = _progressService.streakDays;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Top Header: App Branding + Streak + Settings Icon (Fixed to fit all mobile screens)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LearnWord',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          Text(
                            'YDS & YÖKDİL Hazırlık',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Streak chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentYellow.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '$streakDays G',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Settings Button (Never pushed off screen)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(7),
                      minimumSize: const Size(36, 36),
                    ),
                    icon: const Icon(Icons.settings_rounded, size: 20, color: AppTheme.primaryPurple),
                    tooltip: 'Ayarlar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quick Stats Ribbon (Compact, 0 scrolling required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPill('Kelimeler', '$totalWords', Icons.auto_awesome),
                _buildDivider(),
                _buildStatPill('Öğrenilen', '$learnedCount', Icons.check_circle_outline),
                _buildDivider(),
                _buildStatPill('Tekrar', '$repeatCount', Icons.replay_rounded, isAlert: repeatCount > 0),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 1. Word of the Day Card
          _buildWordOfTheDayCard(),

          const SizedBox(height: 10),

          // 2. Side-by-side or stacked Cards: Random Repeat Word & Featured Conjunction
          Row(
            children: [
              Expanded(child: _buildRandomRepeatWordCard()),
              const SizedBox(width: 10),
              Expanded(child: _buildFeaturedConjunctionCard()),
            ],
          ),

          const SizedBox(height: 16),

          // Modular Bento Navigation Grid
          const Text(
            'Öğrenme Modülleri',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              // 1. Kelime Havuzu & Flashcard
              _buildBentoCard(
                title: 'Kelime Havuzu',
                subtitle: '$totalWords Sınav Kelimesi',
                icon: Icons.menu_book_rounded,
                color1: const Color(0xFF6366F1),
                color2: const Color(0xFF4F46E5),
                onTap: () {
                  setState(() => _selectedNavIndex = 1);
                },
              ),

              // 2. Bağlaçlar Modülü
              _buildBentoCard(
                title: 'Bağlaçlar Rehberi',
                subtitle: '94+ Bağlaç & Flashcard',
                icon: Icons.style_rounded,
                color1: const Color(0xFF0D9488),
                color2: const Color(0xFF0F766E),
                onTap: () {
                  setState(() => _selectedNavIndex = 2);
                },
              ),

              // 3. Okuma & Dinleme
              _buildBentoCard(
                title: 'Okuma & Çeviri',
                subtitle: 'Sesli & Vurgulu Metinler',
                icon: Icons.auto_stories_rounded,
                color1: const Color(0xFF0284C7),
                color2: const Color(0xFF0369A1),
                onTap: () {
                  setState(() => _selectedNavIndex = 3);
                },
              ),

              // 4. Gramer Rehberi
              _buildBentoCard(
                title: 'Gramer Rehberi',
                subtitle: 'Zamanlar, Koşullar, Cümlecikler',
                icon: Icons.rule_folder_rounded,
                color1: const Color(0xFF1E3A8A),
                color2: const Color(0xFF1E40AF),
                onTap: () {
                  setState(() => _selectedNavIndex = 4);
                },
              ),

              // 5. Akıllı Tekrar Modülü
              _buildBentoCard(
                title: 'Tekrar Modülü',
                subtitle: repeatCount > 0 ? '$repeatCount Kelime Bekliyor' : 'Spaced Repetition',
                icon: Icons.replay_circle_filled_rounded,
                color1: const Color(0xFFEA580C),
                color2: const Color(0xFFC2410C),
                badgeText: repeatCount > 0 ? '$repeatCount' : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  );
                },
              ),

              // 6. Sınav Simülatörü
              _buildBentoCard(
                title: 'Sınav Simülatörü',
                subtitle: 'Çoktan Seçmeli Test',
                icon: Icons.quiz_rounded,
                color1: const Color(0xFF9333EA),
                color2: const Color(0xFF7E22CE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Action Pill: Flashcard EZBERE BAŞLA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: Colors.brown.shade900,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              icon: const Icon(Icons.bolt_rounded, size: 22),
              label: const Text(
                'Flashcard ile Hızlı Ezber Başlat',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FlashcardScreen(words: OsymWordDatabase.words)),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Developer Credit Signature
          Center(
            child: Column(
              children: [
                const Text(
                  'Geliştirici & Tasarım: Kemal ŞİMŞEK',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'İngilizce Dil & Sınav Uzmanı | Yazılım & UX/UI Mimarı',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon, {bool isAlert = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isAlert ? Colors.amberAccent : Colors.white70),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isAlert ? Colors.amberAccent : Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white24,
    );
  }

  // 1. Word of the Day Card
  Widget _buildWordOfTheDayCard() {
    final word = _wordOfTheDay;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.lightYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🌟 Günün Kelimesi',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        word.type.labelTr,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.primaryPurple),
                    tooltip: 'Seslendir',
                    onPressed: () => _ttsService.speakWord(word.word),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                word.word,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 2),
              Text(
                word.meaning,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Random Repeat Word Card
  Widget _buildRandomRepeatWordCard() {
    final word = _randomRepeatWord;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔁 Tekrar',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.volume_up_rounded, size: 18, color: Colors.orange.shade800),
                    onPressed: () => _ttsService.speakWord(word.word),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                word.word,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.orange.shade900),
              ),
              const SizedBox(height: 2),
              Text(
                word.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Featured Conjunction Card
  Widget _buildFeaturedConjunctionCard() {
    final conj = _featuredConjunction;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() => _selectedNavIndex = 2);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🔗 Bağlaç',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF0D9488)),
                    onPressed: () => _ttsService.speakWord(conj.conjunction),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                conj.conjunction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F766E)),
              ),
              const SizedBox(height: 2),
              Text(
                conj.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
              if (badgeText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
