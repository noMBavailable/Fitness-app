import 'package:flutter/material.dart';
import '../services/database_service.dart';

class NotesManager extends ChangeNotifier {
  // Instantiates the core network database utility helper class handles
  final DatabaseService _dbService = DatabaseService();

  // --- 1. CREATE OPERATIONS PATHWAY ---
  // Forwards fresh string field inputs directly to database write pipelines
  void addNote(String title, String content) async {
    // Guard clause: Prevent creating notes that have absolutely no description text
    if (content.isEmpty) return;

    // Dispatches properties straight down network paths; Firestore creates unique random hash IDs automatically
    await _dbService.saveNote(title, content);
    
    // Manual local array insertions are unneeded here because the UI relies on an active StreamBuilder. 
    // The stream automatically catches remote addition database updates and forces a visual layout sync.
    notifyListeners();
  }

  // --- 2. UPDATE OPERATIONS PATHWAY ---
  // Modifies existing document tracking key parameters inside targeted storage slots
  void updateNote(String id, String newTitle, String newContent) async {
    await _dbService.updateNote(id, newTitle, newContent);
    notifyListeners(); // Refresh tracking frameworks contexts listeners
  }

  // --- 3. DELETE OPERATIONS PATHWAY ---
  // Purges targeted document records keys lists entries matching selected identification codes
  void deleteNote(String id) async {
    await _dbService.deleteNote(id);
    notifyListeners();
  }
}