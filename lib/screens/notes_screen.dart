import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../managers/nav_manager.dart';
import '../managers/notes_manager.dart';
import '../services/database_service.dart'; 
import '../widgets/swipe_nav_dock.dart';
import '../widgets/custom_header.dart';
import '../models/note_model.dart';
import 'add_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final NavManager navManager;
  final NotesManager notesManager;

  const NotesScreen({super.key, required this.navManager, required this.notesManager});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final DatabaseService _dbService = DatabaseService();

  void _goToNoteEditor({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          notesManager: widget.notesManager,
          existingNote: note,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () => _goToNoteEditor(),
          backgroundColor: const Color(0xFF1A1A1A),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const CustomHeader(title: "Notities"),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _dbService.getNotesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No notes yet. Tap the + to add your first note!"));
                    }

                    final notes = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Note(
                        id: doc.id,
                        title: data['title'] ?? '',
                        content: data['content'] ?? '',
                        date: (data['date'] as Timestamp).toDate(),
                      );
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) => _buildNoteCard(notes[index]),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return InkWell(
      onTap: () => _goToNoteEditor(note: note),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Remove note?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
              TextButton(
                onPressed: () {
                  widget.notesManager.deleteNote(note.id);
                  Navigator.pop(ctx);
                },
                child: const Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Text(note.title, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
            Expanded(child: Padding(padding: const EdgeInsets.all(6), child: Text(note.content, style: const TextStyle(fontSize: 10)))),
            Padding(padding: const EdgeInsets.all(6), child: Text(DateFormat('dd/MM/yy').format(note.date), style: const TextStyle(fontSize: 8, color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}