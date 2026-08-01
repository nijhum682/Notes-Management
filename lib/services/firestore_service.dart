import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final CollectionReference _notesCollection =
      FirebaseFirestore.instance.collection('notes');

  @override
  Stream<List<Note>> getNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  @override
  Future<void> addNote(Note note) async {
    // Let Firestore generate the ID, or use our own
    final docRef = _notesCollection.doc();
    final noteWithId = note.copyWith(id: docRef.id);
    await docRef.set(noteWithId.toMap());
  }

  @override
  Future<void> updateNote(Note note) async {
    await _notesCollection.doc(note.id).update(note.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  @override
  bool get isMock => false;
}
