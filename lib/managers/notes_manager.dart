import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NotesManager extends ChangeNotifier {
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
}