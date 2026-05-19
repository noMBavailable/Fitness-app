import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Added for responsive layout checks
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

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation for the pulsing effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start pulsing when the screen opens
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFFEEEEEE),
      // FIX: Constrains the floating pulse button location to the 450px column boundary on Web
      floatingActionButton: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 100, right: 16),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4DB).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _goToNoteEditor(),
                backgroundColor: Colors.transparent, 
                elevation: 0, 
                highlightElevation: 0,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top bar stretches across 100% of widescreen displays seamlessly
              const CustomHeader(title: "Notes"),
              
              Expanded(
                child: Center(
                  child: Container(
                    // FIX: Restricts the notes grid width to a clean 450px factor on Web browsers
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getNotesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No notes yet. Tap + to get started!"),
                          );
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
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 130),
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
                ),
              ),
            ],
          ),
          
          // Navigation Dock continues to span full widescreen layout size smoothly
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
              TextButton(
                onPressed: () {
                  widget.notesManager.deleteNote(note.id);
                  Navigator.pop(ctx);
                },
                child: const Text("Yes", style: TextStyle(color: Colors.red)),
              ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
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
              child: Text(
                note.title, 
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6), 
                child: Text(
                  note.content, 
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(6), 
              child: Text(
                DateFormat('dd/MM/yy').format(note.date), 
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}