import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightEntry {
  final double value;
  final DateTime date;

  WeightEntry(this.value, this.date);
}

class WeightManager extends ChangeNotifier {
  List<WeightEntry> _history = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<WeightEntry> get history => _history;

  // 1. LOAD DATA FROM FIREBASE (Updated to isolate RAM caches instantly)
  Future<void> loadWeightHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearLocalData(); // Clean memory cache instantly if user session goes invalid
      return;
    }

    try {
      // FIX: Purge old account elements from local memory array instantly
      _history = [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .orderBy('date', descending: false)
          .get();

      _history = snapshot.docs.map((doc) {
        final data = doc.data();
        return WeightEntry(
          (data['value'] as num?)?.toDouble() ?? 0.0,
          (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading weight: $e");
    }
  }

  // 2. SAVE/UPDATE DATA IN FIREBASE
  Future<void> addWeight(double weight) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    // Create a unique key for today (e.g., "2026-5-20")
    final String dateId = "${now.year}-${now.month}-${now.day}";
    final todayMidnight = DateTime(now.year, now.month, now.day);

    try {
      // Save to Firebase
      // Using .doc(dateId).set() automatically replaces the weight if it's the same day
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .doc(dateId)
          .set({
        'value': weight,
        'date': now, // Store full timestamp for precision
      });

      // Update Local UI List
      int existingIndex = _history.indexWhere((entry) {
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        return entryDate.isAtSameMomentAs(todayMidnight);
      });

      if (existingIndex != -1) {
        _history[existingIndex] = WeightEntry(weight, now);
      } else {
        _history.add(WeightEntry(weight, now));
      }

      _history.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving weight: $e");
    }
  }

  // Helper clear method invoked upon auth switches to clear state leaks
  void _clearLocalData() {
    _history = [];
    notifyListeners();
  }
}