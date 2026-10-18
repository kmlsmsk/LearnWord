import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final isLearned = _progressService.isLearned(word.id);
    final isFavorite = _progressService.isFavorite(word.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          word.word,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : null,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _progressService.toggleFavorite(word.id);
              });
            },
          ),
          IconButton(
            icon: Icon(
              isLearned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              color: isLearned ? AppTheme.successGreen : null,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _progressService.toggleLearned(word.id);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card with 3D styled gradient
            Container(
              padding: const EdgeInsets.all(22),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          word.type.labelTr,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.25),
                        ),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 26),
                        onPressed: () => _ttsService.speak(word.word),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    word.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    word.meaning,
                    style: const TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (word.detailedMeaning != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      word.detailedMeaning!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: word.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kök ve Köken Analizi (Root / Etymology)
            _buildSectionCard(
              title: 'Kelime Kökü & Türeme Mantığı',
              icon: Icons.account_tree_rounded,
              iconColor: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.lightYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accentYellow.withOpacity(0.5)),
                        ),
                        child: Text(
                          'Kök: ${word.root.rootWord}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '("${word.root.rootMeaning}")',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.root.explanation,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Kökten Türeyen Kelimeler (Word Family / Derivatives)
            _buildSectionCard(
              title: 'Kökten Türeyen Kelimeler (Word Family)',
              icon: Icons.hub_rounded,
              iconColor: Colors.teal,
              child: Column(
                children: word.derivatives.map((deriv) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.04)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _ttsService.speak(deriv.word),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.volume_up_outlined, size: 20, color: AppTheme.primaryPurple),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    deriv.word,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      deriv.partOfSpeech,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                deriv.meaning,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Eş ve Zıt Anlamlılar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Synonyms
                Expanded(
                  child: _buildSectionCard(
                    title: 'Eş Anlamlılar',
                    icon: Icons.compare_arrows_rounded,
                    iconColor: Colors.blue,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: word.synonyms.map((syn) {
                        return InkWell(
                          onTap: () => _ttsService.speak(syn),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  syn,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.blue),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.volume_down_rounded, size: 14, color: Colors.blue),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Antonyms
                Expanded(
                  child: _buildSectionCard(
                    title: 'Zıt Anlamlılar',
                    icon: Icons.swap_horiz_rounded,
                    iconColor: Colors.redAccent,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: word.antonyms.map((ant) {
                        return InkWell(
                          onTap: () => _ttsService.speak(ant),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ant,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.redAccent),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.volume_down_rounded, size: 14, color: Colors.redAccent),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Örnek Cümleler (Examples)
            _buildSectionCard(
              title: 'ÖSYM Örnek Cümleleri ve Çevirisi',
              icon: Icons.format_quote_rounded,
              iconColor: Colors.amber.shade800,
              child: Column(
                children: word.examples.map((ex) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.withOpacity(0.2)),
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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.primaryPurple),
                              onPressed: () => _ttsService.speak(ex.english),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          ex.turkish,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            if (word.examTip != null) ...[
              const SizedBox(height: 16),
              // ÖSYM Uzman Tüyosu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentYellow, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ÖSYM Sınav Tüyosu (YDS & YÖKDİL)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.brown),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.examTip!,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
