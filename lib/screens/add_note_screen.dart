import 'package:flutter/material.dart';
import '../managers/notes_manager.dart';
import '../models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final NotesManager notesManager;
  final Note? existingNote; 

  const AddNoteScreen({super.key, required this.notesManager, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
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

    // Prevent saving completely empty notes
    if (titleText.isEmpty && contentText.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final finalTitle = titleText.isEmpty ? "Nameless note" : titleText;

    if (widget.existingNote != null) {
      // UPDATE existing note in Firebase
      widget.notesManager.updateNote(
        widget.existingNote!.id,
        finalTitle,
        contentText,
      );
    } else {
      // ADD new note to Firebase
      widget.notesManager.addNote(finalTitle, contentText);
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
            child: const Text("Save", 
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
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: Stack(
                children: [
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
                      height: 1.66, 
                    ),
                    decoration: const InputDecoration(
                      hintText: "Start writing...",
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

class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    const double step = 30.0; 
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}