import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/progress_service.dart';
import '../services/translation_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _ttsService = TtsService();
  final ProgressService _progressService = ProgressService();
  final TranslationService _translationService = TranslationService();

  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _selectedAccent = 'en-US';
  String _translationProvider = 'Google Çeviri + Sınav Sözlüğü';
  String _readerFontSize = 'Normal';
  bool _isTestingTranslation = false;

  final List<Map<String, String>> _accents = [
    {'code': 'en-US', 'name': 'Amerikan İngilizcesi (en-US)'},
    {'code': 'en-GB', 'name': 'İngiliz İngilizcesi (en-GB)'},
    {'code': 'en-AU', 'name': 'Avustralya İngilizcesi (en-AU)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar & Tercihler'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Seslendirme ve Telaffuz (TTS)
          _buildSectionHeader('Seslendirme ve Telaffuz (TTS)', Icons.record_voice_over_rounded),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent Selector
                  const Text('İngilizce Aksanı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccent,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _accents.map((a) {
                      return DropdownMenuItem<String>(
                        value: a['code'],
                        child: Text(a['name']!, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedAccent = val);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Speech Rate Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Okuma Hızı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${_speechRate.toStringAsFixed(2)}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
                    ],
                  ),
                  Slider(
                    value: _speechRate,
                    min: 0.25,
                    max: 1.0,
                    divisions: 15,
                    label: '${_speechRate.toStringAsFixed(2)}x',
                    onChanged: (val) {
                      setState(() => _speechRate = val);
                      _ttsService.setSpeechRate(val);
                    },
                  ),

                  // Pitch Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ses Tonu (Pitch):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(_pitch.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
                    ],
                  ),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    label: _pitch.toStringAsFixed(1),
                    onChanged: (val) {
                      setState(() => _pitch = val);
                    },
                  ),

                  // Test Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 18),
                      label: const Text('Test Sesini Dinle'),
                      onPressed: () {
                        _ttsService.speakEnglish("Welcome to LearnWord. Master your academic vocabulary efficiently.");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section: Çeviri ve Okuma Ayarları
          _buildSectionHeader('Çeviri ve Okuma Ayarları', Icons.translate_rounded),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Varsayılan Çeviri Motoru:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _translationProvider,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Google Çeviri + Sınav Sözlüğü',
                        child: Text('Google Çeviri + Sınav Sözlüğü (Akıllı Hibrit)', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: 'Yalnızca Çevrimdışı Sınav Sözlüğü',
                        child: Text('Yalnızca Çevrimdışı Sözlük Havuzu (2000+ Kelime)', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _translationProvider = val);
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Live Network Translation Test Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isTestingTranslation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.network_check_rounded, size: 20),
                      label: Text(
                        _isTestingTranslation ? 'Bağlantı Kontrol Ediliyor...' : 'Google Çeviri Bağlantısını Test Et',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _isTestingTranslation ? null : _testTranslationConnection,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text('Okuma Metni Yazı Boyutu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Küçük', label: Text('Küçük', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'Normal', label: Text('Normal', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'Büyük', label: Text('Büyük', style: TextStyle(fontSize: 12))),
                    ],
                    selected: {_readerFontSize},
                    onSelectionChanged: (val) {
                      setState(() => _readerFontSize = val.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Section: Veri ve İlerleme Yönetimi
          _buildSectionHeader('Veri ve İlerleme', Icons.storage_rounded),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.redAccent),
              title: const Text('Tekrar Listesini Sıfırla', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('Şu anda ${_progressService.repeatCount} kelime tekrar listesinde kayıtlı.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _confirmResetRepeatList(context),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Geliştirici & Telif Hakkı
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'LearnWord v2.0',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryPurple),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Geliştirici & Tasarım: Kemal ŞİMŞEK',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  'İngilizce Dil & Sınav Uzmanı | Yazılım & UX/UI Mimarı',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryPurple),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryPurple),
          ),
        ],
      ),
    );
  }

  void _testTranslationConnection() async {
    setState(() => _isTestingTranslation = true);
    final result = await _translationService.testConnection();
    if (!mounted) return;
    setState(() => _isTestingTranslation = false);

    final bool isSuccess = result['success'] == true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: isSuccess ? Colors.green : Colors.redAccent,
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(isSuccess ? 'Bağlantı Başarılı' : 'Bağlantı Hatası'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['message']?.toString() ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Motor: ${result['source']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                      Text(
                        '${result['durationMs']} ms',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Örnek Test: ${result['sample']}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? AppTheme.primaryPurple : Colors.grey.shade700,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmResetRepeatList(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tekrar Listesi Sıfırlansın mı?'),
        content: const Text('Tekrar listesinde biriken tüm kelimeler silinecektir. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              for (var id in _progressService.repeatWordIds.toList()) {
                await _progressService.removeFromRepeat(id);
              }
              if (mounted) {
                setState(() {});
                messenger.showSnackBar(
                  const SnackBar(content: Text('Tekrar listesi sıfırlandı.')),
                );
              }
              nav.pop();
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
