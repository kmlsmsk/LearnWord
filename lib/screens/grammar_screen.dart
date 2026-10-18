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

class _GrammarScreenState extends State<GrammarScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Tümü';
  String _searchQuery = '';

  final List<String> _categories = [
    'Tümü',
    'Zamanlar (Tenses)',
    'Koşul Cümleleri (Conditionals)',
    'Sıfat Cümlecikleri (Relative Clauses)',
    'İsim Cümlecikleri (Noun Clauses)',
    'Kısaltmalar (Reductions)',
  ];

  @override
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTopics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ÖSYM Gramer Modülü'),
      ),
      body: Column(
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÖSYM Gramer Rehberi & Kurallar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Zamanlar, Zaman Uyumu, Koşullar, Cümlecikler ve Kısaltmalar.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E3A8A),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Topics List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Aradığınız kriterde gramer konusu bulunamadı.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final topic = filtered[index];
                      return _buildGrammarCard(topic);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarCard(GrammarTopic topic) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
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
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          const SizedBox(height: 14),

          // ÖSYM Exam Tips
          if (topic.osymTips.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🎯 ÖSYM Sınav Püf Noktaları:',
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
                        '💡 Sınav Notu: ${ex.examNote}',
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
