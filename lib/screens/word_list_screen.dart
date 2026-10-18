import 'package:flutter/material.dart';
import '../models/word.dart';
import '../data/osym_word_database.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'word_detail_screen.dart';
import 'flashcard_screen.dart';

class WordListScreen extends StatefulWidget {
  final WordType? initialTypeFilter;
  final String? initialTagFilter;

  const WordListScreen({
    super.key,
    this.initialTypeFilter,
    this.initialTagFilter,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();

  int _selectedTabIndex = 0; // 0: Tüm Kelimeler, 1: Öğrenilecek 30, 2: Tekrar Edilecek
  List<Word> _learningWords = [];

  WordType? _selectedType;
  String _selectedTag = 'Tümü';
  String _searchQuery = '';

  final List<String> _tags = [
    'Tümü',
    'YDS',
    'YÖKDİL Sosyal',
    'YÖKDİL Sağlık',
    'YÖKDİL Fen',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTypeFilter;
    if (widget.initialTagFilter != null) {
      _selectedTag = widget.initialTagFilter!;
    }
    _progressService.addListener(_onProgressChanged);
    _generateLearningWords();
  }

  void _onProgressChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progressService.removeListener(_onProgressChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// 30 Kelimelik öğrenme setini oluşturur:
  /// - Öğrenilmiş kelimeleri eklemez (!isLearned)
  /// - Tekrar edilmesi gereken kelimeleri öncelikli alır (isRepeat)
  /// - Kalanı henüz öğrenilmemiş diğer rastgele kelimelerle 30'a tamamlar
  void _generateLearningWords() {
    final allWords = OsymWordDatabase.words;
    final unlearnedWords = allWords.where((w) => !_progressService.isLearned(w.id)).toList();

    final repeatWords = unlearnedWords.where((w) => _progressService.isRepeat(w.id)).toList()..shuffle();
    final otherUnlearned = unlearnedWords.where((w) => !_progressService.isRepeat(w.id)).toList()..shuffle();

    final List<Word> selected = [];
    selected.addAll(repeatWords.take(30));

    if (selected.length < 30) {
      final remainingCount = 30 - selected.length;
      selected.addAll(otherUnlearned.take(remainingCount));
    }

    setState(() {
      _learningWords = selected;
    });
  }

  List<Word> get _filteredAllWords {
    return OsymWordDatabase.words.where((word) {
      if (_selectedType != null && word.type != _selectedType) {
        return false;
      }
      if (_selectedTag != 'Tümü' && !word.tags.contains(_selectedTag)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesWord = word.word.toLowerCase().contains(query);
        final matchesMeaning = word.meaning.toLowerCase().contains(query);
        final matchesSynonym = word.synonyms.any((s) => s.toLowerCase().contains(query));
        final matchesRoot = word.root.rootWord.toLowerCase().contains(query);
        return matchesWord || matchesMeaning || matchesSynonym || matchesRoot;
      }
      return true;
    }).toList();
  }

  List<Word> get _repeatWords {
    return OsymWordDatabase.words.where((word) {
      return _progressService.isRepeat(word.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repeatCount = _progressService.repeatCount;
    final totalCount = OsymWordDatabase.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Öğrenme & Havuz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.style_rounded),
            tooltip: 'Flashcard Kart Modu',
            onPressed: () {
              List<Word> targetList;
              String title;
              if (_selectedTabIndex == 1) {
                targetList = _learningWords;
                title = 'Öğrenilecek 30 Kelime';
              } else if (_selectedTabIndex == 2) {
                targetList = _repeatWords;
                title = 'Tekrar Edilecek Kelimeler';
              } else {
                targetList = _filteredAllWords;
                title = 'Tüm Kelimeler';
              }

              if (targetList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Çalışılacak kelime bulunamadı.')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashcardScreen(
                    words: targetList,
                    title: title,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Navigation Tabs
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  index: 0,
                  title: 'Tüm Kelimeler',
                  badge: '$totalCount',
                  icon: Icons.all_inclusive_rounded,
                ),
                _buildSegmentTab(
                  index: 1,
                  title: 'Öğrenilecek',
                  badge: '${_learningWords.length}',
                  icon: Icons.lightbulb_rounded,
                ),
                _buildSegmentTab(
                  index: 2,
                  title: 'Tekrar',
                  badge: '$repeatCount',
                  icon: Icons.replay_rounded,
                  badgeColor: repeatCount > 0 ? Colors.orange : null,
                ),
              ],
            ),
          ),

          // Content body based on active tab
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildAllWordsTab(),
                _buildLearningWordsTab(),
                _buildRepeatWordsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab({
    required int index,
    required String title,
    required String badge,
    required IconData icon,
    Color? badgeColor,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? AppTheme.primaryPurple : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppTheme.primaryPurple : const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (badgeColor ?? AppTheme.primaryPurple).withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (badgeColor ?? AppTheme.primaryPurple)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: TÜM KELİMELER (All Words)
  // ==========================================
  Widget _buildAllWordsTab() {
    final filtered = _filteredAllWords;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kelime, anlam, kök veya eş anlamlı ara...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryPurple),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),

        // Word Types Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              _buildTypeChip(label: 'Tüm Türler', type: null),
              _buildTypeChip(label: 'Fiil (v.)', type: WordType.verb),
              _buildTypeChip(label: 'İsim (n.)', type: WordType.noun),
              _buildTypeChip(label: 'Sıfat (adj.)', type: WordType.adjective),
              _buildTypeChip(label: 'Zarf (adv.)', type: WordType.adverb),
              _buildTypeChip(label: 'Phrasal Verb', type: WordType.phrasalVerb),
            ],
          ),
        ),

        // Exam Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: _tags.map((tag) {
              final isSelected = _selectedTag == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                  selectedColor: AppTheme.primaryPurple,
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryPurple : const Color(0xFFCBD5E1),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Count and Quick Action Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} kelime listeleniyor',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.style_rounded, size: 15),
                label: Text('Flashcard (${filtered.length})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (filtered.isEmpty) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardScreen(
                        words: filtered,
                        title: 'Tüm Kelimeler (${filtered.length})',
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
            ],
          ),
        ),

        // Word List View
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'Arama kriterlerine uygun kelime bulunamadı.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildWordCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: ÖĞRENİLECEK 30 KELİME MODÜLÜ
  // ==========================================
  Widget _buildLearningWordsTab() {
    return Column(
      children: [
        // Dedicated 30-Word Study Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hedef 30 Kelime Ezber Modülü',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Öğrenilenler hariç tutulur, tekrar edilecekler önceliklendirilir.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                    tooltip: 'Yeni 30 Kelime Getir',
                    onPressed: _generateLearningWords,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.style_rounded, size: 18),
                      label: Text(
                        '30 Kelimelik Flashcard\'ı Başlat (${_learningWords.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentYellow,
                        foregroundColor: Colors.brown.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      onPressed: _learningWords.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FlashcardScreen(
                                    words: _learningWords,
                                    title: 'Öğrenilecek 30 Kelime',
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu Oturumun Kelimeleri (${_learningWords.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              InkWell(
                onTap: _generateLearningWords,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shuffle_rounded, size: 14, color: Color(0xFF4F46E5)),
                    SizedBox(width: 4),
                    Text(
                      'Yeni 30 Kelime',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Word List View
        Expanded(
          child: _learningWords.isEmpty
              ? const Center(
                  child: Text(
                    'Tebrikler! Havuzdaki tüm kelimeleri öğrendiniz.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _learningWords.length,
                  itemBuilder: (context, index) {
                    return _buildWordCard(_learningWords[index]);
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TEKRAR EDİLECEK KELİMELER MODÜLÜ
  // ==========================================
  Widget _buildRepeatWordsTab() {
    final repeatWords = _repeatWords;

    return Column(
      children: [
        // Repeat Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.replay_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tekrar Listesi (${repeatWords.length} Kelime)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          'Kartları çalışırken zorlandığınız ve "Tekrar Et" dediğiniz kelimeler.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (repeatWords.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.style_rounded, size: 18),
                        label: Text(
                          'Tekrar Flashcard\'ını Başlat (${repeatWords.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardScreen(
                                words: repeatWords,
                                title: 'Tekrar Edilecek Kelimeler',
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tekrar Bekleyen Kelimeler (${repeatWords.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),

        // Word List View
        Expanded(
          child: repeatWords.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 54, color: Colors.green.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Harika! Tekrar listeniz boş.',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kelime kartlarını çalışırken "Tekrar Et" butonuna bastığınız kelimeler burada toplanacaktır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: repeatWords.length,
                  itemBuilder: (context, index) {
                    return _buildWordCard(repeatWords[index], isRepeatTab: true);
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED WORD CARD WIDGET
  // ==========================================
  Widget _buildWordCard(Word word, {bool isRepeatTab = false}) {
    final isLearned = _progressService.isLearned(word.id);
    final isFavorite = _progressService.isFavorite(word.id);
    final isRepeat = _progressService.isRepeat(word.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WordDetailScreen(word: word),
            ),
          ).then((_) => setState(() {}));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Pronounce Button
              InkWell(
                onTap: () => _ttsService.speak(word.word),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Word & Meaning Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            word.word,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.lightYellow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.accentYellow.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            word.type.shortLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade900,
                            ),
                          ),
                        ),
                        if (isRepeat) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              'Tekrar',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      word.meaning,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Root info (Protected against horizontal overflow)
                    Row(
                      children: [
                        const Icon(Icons.account_tree_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Kök: ${word.root.rootWord}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFavorite ? Colors.amber : Colors.grey.shade400,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _progressService.toggleFavorite(word.id);
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(
                      isLearned ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isLearned ? AppTheme.successGreen : Colors.grey.shade400,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _progressService.toggleLearned(word.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip({required String label, required WordType? type}) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedType = val ? type : null;
          });
        },
        selectedColor: AppTheme.primaryPurple,
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryPurple : const Color(0xFFCBD5E1),
          ),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
