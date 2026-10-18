import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grammar_topic.dart';
import '../data/osym_grammar_database.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();

  bool _isFlashcardMode = false;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';

  // Flashcard state
  int _currentTopicIndex = 0;
  bool _isCardFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final List<String> _categories = [
    'Tümü',
    'Zamanlar (Tenses)',
    'Koşul Cümleleri (Conditionals)',
    'Sıfat Cümlecikleri (Relative Clauses)',
    'İsim Cümlecikleri (Noun Clauses)',
    'Kısaltmalar (Reductions)',
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  List<GrammarTopic> get _filteredTopics {
    return OsymGrammarDatabase.topics.where((t) {
      if (_selectedCategory != 'Tümü' && t.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(q) || t.titleTr.toLowerCase().contains(q);
        final matchesExp = t.explanation.toLowerCase().contains(q);
        final matchesFormula = t.formula.toLowerCase().contains(q);
        return matchesTitle || matchesExp || matchesFormula;
      }
      return true;
    }).toList();
  }

  void _flipCard() {
    if (_isCardFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
  }

  void _nextTopic(int total) {
    if (total == 0) return;
    if (_isCardFlipped) {
      _flipController.reverse();
      _isCardFlipped = false;
    }
    setState(() {
      _currentTopicIndex = (_currentTopicIndex + 1) % total;
    });
  }

  void _prevTopic(int total) {
    if (total == 0) return;
    if (_isCardFlipped) {
      _flipController.reverse();
      _isCardFlipped = false;
    }
    setState(() {
      _currentTopicIndex = (_currentTopicIndex - 1 + total) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTopics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gramer Modülü'),
        actions: [
          IconButton(
            tooltip: _isFlashcardMode ? 'Liste Görünümüne Geç' : 'Flashcard Moduna Geç',
            icon: Icon(_isFlashcardMode ? Icons.view_list_rounded : Icons.style_rounded),
            onPressed: () {
              setState(() {
                _isFlashcardMode = !_isFlashcardMode;
                _isCardFlipped = false;
                _flipController.reset();
              });
            },
          ),
        ],
      ),
      body: _isFlashcardMode
          ? _buildDedicatedGrammarFlashcardMode(filtered)
          : _buildStandardGrammarListMode(filtered),
    );
  }

  // ==========================================
  // DEDICATED GRAMMAR FLASHCARD MODE
  // ==========================================
  Widget _buildDedicatedGrammarFlashcardMode(List<GrammarTopic> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rule_folder_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Bu kriterde gramer konusu bulunamadı.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _selectedCategory = 'Tümü'),
              child: const Text('Tüm Konuları Göster'),
            ),
          ],
        ),
      );
    }

    if (_currentTopicIndex >= list.length) {
      _currentTopicIndex = 0;
    }
    final topic = list[_currentTopicIndex];

    return SafeArea(
      child: Column(
        children: [
          // Top Control Bar in Flashcard Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.view_list_rounded, size: 16),
                      label: const Text('Listeye Dön', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isFlashcardMode = false;
                          _isCardFlipped = false;
                          _flipController.reset();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentTopicIndex + 1} / ${list.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                  icon: const Icon(Icons.shuffle_rounded, size: 18, color: Color(0xFF1E3A8A)),
                  tooltip: 'Karıştır',
                  onPressed: () {
                    setState(() {
                      list.shuffle();
                      _currentTopicIndex = 0;
                      _isCardFlipped = false;
                      _flipController.reset();
                    });
                  },
                ),
              ],
            ),
          ),

          // 3D Flipping Card (Takes full available height)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * pi;
                    final isUnder = angle > pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isUnder
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildGrammarCardBack(topic),
                            )
                          : _buildGrammarCardFront(topic),
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Action Controls with responsive icon buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Önceki Konu
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => _prevTopic(list.length),
                  tooltip: 'Önceki Konu',
                ),

                // 2. Seslendir (Örnek Cümle)
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 26),
                  tooltip: 'Örnek Cümleyi Dinle',
                  onPressed: () {
                    if (topic.examples.isNotEmpty) {
                      _ttsService.speakEnglish(topic.examples.first.english);
                    } else {
                      _ttsService.speakEnglish(topic.title);
                    }
                  },
                ),

                // 3. Kartı Çevir
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.flip_rounded, size: 26),
                  tooltip: 'Kartı Çevir',
                  onPressed: _flipCard,
                ),

                // 4. Sonraki Konu
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () => _nextTopic(list.length),
                  tooltip: 'Sonraki Konu',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STANDARD GRAMMAR LIST MODE
  // ==========================================
  Widget _buildStandardGrammarListMode(List<GrammarTopic> list) {
    return Column(
      children: [
        // Top Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.rule_folder_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gramer Rehberi & Kurallar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Zamanlar, Koşullar, Relative & Noun Clause, Kısaltmalar.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                icon: const Icon(Icons.style_rounded, color: Colors.white, size: 22),
                tooltip: 'Flashcard Kart Modu',
                onPressed: () {
                  setState(() {
                    _isFlashcardMode = true;
                    _isCardFlipped = false;
                    _flipController.reset();
                  });
                },
              ),
            ],
          ),
        ),

        // Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Gramer konusu veya kural ara...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Category Chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF1E3A8A),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _currentTopicIndex = 0;
                      _isCardFlipped = false;
                      _flipController.reset();
                    });
                  }
                },
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // List View
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Aradığınız kriterde gramer konusu bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final topic = list[index];
                    return _buildGrammarCard(topic);
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // GRAMMAR CARD FRONT (FLASHCARD)
  // ==========================================
  Widget _buildGrammarCardFront(GrammarTopic topic) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withValues(alpha: 0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                topic.category,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const Spacer(),

            // Title English
            Text(
              topic.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Title Turkish
            Text(
              topic.titleTr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            // Formula Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.functions_rounded, size: 16, color: Colors.brown),
                      SizedBox(width: 6),
                      Text(
                        'Formül & Dizilim:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.formula,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tap hint
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(
                  'Açıklama, püf noktaları ve örnekleri görmek için dokunun',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // GRAMMAR CARD BACK (FLASHCARD)
  // ==========================================
  Widget _buildGrammarCardBack(GrammarTopic topic) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.amber.shade50.withValues(alpha: 0.35)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.amber.shade400, width: 1.5),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                topic.title,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E3A8A)),
              ),
              Text(
                topic.titleTr,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 14),

              // Explanation
              Text(
                topic.explanation,
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),

              const SizedBox(height: 12),

              // Tips
              if (topic.osymTips.isNotEmpty) ...[
                const Text(
                  '🎯 Sınav Püf Noktaları:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
                ),
                const SizedBox(height: 6),
                ...topic.osymTips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],

              // Examples
              if (topic.examples.isNotEmpty) ...[
                const Divider(),
                const Text(
                  '📝 Sınav Tipi Örnek Cümleler:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ...topic.examples.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                ex.english,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF1E3A8A)),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.volume_up, size: 18, color: Colors.blue),
                              onPressed: () => _ttsService.speakEnglish(ex.english),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ex.turkish,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                        ),
                        if (ex.examNote != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '💡 Not: ${ex.examNote}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Standard List Card
  Widget _buildGrammarCard(GrammarTopic topic) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.rule_rounded, color: Color(0xFF1E3A8A), size: 22),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            topic.titleTr,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // Formula Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.functions_rounded, size: 16, color: Colors.brown),
                    SizedBox(width: 6),
                    Text(
                      'Gramer Formülü & Dizilimi:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  topic.formula,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Explanation
          Text(
            topic.explanation,
            style: const TextStyle(fontSize: 13, height: 1.45),
          ),

          const SizedBox(height: 12),

          // Sınav Püf Noktaları
          if (topic.osymTips.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🎯 Sınav Püf Noktaları:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 6),
            ...topic.osymTips.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // Examples
          if (topic.examples.isNotEmpty) ...[
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📝 Sınav Tipi Örnek Cümleler:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            ...topic.examples.map((ex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ex.english,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryPurple),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.volume_up, size: 18, color: Colors.blue),
                          onPressed: () => _ttsService.speakEnglish(ex.english),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ex.turkish,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                    ),
                    if (ex.examNote != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '💡 Not: ${ex.examNote}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
