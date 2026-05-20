import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- DATA STRUCTURE ---
// Simple object holding a specific numerical weight entry alongside its creation date
class WeightEntry {
  final double value; // The user's logged weight value in kilograms
  final DateTime date; // The timestamp of when the entry was created

  WeightEntry(this.value, this.date);
}

class WeightManager extends ChangeNotifier {
  // Local RAM array cache containing the historical weight timeline logs
  List<WeightEntry> _history = [];
  
  // Instantiates global interaction handles to core Firebase systems components
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Public getter exposing the underlying metrics array data list to UI chart viewers
  List<WeightEntry> get history => _history;

  // --- 1. DOWNLOAD HISTORY LIFECYCLE ---
  // Pulls a chronological collection tracking track record of old entries from the cloud database
  Future<void> loadWeightHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearLocalData(); // Instantly wipe cache state leaks if no user session is valid
      return;
    }

    try {
      // DATA CLEANUP FIX: Purge old memory artifacts completely before parsing new documents
      // to make sure Account B never flashes past structural logs belonging to Account A
      _history = [];

      // Query database items, ordering milestones from oldest moving forward across time tracks
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .orderBy('date', descending: false)
          .get();

      // De-serialize document field parameters back into valid local system data structures
      _history = snapshot.docs.map((doc) {
        final data = doc.data();
        return WeightEntry(
          (data['value'] as num?)?.toDouble() ?? 0.0,
          (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      notifyListeners(); // Signal data updates out to reactive listener layout cards
    } catch (e) {
      debugPrint("Error loading weight: $e");
    }
  }

  // --- 2. SAVE/UPDATE ENTRY LOGS ---
  // Synchronizes a freshly provided weight metric entry across both Firestore collections and RAM arrays
  Future<void> addWeight(double weight) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    
    // Create a precise string id stamp restricted to year-month-day parameters (e.g., "2026-5-20").
    // This allows overwrite updates if multiple records target a single calendar grid space.
    final String dateId = "${now.year}-${now.month}-${now.day}";
    final todayMidnight = DateTime(now.year, now.month, now.day);

    try {
      // Persist values straight to the cloud database paths registers mapping index layouts
      // Using .doc(dateId).set() replaces records matching today's id cleanly instead of duplicating rows
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .doc(dateId)
          .set({
        'value': weight,
        'date': now, // Preserve precision fields details internally for sorting algorithms accuracy
      });

      // Look through local memory cache to identify if a record has already run matching today's timeline
      int existingIndex = _history.indexWhere((entry) {
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        return entryDate.isAtSameMomentAs(todayMidnight);
      });

      if (existingIndex != -1) {
        // Update index placement properties details directly inline
        _history[existingIndex] = WeightEntry(weight, now);
      } else {
        // Append brand new row entries to the historical tail array
        _history.add(WeightEntry(weight, now));
      }

      // Re-sort the baseline tracking array index variables to prevent charting breaks on local changes
      _history.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving weight: $e");
    }
  }

  // --- 3. STATE CLEANUP CONTROLLER ---
  // System memory purge method dispatched automatically during app signouts routines
  void _clearLocalData() {
    _history = [];
    notifyListeners();
  }
}