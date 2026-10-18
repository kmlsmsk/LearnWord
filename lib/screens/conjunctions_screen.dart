import 'package:flutter/material.dart';
import '../models/conjunction.dart';
import '../data/osym_conjunctions_database.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class ConjunctionsScreen extends StatefulWidget {
  const ConjunctionsScreen({super.key});

  @override
  State<ConjunctionsScreen> createState() => _ConjunctionsScreenState();
}

class _ConjunctionsScreenState extends State<ConjunctionsScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Tümü';
  String _searchQuery = '';

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
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConjunctions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ÖSYM Bağlaçlar Modülü'),
      ),
      body: Column(
        children: [
          // Informational Banner
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
                  color: Colors.teal.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.link_rounded, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sınavın Bel Kemiği: Bağlaçlar',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'YDS & YÖKDİL\'de Cümle Tamamlama ve Paragraf sorularının en az %40\'ı doğru bağlaç ve gramer kuralıyla çözülür.',
                        style: TextStyle(color: Color(0xFFCCFBF1), fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Bağlaç, Türkçe anlam veya eş anlamlı ara...',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  borderSide: const BorderSide(color: Colors.teal, width: 2),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Horizontal Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: Colors.teal.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.teal.shade900 : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} bağlaç listeleniyor',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // List of Conjunctions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name + TTS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.conjunction,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: TextStyle(
                                      color: Colors.teal.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: Colors.teal),
                              onPressed: () => _ttsService.speak(item.conjunction),
                            ),
                          ],
                        ),

                        // Meaning
                        Text(
                          item.meaning,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),

                        const SizedBox(height: 8),

                        // Grammar Rule (Crucial for ÖSYM exams!)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.rule_rounded, size: 16, color: Colors.brown),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Gramer Kuralı: ${item.grammarRule}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.brown.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Synonyms
                        if (item.synonyms.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Eş Anlamlıları: ',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: item.synonyms.map((s) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        s,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Example Sentence
                        if (item.examples.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.04)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.examples.first.english,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_outlined, size: 18, color: Colors.teal),
                                      onPressed: () => _ttsService.speak(item.examples.first.english),
                                    ),
                                  ],
                                ),
                                const Divider(height: 12),
                                Text(
                                  item.examples.first.turkish,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (item.examTip != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.examTip!,
                                  style: TextStyle(fontSize: 11, color: Colors.orange.shade900, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
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
}
