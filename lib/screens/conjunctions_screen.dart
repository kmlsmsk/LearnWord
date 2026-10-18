import 'dart:math';
import 'package:flutter/material.dart';
import '../models/conjunction.dart';
import '../data/osym_conjunctions_database.dart';
import '../services/tts_service.dart';

class ConjunctionsScreen extends StatefulWidget {
  const ConjunctionsScreen({super.key});

  @override
  State<ConjunctionsScreen> createState() => _ConjunctionsScreenState();
}

class _ConjunctionsScreenState extends State<ConjunctionsScreen> with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();

  bool _isFlashcardMode = false;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';

  // Flashcard state
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  final List<String> _categories = [
    'Tümü',
    'Zıtlık & Karşıtlık (Contrast)',
    'Sebep & Sonuç (Cause & Effect)',
    'Koşul & Şart (Condition)',
    'Ek & İlave (Addition)',
    'Zaman (Time)',
    'Amaç (Purpose)',
    'Vurgu & Açıklama (Clarification)',
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

  List<Conjunction> get _filteredConjunctions {
    return OsymConjunctionsDatabase.conjunctions.where((c) {
      if (_selectedCategory != 'Tümü' && c.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = c.conjunction.toLowerCase().contains(q);
        final matchesTr = c.meaning.toLowerCase().contains(q);
        final matchesSyn = c.synonyms.any((s) => s.toLowerCase().contains(q));
        return matchesName || matchesTr || matchesSyn;
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

  void _nextCard(int total) {
    if (total == 0) return;
    if (_isCardFlipped) {
      _flipController.reverse();
      _isCardFlipped = false;
    }
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % total;
    });
  }

  void _prevCard(int total) {
    if (total == 0) return;
    if (_isCardFlipped) {
      _flipController.reverse();
      _isCardFlipped = false;
    }
    setState(() {
      _currentCardIndex = (_currentCardIndex - 1 + total) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConjunctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağlaçlar Modülü'),
        actions: [
          IconButton(
            tooltip: _isFlashcardMode ? 'Liste Görünümüne Geç' : 'Flashcard Kart Moduna Geç',
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
          ? _buildDedicatedFlashcardMode(filtered)
          : _buildStandardListMode(filtered),
    );
  }

  // ==========================================
  // DEDICATED FULL-SCREEN FLASHCARD MODE
  // ==========================================
  Widget _buildDedicatedFlashcardMode(List<Conjunction> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Bu kategoride bağlaç bulunamadı.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _selectedCategory = 'Tümü'),
              child: const Text('Tüm Bağlaçları Göster'),
            ),
          ],
        ),
      );
    }

    if (_currentCardIndex >= list.length) {
      _currentCardIndex = 0;
    }
    final conj = list[_currentCardIndex];

    return SafeArea(
      child: Column(
        children: [
          // Top Bar in Flashcard: Progress & Categories & Shuffle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mode return button & Counter
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.view_list_rounded, size: 16),
                      label: const Text('Listeye Dön', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
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
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentCardIndex + 1} / ${list.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D9488)),
                      ),
                    ),
                  ],
                ),

                // Shuffle button
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                  icon: const Icon(Icons.shuffle_rounded, size: 18, color: Color(0xFF0D9488)),
                  tooltip: 'Karıştır',
                  onPressed: () {
                    setState(() {
                      list.shuffle();
                      _currentCardIndex = 0;
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
                              child: _buildCardBack(conj),
                            )
                          : _buildCardFront(conj),
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Action Controls with clear responsive icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. Önceki Bağlaç
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => _prevCard(list.length),
                  tooltip: 'Önceki Bağlaç',
                ),

                // 2. Seslendir
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 26),
                  tooltip: 'Telaffuz',
                  onPressed: () => _ttsService.speakWord(conj.conjunction),
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

                // 4. Sonraki Bağlaç
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () => _nextCard(list.length),
                  tooltip: 'Sonraki Bağlaç',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STANDARD LIST MODE
  // ==========================================
  Widget _buildStandardListMode(List<Conjunction> list) {
    return Column(
      children: [
        // Mode Header Ribbon
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.hub_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 94+ Bağlaç & Sınav Kuralları',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '+ S+V ve + İsim/Ving ayrımları ve sınav püf noktaları.',
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
              hintText: 'Bağlaç veya Türkçe anlam ara...',
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

        // Category Filter Chips
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
                selectedColor: const Color(0xFF0D9488),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _currentCardIndex = 0;
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
              ? const Center(child: Text('Aradığınız kriterde bağlaç bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final conj = list[index];
                    final isSv = conj.grammarRule.contains('S+V') || conj.grammarRule.contains('S + V');
                    final String shortTag = isSv
                        ? '+ S + V'
                        : (conj.grammarRule.toLowerCase().contains('noun') || conj.grammarRule.contains('İsim')
                            ? '+ İsim / Ving'
                            : '+ Cümle');

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0D9488), size: 22),
                          onPressed: () => _ttsService.speakWord(conj.conjunction),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conj.conjunction,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F766E)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSv ? Colors.indigo.shade50 : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSv ? Colors.indigo.shade200 : Colors.amber.shade300),
                              ),
                              child: Text(
                                shortTag,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSv ? Colors.indigo.shade800 : Colors.brown.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            conj.meaning,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                        ),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        children: [
                          // Detailed Grammar Rule Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSv ? Colors.indigo.shade50 : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSv ? Colors.indigo.shade200 : Colors.amber.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.rule_rounded, size: 16, color: isSv ? Colors.indigo : Colors.brown),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Kural: ${conj.grammarRule}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSv ? Colors.indigo.shade900 : Colors.brown.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Synonyms
                          if (conj.synonyms.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Eş Anlamlılar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    conj.synonyms.join(', '),
                                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Exam Tip
                          if (conj.examTip != null && conj.examTip!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🎯 ', style: TextStyle(fontSize: 13)),
                                  Expanded(
                                    child: Text(
                                      conj.examTip!,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.brown),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Example Sentence
                          if (conj.examples.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conj.examples.first.english,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    conj.examples.first.turkish,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // FLASHCARD FRONT WIDGET
  // ==========================================
  Widget _buildCardFront(Conjunction conj) {
    final isSv = conj.grammarRule.contains('S+V') || conj.grammarRule.contains('S + V');

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50.withValues(alpha: 0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conj.category,
                style: const TextStyle(
                  color: Color(0xFF0D9488),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const Spacer(),

            // Conjunction Name
            Text(
              conj.conjunction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F766E),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Grammar Rule Chip (Wrapped cleanly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSv ? Colors.indigo.shade50 : Colors.amber.shade50,
                border: Border.all(
                  color: isSv ? Colors.indigo.shade300 : Colors.amber.shade300,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                conj.grammarRule,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isSv ? Colors.indigo.shade900 : Colors.brown.shade900,
                ),
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
                  'Anlam ve püf noktaları görmek için dokunun',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLASHCARD BACK WIDGET
  // ==========================================
  Widget _buildCardBack(Conjunction conj) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conj.conjunction,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0D9488)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 22, color: Color(0xFF0D9488)),
                    onPressed: () => _ttsService.speakWord(conj.conjunction),
                  ),
                ],
              ),
              const Divider(height: 12),

              // Turkish Meaning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Türkçe Anlamı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.teal)),
                    const SizedBox(height: 4),
                    Text(
                      conj.meaning,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Synonyms
              if (conj.synonyms.isNotEmpty) ...[
                const Text('Eş Anlamlı Bağlaçlar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: conj.synonyms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],

              // Exam Tip
              if (conj.examTip != null && conj.examTip!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯 ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          conj.examTip!,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Example Sentence
              if (conj.examples.isNotEmpty) ...[
                const Text('Örnek Cümle:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conj.examples.first.english,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        conj.examples.first.turkish,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ],
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
