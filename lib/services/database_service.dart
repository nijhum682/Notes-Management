import '../models/note.dart';

abstract class DatabaseService {
  // Get all notes stream
  Stream<List<Note>> getNotes();

  // Add a new note
  Future<void> addNote(Note note);

  // Update an existing note
  Future<void> updateNote(Note note);

  // Delete a note by id
  Future<void> deleteNote(String id);

  // Check if we are running in real Firebase mode or Mock mode
  bool get isMock;
}
