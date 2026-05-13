import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Save
  Future<void> saveNote(String title, String content) async {
    await _db.collection('users').doc(uid).collection('notes').add({
      'title': title,
      'content': content,
      'date': Timestamp.now(),
    });
  }

  // Update
  Future<void> updateNote(String id, String title, String content) async {
    await _db.collection('users').doc(uid).collection('notes').doc(id).update({
      'title': title,
      'content': content,
      'date': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteNote(String id) async {
    await _db.collection('users').doc(uid).collection('notes').doc(id).delete();
  }

  // Stream (The live connection for your UI)
  Stream<QuerySnapshot> getNotesStream() {
    return _db.collection('users').doc(uid).collection('notes')
        .orderBy('date', descending: true)
        .snapshots();
  }
}