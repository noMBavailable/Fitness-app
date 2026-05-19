import 'package:flutter/material.dart';
// import '../models/note_model.dart';
import '../services/database_service.dart';

class NotesManager extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // 1. ADD: Send to Firebase
  void addNote(String title, String content) async {
    if (content.isEmpty) return;

    // We don't need to generate a local ID anymore, Firebase does it for us
    await _dbService.saveNote(title, content);
    
    // We don't need to manually insert into a list; 
    // the StreamBuilder in the UI will see the change in the cloud and update automatically.
    notifyListeners();
  }

  // 2. UPDATE: Edit in Firebase
  void updateNote(String id, String newTitle, String newContent) async {
    await _dbService.updateNote(id, newTitle, newContent);
    notifyListeners();
  }

  // 3. DELETE: Remove from Firebase
  void deleteNote(String id) async {
    await _dbService.deleteNote(id);
    notifyListeners();
  }
}

