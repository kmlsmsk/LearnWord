import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/progress_service.dart';
import 'services/tts_service.dart';
import 'services/reading_service.dart';
import 'data/osym_word_database.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations for mobile phones
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize persistence, word database, reading service and text-to-speech
  await ProgressService().init();
  await TtsService().init();
  await OsymWordDatabase.init();
  await ReadingService().init();

  runApp(const LearnWordApp());
}

class LearnWordApp extends StatelessWidget {
  const LearnWordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnWord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
