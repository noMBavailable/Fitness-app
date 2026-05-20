import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for responsive layout checks
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
  final DatabaseService _dbService = DatabaseService(); // Connects UI elements directly to Firestore network services
  
  // --- ANIMATION SYSTEM STATE ---
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configures a cyclic pulsing timeline framework for the primary adding shortcut button
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Creates a smooth bouncing scale transition that scales up to 1.15x size and returns to normal
    _pulseAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Wait briefly for layout builds to finish before starting the loop animation safely
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Kill active animation rendering loop to save battery
    super.dispose();
  }

  // --- NAVIGATION ROUTING TRIGGER ---
  
  // Routes page context tree to the note workspace screen (Handles both new creation and existing document editing paths)
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

  // --- PRIMARY SCROLL VIEW TREE BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      
      // Floating Addition Button container layout rules
      floatingActionButton: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450), // Aligns the button perfectly within the web layout row bounds
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(bottom: 100, right: 16),
          child: ScaleTransition(
            scale: _pulseAnimation, // Binds the looping scale vector animation
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
                onPressed: () => _goToNoteEditor(), // Launches the blank note creation panel
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
              const CustomHeader(title: "Notes"), // Spans full window workspace grid width
              
              Expanded(
                child: Center(
                  child: Container(
                    // Web lock restriction: Restricts notes preview layout view to a tidy 450px columns width on browser targets
                    constraints: BoxConstraints(maxWidth: kIsWeb ? 450 : double.infinity),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getNotesStream(), // Connects directly to reactive live Firestore data feeds channel paths
                      builder: (context, snapshot) {
                        // Display progress wheel icon if data query pipelines are active
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        // Fallback layout template if snapshot collection references return empty maps
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No notes yet. Tap + to get started!"),
                          );
                        }

                        // Map text and raw timestamp properties from individual Firestore document instances cleanly into Note objects
                        final notes = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Note(
                            id: doc.id,
                            title: data['title'] ?? '',
                            content: data['content'] ?? '',
                            date: (data['date'] as Timestamp).toDate(),
                          );
                        }).toList();

                        // Main interface preview feed grid block layout configurations
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 130), // Extra space at bottom to scroll clean of the navigation dock
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Draws exactly 3 item nodes side-by-side per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8, // Sets proportional card height rules
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
          
          // Navigation Dock container placement logic rules properties matrix layout
          Align(
            alignment: const Alignment(0, 0.92),
            child: SwipeNavDock(manager: widget.navManager),
          ),
        ],
      ),
    );
  }

  // --- CARD GENERATOR SUB-FACTORY ---
  
  // Compiles individual card item elements with tap selection logic and long-press deletion triggers
  Widget _buildNoteCard(Note note) {
    return InkWell(
      onTap: () => _goToNoteEditor(note: note), // Selecting note targets existing note instance models for update edits
      onLongPress: () {
        // Display pop-up query card dialogue to verify document disposal intent actions
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Remove note?"),
            actions: [
              TextButton(
                onPressed: () {
                  widget.notesManager.deleteNote(note.id); // Triggers background delete routing methods
                  Navigator.pop(ctx); // Clear warning modal overlay screen panel
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
            // Card Title Banner block frame overlay element
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
                overflow: TextOverflow.ellipsis, // Clips leaking title text lines to trailing ellipsis strings (...)
              ),
            ),
            
            // Content Summary Preview block panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6), 
                child: Text(
                  note.content, 
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                  maxLines: 4, // Clamps description text bounds limit up to 4 lines maximum
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ),
            
            // Localized calendar tracking metadata label layer
            Padding(
              padding: const EdgeInsets.all(6), 
              child: Text(
                DateFormat('dd/MM/yy').format(note.date), // Reconfigures raw platform DateTime timestamps to a clean string
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}