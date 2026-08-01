import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'database_service.dart';

class MockDatabaseService implements DatabaseService {
  final List<Note> _notes = [];
  final StreamController<List<Note>> _controller = StreamController<List<Note>>.broadcast();
  final _uuid = const Uuid();

  MockDatabaseService() {
    // Populate some initial gorgeous mock notes
    final now = DateTime.now();
    _notes.addAll([
      Note(
        id: _uuid.v4(),
        title: 'Welcome to Premium Notes! 🚀',
        description: 'An offline-first, beautifully styled dashboard designed to make note-taking quick and elegant. Connect Firebase to sync your notes with the cloud!',
        colorValue: 0xFF1E3A8A, // Deep Blue
        category: 'Ideas',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      Note(
        id: _uuid.v4(),
        title: 'Flutter Mesh Gradient Design 🎨',
        description: 'Research how to draw smooth animated radial blobs using CustomPainter in Flutter to create awesome dynamic glassmorphic backgrounds.',
        colorValue: 0xFF581C87, // Royal Purple
        category: 'Work',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Note(
        id: _uuid.v4(),
        title: 'Weekly Groceries & Snacks 🥑',
        description: 'Need to pick up:\n- Fresh avocados & tomatoes\n- Sourdough bread\n- Organic honey & coffee beans\n- Dark chocolate (85%)',
        colorValue: 0xFF064E3B, // Forest Green
        category: 'Personal',
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
    _emit();
  }

  void _emit() {
    // Sort notes: newest updated first
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _controller.add(List.unmodifiable(_notes));
  }

  @override
  Stream<List<Note>> getNotes() {
    // Run emit shortly after listening to ensure listeners get current list
    Timer.run(_emit);
    return _controller.stream;
  }

  @override
  Future<void> addNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    final newNote = note.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.add(newNote);
    _emit();
  }

  @override
  Future<void> updateNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
      _emit();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network latency
    _notes.removeWhere((n) => n.id == id);
    _emit();
  }

  @override
  bool get isMock => true;
}
