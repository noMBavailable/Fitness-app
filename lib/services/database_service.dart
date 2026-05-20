import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  // Instantiates the primary global reference access instance hook to Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // --- USER VALIDATION HELPER ---
  
  // Null-safe getter that returns the current authenticated user's unique identification key.
  // Using conditional chaining (?.) prevents application crashes during logout operations.
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // --- DATABASE OPERATIONS (CRUD) ---

  // CREATE: Appends a completely new note data payload sheet map into the active user's sub-collection
  Future<void> saveNote(String title, String content) async {
    final currentUid = uid;
    if (currentUid == null) return; // Guard clause: Exit gracefully if transaction hits unauthenticated states

    await _db.collection('users').doc(currentUid).collection('notes').add({
      'title': title,
      'content': content,
      'date': Timestamp.now(), // Saves the exact creation server runtime timestamp
    });
  }

  // UPDATE: Modifies the string attributes of a specific targeted note document snapshot entry
  Future<void> updateNote(String id, String title, String content) async {
    final currentUid = uid;
    if (currentUid == null) return; // Guard clause: Safety check preventing null errors

    await _db.collection('users').doc(currentUid).collection('notes').doc(id).update({
      'title': title,
      'content': content,
      'date': Timestamp.now(), // Overwrites entry date to reflect the latest edit timestamp
    });
  }

  // DELETE: Strips a targeted note document completely out of the remote database collection map variables
  Future<void> deleteNote(String id) async {
    final currentUid = uid;
    if (currentUid == null) return; // Guard clause: Validates active connection session states

    await _db.collection('users').doc(currentUid).collection('notes').doc(id).delete();
  }

  // --- REAL-TIME STREAMING ---

  // READ (STREAM): Establishes a live connection funnel to pass database changes straight to the UI view layers
  Stream<QuerySnapshot> getNotesStream() {
    final currentUid = uid;
    if (currentUid == null) {
      // Returns a safe empty placeholder line pipeline stream to bypass listener compilation crashes on user logs out
      return const Stream.empty(); 
    }

    // Connects directly to data pathways, organizing results chronologically from newest down to oldest entries
    return _db.collection('users').doc(currentUid).collection('notes')
        .orderBy('date', descending: true)
        .snapshots(); // Emits fresh list datasets automatically whenever changes happen in the cloud database
  }
}