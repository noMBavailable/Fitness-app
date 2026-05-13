import 'package:flutter/material.dart';
import '../models/note_model.dart';
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

/*
 final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
      date: DateTime.now(),
    );
    _notes.insert(0, newNote); // Adds to the top of the list
    notifyListeners();
  }

  // NIEUW: Functie om een bestaande notitie bij te werken
  void updateNote(String id, String newTitle, String newContent) {
    // Zoek de index van de notitie met het juiste ID
    final index = _notes.indexWhere((note) => note.id == id);
    
    if (index != -1) {
      _notes[index] = Note(
        id: id, // holds original ID to keep it consistent
        title: newTitle,
        content: newContent,
        date: DateTime.now(), // Update the date to now since it's being edited
      );
      notifyListeners(); 
    }
  }

  void deleteNote(String id) { // not used yet, but will be needed for the delete functionality
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }





*/