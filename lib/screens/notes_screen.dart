import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../managers/nav_manager.dart';
import '../managers/notes_manager.dart';
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
  
  // Functie om naar het schrijfscherrm te gaan (Nieuw of Bewerken)
  void _goToNoteEditor({Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          notesManager: widget.notesManager,
          existingNote: note, // Als dit null is, is het een nieuwe notitie
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
          onPressed: () => _goToNoteEditor(), // Nieuwe notitie
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
                child: ListenableBuilder(
                  listenable: widget.notesManager,
                  builder: (context, _) {
                    final notes = widget.notesManager.notes;
                    if (notes.isEmpty) return const Center(child: Text("Nog geen notities."));
                    
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
                  }
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
    // InkWell maakt het blokje klikbaar met een visueel effect
    return InkWell(
      onTap: () => _goToNoteEditor(note: note), // Open bestaande notitie
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 4,
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // De titelbalk (Rounded top)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), 
                  topRight: Radius.circular(15)
                ),
              ),
              child: Text(
                note.title, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold
                ), 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // De inhoud tekst
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  note.content, 
                  style: const TextStyle(fontSize: 10, color: Colors.black87), 
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // De datum onderaan
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                DateFormat('dd/MM/yy').format(note.date), 
                style: const TextStyle(fontSize: 8, color: Colors.grey)
              ),
            ),
          ],
        ),
      ),
    );
  }
}