import 'package:flutter/material.dart';
import '../managers/notes_manager.dart';
import '../models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final NotesManager notesManager;
  final Note? existingNote; // If provided, we are in Edit Mode. If null, we are in Create Mode.

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
    // Initialize controllers with existing note content if editing, otherwise start blank
    _titleController = TextEditingController(text: widget.existingNote?.title ?? "");
    _contentController = TextEditingController(text: widget.existingNote?.content ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Handles saving logic for both new and existing notes
  void _saveNote() {
    final titleText = _titleController.text.trim();
    final contentText = _contentController.text.trim();

    // Guard clause: Prevent saving if both fields are entirely empty
    if (titleText.isEmpty && contentText.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // Fallback title text if the user leaves the title blank
    final finalTitle = titleText.isEmpty ? "Nameless note" : titleText;

    if (widget.existingNote != null) {
      // UPDATE Mode: Modify existing database document in Firebase
      widget.notesManager.updateNote(
        widget.existingNote!.id,
        finalTitle,
        contentText,
      );
    } else {
      // CREATE Mode: Append a completely new document to the user's collection in Firebase
      widget.notesManager.addNote(finalTitle, contentText);
    }
    
    Navigator.pop(context); // Return back to the notes list view
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
          onPressed: () => Navigator.pop(context), // Dismiss without saving
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
            // Title Input field
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 2),
            
            // Content Input field with lined paper backdrop effect
            Expanded(
              child: Stack(
                children: [
                  // Layer 1: Draws the horizontal lines onto the canvas background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LinedPaperPainter(),
                    ),
                  ),
                  // Layer 2: The transparent text entry box aligned directly on top of the drawn lines
                  TextField(
                    controller: _contentController,
                    maxLines: null, // Stretches automatically down the page vertically
                    style: const TextStyle(
                      fontSize: 18, 
                      height: 1.66, // Matches the text line-height directly to the 30px custom paint step boundaries
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

// Custom painter that draws horizontal lines to look like standard notebook paper
class LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15) // Soft blue ink look
      ..strokeWidth = 1.0;

    const double step = 30.0; // Distance between each line in pixels
    
    // Loop down the entire vertical height of the container drawing straight lines
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  // Static configuration pattern: No state variables exist here to trigger repaints
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}