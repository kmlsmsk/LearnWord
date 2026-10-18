import 'package:flutter/material.dart';
import '../data/osym_word_database.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class WordFamilyScreen extends StatefulWidget {
  const WordFamilyScreen({super.key});

  @override
  State<WordFamilyScreen> createState() => _WordFamilyScreenState();
}

class _WordFamilyScreenState extends State<WordFamilyScreen> {
  final TtsService _ttsService = TtsService();

  @override
  Widget build(BuildContext context) {
    final families = OsymWordDatabase.getWordFamilies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kökten Türetme (Word Families)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Educational Explanatory Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.psychology_rounded, size: 32, color: Colors.black87),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1 Kök Ezberle, 4 Kelime Kazan!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ÖSYM sınavlarında kelimenin kökünü bilmek; fiil, isim, sıfat ve zarf türevlerini saniyeler içinde tanımanızı sağlar.',
                          style: TextStyle(color: Color(0xFFFEF3C7), fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'ÖSYM Temel Kök & Türev Grupları',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Family Cards
            ...families.map((f) {
              final rootName = f['root'] as String;
              final desc = f['description'] as String;
              final familyList = f['family'] as List<Map<String, String>>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.lightYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_tree_rounded, color: Colors.brown, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rootName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  desc,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      // Derived Words Grid / List
                      ...familyList.map((member) {
                        final word = member['word']!;
                        final pos = member['pos']!;
                        final tr = member['tr']!;

                        Color badgeColor;
                        if (pos.contains('Fiil')) {
                          badgeColor = Colors.orange;
                        } else if (pos.contains('İsim')) {
                          badgeColor = Colors.blue;
                        } else if (pos.contains('Sıfat')) {
                          badgeColor = Colors.green;
                        } else {
                          badgeColor = Colors.purple;
                        }

                        return InkWell(
                          onTap: () => _ttsService.speak(word),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_up_outlined, size: 18, color: AppTheme.primaryPurple),
                                const SizedBox(width: 8),
                                Text(
                                  word,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    pos,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  tr,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Örnek Türetme Formülü (Prefix/Suffix Quick Reference)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: AppTheme.accentYellow),
                        SizedBox(width: 8),
                        Text(
                          'Sık Çıkan Eklerle Türetme Rehberi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSuffixRow('-tion, -ment, -ance, -ity', 'Fiilden İSİM yapar', 'allocate -> allocation'),
                    _buildSuffixRow('-able, -ible, -ive, -ous', 'Fiil/İsimden SIFAT yapar', 'sustain -> sustainable'),
                    _buildSuffixRow('-ly', 'Sıfattan ZARF yapar', 'reluctant -> reluctantly'),
                    _buildSuffixRow('un-, in-, im-, dis-', 'OLUMSUZLUK katar', 'precedented -> unprecedented'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSuffixRow(String pattern, String meaning, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              pattern,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryPurple),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$meaning ($example)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
