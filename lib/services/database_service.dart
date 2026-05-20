import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // FIX: Safe getter that returns null if nobody is logged in, rather than crashing with an exclamation mark (!)
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Save
  Future<void> saveNote(String title, String content) async {
    final currentUid = uid;
    if (currentUid == null) return; // Guard clause against null crashes

    await _db.collection('users').doc(currentUid).collection('notes').add({
      'title': title,
      'content': content,
      'date': Timestamp.now(),
    });
  }

  // Update
  Future<void> updateNote(String id, String title, String content) async {
    final currentUid = uid;
    if (currentUid == null) return;

    await _db.collection('users').doc(currentUid).collection('notes').doc(id).update({
      'title': title,
      'content': content,
      'date': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteNote(String id) async {
    final currentUid = uid;
    if (currentUid == null) return;

    await _db.collection('users').doc(currentUid).collection('notes').doc(id).delete();
  }

  // Stream (The live connection for your UI)
  Stream<QuerySnapshot> getNotesStream() {
    final currentUid = uid;
    if (currentUid == null) {
      // FIX: Return an empty stream safely if no one is logged in yet, instead of throwing an error
      return const Stream.empty(); 
    }

    return _db.collection('users').doc(currentUid).collection('notes')
        .orderBy('date', descending: true)
        .snapshots();
  }
}