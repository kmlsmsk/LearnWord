import 'package:flutter/material.dart';
import '../models/word.dart';
import '../data/osym_word_database.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'word_detail_screen.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Word> get _filteredWords {
    return OsymWordDatabase.words.where((word) {
      // Type filter
      if (_selectedType != null && word.type != _selectedType) {
        return false;
      }
      // Tag filter
      if (_selectedTag != 'Tümü' && !word.tags.contains(_selectedTag)) {
        return false;
      }
      // Search query
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Havuzu'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // Horizontal Filter Chips for Word Types
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

          // Horizontal Filter Chips for Exam Category
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    selectedColor: AppTheme.accentYellow,
                    backgroundColor: Theme.of(context).cardTheme.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black87 : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} kelime listeleniyor',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = null;
                      _selectedTag = 'Tümü';
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: const Text(
                    'Filtreleri Sıfırla',
                    style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final word = filtered[index];
                      final isLearned = _progressService.isLearned(word.id);
                      final isFavorite = _progressService.isFavorite(word.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Pronounce Button
                                InkWell(
                                  onTap: () => _ttsService.speak(word.word),
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.volume_up_rounded,
                                      color: AppTheme.primaryPurple,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Word & Meaning Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            word.word,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightYellow,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              word.type.shortLabel,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        word.meaning,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Root tag
                                      Row(
                                        children: [
                                          const Icon(Icons.account_tree_outlined, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Kök: ${word.root.rootWord}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Star and Checkmark Actions
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isFavorite ? Colors.amber : Colors.grey,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _progressService.toggleFavorite(word.id);
                                    });
                                  },
                                ),
                                Icon(
                                  isLearned ? Icons.check_circle_rounded : Icons.circle_outlined,
                                  color: isLearned ? AppTheme.successGreen : Colors.grey.shade400,
                                  size: 22,
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
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
