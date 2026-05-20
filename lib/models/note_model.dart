// --- DATA MODEL ---
// Represents a single note instance containing title, body text, and its timestamp log.
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}