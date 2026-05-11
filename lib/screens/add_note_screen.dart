import 'package:flutter/material.dart';
import '../managers/notes_manager.dart';
import '../models/note_model.dart'; // CRUCIAAL: Dit lost de 'Undefined class' error op!

class AddNoteScreen extends StatefulWidget {
  final NotesManager notesManager;
  final Note? existingNote; 

  const AddNoteScreen({super.key, required this.notesManager, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  // We gebruiken 'late' zodat we ze in initState kunnen vullen
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // Vul de controllers direct met de tekst van de bestaande notitie (als die er is)
    _titleController = TextEditingController(text: widget.existingNote?.title ?? "");
    _contentController = TextEditingController(text: widget.existingNote?.content ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final titleText = _titleController.text.trim();
    final contentText = _contentController.text.trim();

    if (titleText.isNotEmpty || contentText.isNotEmpty) {
      final finalTitle = titleText.isEmpty ? "Naamloze notitie" : titleText;

      if (widget.existingNote != null) {
        // BEWERKEN: Gebruik de updateNote functie van de manager
        widget.notesManager.updateNote(
          widget.existingNote!.id,
          finalTitle,
          contentText,
        );
      } else {
        // NIEUW: Gebruik de addNote functie
        widget.notesManager.addNote(finalTitle, contentText);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: const Text("Opslaan", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Titel",
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: Stack(
                children: [
                  // De blauwe lijntjes op de achtergrond
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LinedPaperPainter(),
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 18, 
                      height: 1.66, // Matcht de hoogte van de lijntjes
                    ),
                    decoration: const InputDecoration(
                      hintText: "Begin met typen...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Vergeet de Painter niet onderaan het bestand te zetten!
class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..strokeWidth = 1.0;

    const double step = 30.0; 
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}