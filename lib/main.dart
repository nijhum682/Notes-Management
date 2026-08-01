import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/mock_database_service.dart';
import 'services/firestore_service.dart';
import 'screens/notes_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseService dbService;

  try {
    if (DefaultFirebaseOptions.isConfigured) {
      // Initialize Firebase if user has provided credentials
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      dbService = FirestoreService();
      debugPrint('Firebase initialized successfully. Using Firestore.');
    } else {
      // Configuration is empty (default state), use Mock mode
      dbService = MockDatabaseService();
      debugPrint('Firebase not configured. Falling back to Mock Database.');
    }
  } catch (e) {
    // If initialization fails (e.g. offline, bad config), fallback to Mock mode
    dbService = MockDatabaseService();
    debugPrint('Firebase initialization failed: $e. Falling back to Mock Database.');
  }

  runApp(NotesApp(databaseService: dbService));
}

class NotesApp extends StatelessWidget {
  final DatabaseService databaseService;

  const NotesApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aether Notes',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF0B0F19), // Midnight background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF14B8A6),
          surface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: NotesListScreen(databaseService: databaseService),
    );
  }
}
