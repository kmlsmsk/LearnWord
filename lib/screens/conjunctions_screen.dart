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
      duration: const Duration(milliseconds: 400),
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
    if (_isCardFlipped) {
      _flipController.reverse();
      _isCardFlipped = false;
    }
    setState(() {
      _currentCardIndex = (_currentCardIndex + 1) % total;
    });
  }

  void _prevCard(int total) {
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
        title: const Text('ÖSYM Bağlaçlar Modülü'),
        actions: [
          IconButton(
            tooltip: _isFlashcardMode ? 'Liste Moduna Geç' : 'Flashcard Moduna Geç',
            icon: Icon(_isFlashcardMode ? Icons.view_list_rounded : Icons.flip_to_front_rounded),
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
      body: Column(
        children: [
          // Banner & View Switcher
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
                      Text(
                        _isFlashcardMode ? '🎴 Bağlaçlar Flashcard Modu' : '📋 94+ ÖSYM Bağlaç Rehberi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _isFlashcardMode
                            ? 'Kartı çevirerek anlam, eş anlam ve sınav kurallarını pekiştirin.'
                            : '+ S+V ve + Noun/Ving kuralları ve ÖSYM sınav püf noktaları.',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mode Selector Segmented Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.list_alt_rounded, size: 18),
                  label: Text('Liste Görünümü', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.style_rounded, size: 18),
                  label: Text('Flashcard Kart Modu', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {_isFlashcardMode},
              onSelectionChanged: (set) {
                setState(() {
                  _isFlashcardMode = set.first;
                  _isCardFlipped = false;
                  _flipController.reset();
                });
              },
            ),
          ),

          // Search Box (in list mode)
          if (!_isFlashcardMode)
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0D9488),
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

          // Body: Either Flashcard Mode or List Mode
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Aradığınız kriterde bağlaç bulunamadı.'))
                : _isFlashcardMode
                    ? _buildFlashcardView(filtered)
                    : _buildListView(filtered),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FLASHCARD VIEW
  // ==========================================
  Widget _buildFlashcardView(List<Conjunction> list) {
    if (_currentCardIndex >= list.length) {
      _currentCardIndex = 0;
    }
    final conj = list[_currentCardIndex];

    return Column(
      children: [
        // Card Counter & Shuffle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kart ${_currentCardIndex + 1} / ${list.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D9488)),
              ),
              IconButton(
                tooltip: 'Karıştır',
                icon: const Icon(Icons.shuffle_rounded, size: 20),
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

        // Flip Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

        // Bottom Navigation Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                label: const Text('Önceki'),
                onPressed: () => _prevCard(list.length),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.flip_rounded, color: Colors.white, size: 20),
                label: const Text('Çevir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _flipCard,
              ),
              FilledButton.tonalIcon(
                label: const Text('Sonraki'),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onPressed: () => _nextCard(list.length),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFront(Conjunction conj) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50.withValues(alpha: 0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
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

            const SizedBox(height: 20),

            // Conjunction Name
            Text(
              conj.conjunction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F766E),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 14),

            // Grammar Rule Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: conj.grammarRule.contains('S+V') ? Colors.indigo.shade50 : Colors.amber.shade50,
                border: Border.all(
                  color: conj.grammarRule.contains('S+V') ? Colors.indigo.shade300 : Colors.amber.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Kural: ${conj.grammarRule}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: conj.grammarRule.contains('S+V') ? Colors.indigo.shade800 : Colors.brown.shade800,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TTS Speaker Button
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 26),
              onPressed: () => _ttsService.speakWord(conj.conjunction),
            ),

            const Spacer(),

            Text(
              'Anlam ve püf noktalarını görmek için dokunun 👆',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Conjunction conj) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.amber.shade50.withValues(alpha: 0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    conj.conjunction,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D9488)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFF0D9488)),
                    onPressed: () => _ttsService.speakWord(conj.conjunction),
                  ),
                ],
              ),
              const Divider(),

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
                    const SizedBox(height: 3),
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
                    return Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],

              // ÖSYM Exam Tip
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
                      const Text('🎯 ', style: TextStyle(fontSize: 14)),
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

  // ==========================================
  // LIST VIEW
  // ==========================================
  Widget _buildListView(List<Conjunction> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final conj = list[index];
        final isSv = conj.grammarRule.contains('S+V');

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: IconButton(
              icon: const Icon(Icons.volume_up, color: Color(0xFF0D9488)),
              onPressed: () => _ttsService.speakWord(conj.conjunction),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    conj.conjunction,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                    conj.grammarRule,
                    style: TextStyle(
                      fontSize: 10,
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
                style: const TextStyle(fontSize: 13, color: Colors.teal, fontWeight: FontWeight.w600),
              ),
            ),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              if (conj.synonyms.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Eş Anlamlılar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(
                      child: Text(
                        conj.synonyms.join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (conj.examTip != null && conj.examTip!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('🎯 ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          conj.examTip!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
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
                      const SizedBox(height: 2),
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
    );
  }
}
