import 'package:flutter/material.dart';
import '../services/reading_service.dart';
import '../theme/app_theme.dart';
import 'reading_passage_detail_screen.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  final ReadingService _readingService = ReadingService();

  @override
  void initState() {
    super.initState();
    _readingService.addListener(_onChanged);
  }

  @override
  void dispose() {
    _readingService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _showAddPassageDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final translationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.post_add_rounded, color: AppTheme.primaryPurple),
            SizedBox(width: 8),
            Text('Yeni Metin Kaydet'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Metin Başlığı',
                  hintText: 'Örn. Yapay Zeka ve Gelecek',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'İngilizce Okuma Metni',
                  hintText: 'İnternetten veya dökümanlardan kopyaladığınız İngilizce metni buraya yapıştırın...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: translationController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Türkçe Çevirisi (İsteğe Bağlı)',
                  hintText: 'Metnin Türkçe karşılığı...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                _readingService.addCustomPassage(
                  title: titleController.text.trim().isEmpty ? 'Özel Metin' : titleController.text.trim(),
                  content: contentController.text.trim(),
                  turkishTranslation: translationController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Metniniz başarıyla kaydedildi!')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passages = _readingService.passages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Okuma Parçaları'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Metin Ekle / Yapıştır', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddPassageDialog,
      ),
      body: passages.isEmpty
          ? const Center(child: Text('Kayıtlı okuma parçası bulunamadı.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: passages.length,
              itemBuilder: (context, index) {
                final item = passages[index];

                Color badgeColor = Colors.teal;
                if (item.category.contains('Sağlık')) {
                  badgeColor = Colors.red.shade700;
                } else if (item.category.contains('Fen')) {
                  badgeColor = Colors.indigo;
                } else if (item.category.contains('Sosyal')) {
                  badgeColor = Colors.deepPurple;
                } else {
                  badgeColor = Colors.orange.shade800;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadingPassageDetailScreen(passage: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (item.isCustom)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                  onPressed: () => _readingService.deletePassage(item.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.primaryPurple),
                              const SizedBox(width: 4),
                              Text(
                                'Kelimeye dokun & Sesli dinle',
                                style: TextStyle(
                                  color: AppTheme.primaryPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
