import 'package:flutter/material.dart';
import '../screens/weight_graph_screen.dart';
import '../managers/weight_manager.dart';
import '../managers/nav_manager.dart';

class WeightModal extends StatefulWidget {
  final WeightManager manager;
  final NavManager navManager;

  const WeightModal({super.key, required this.manager, required this.navManager});

  @override
  State<WeightModal> createState() => _WeightModalState();
}

class _WeightModalState extends State<WeightModal> {
  // --- STATE CONTROLLERS & FLAGS ---
  final TextEditingController _controller = TextEditingController();
  bool _isConfirmed = false;     // Locks the input field if a log exists for today
  bool _showSuccessIcon = false; // Toggles the green checkmark asset visibility

  @override
  void initState() {
    super.initState();
    _checkTodayWeight(); // Evaluate historical metrics data on startup
    
    // REACTIVE SYNC LINK: Registers an active listener inside the state lifecycle.
    // If account profiles switch, this modal captures the changes in real-time.
    widget.manager.addListener(_handleWeightHistoryChange);
  }

  @override
  void dispose() {
    // Unlink global memory streams to optimize memory usage performance
    widget.manager.removeListener(_handleWeightHistoryChange);
    _controller.dispose();
    super.dispose();
  }

  // --- CROSS-USER RECOVERY RESETTER ---
  
  // Wipes active user text input metrics immediately if database log entries are flushed
  void _handleWeightHistoryChange() {
    if (!mounted) return;
    if (widget.manager.history.isEmpty) {
      setState(() {
        _controller.clear();
        _isConfirmed = false;
      });
    } else {
      _checkTodayWeight(); // Re-verify entry states with fresh historical datasets
    }
  }

  // --- CHRONOLOGICAL DATA VERIFIER ---
  
  // Inspects the active user dataset to see if an entry was already submitted today
  void _checkTodayWeight() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      // Find a matching chronological entry for the current day
      final existingEntry = widget.manager.history.firstWhere(
        (entry) {
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(today);
        },
      );

      // If found, populate text input box and toggle confirmation flags
      _controller.text = existingEntry.value.toString();
      _isConfirmed = true;
    } catch (_) {
      // If no data matches today's date, open the field blank for input entries
      _isConfirmed = false;
      _controller.clear();
    }
  }

  // --- DISPLAY INTERFACE BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Clamps vertical layout footprint boundaries tight
      children: [
        Container(
          width: 220, // Sets strict structural horizontal widths
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            children: [
              const Text(
                "Current Weight",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              // Numerical input metrics form node field
              TextField(
                controller: _controller,
                enabled: !_isConfirmed, // Disable inputs if log is confirmed
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: _isConfirmed ? FontWeight.bold : FontWeight.normal,
                  fontSize: _isConfirmed ? 22 : 16,
                  color: _isConfirmed ? Colors.blueAccent : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "kg",
                  suffixText: _isConfirmed ? "kg" : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  prefixIcon: _showSuccessIcon 
                      ? const Icon(Icons.check_circle, color: Colors.green) 
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              
              // Interaction Submit Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isConfirmed) {
                      double? value = double.tryParse(_controller.text);
                      
                      // Safety Validation Guard: Bounded boundary logic verification up to 800kg max
                      if (value != null && value > 0 && value <= 800) {
                        widget.manager.addWeight(value); // Push metrics log to Firestore
                        FocusScope.of(context).unfocus(); // Dismiss numerical keypad overlays
                        
                        setState(() {
                          _showSuccessIcon = true;
                          _isConfirmed = true;
                        });

                        // Clear visual success icon after 2 seconds automatically
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _showSuccessIcon = false);
                        });
                      } else {
                        // Throw validation snackbar warning if input breaches threshold boundaries
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid weight up to 800 kg"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // If user clicks "Change", release locks to allow data edits
                      setState(() {
                        _isConfirmed = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmed ? Colors.grey[800] : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _isConfirmed ? "Change" : "Confirm",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(),
              
              // Historical visual chart routing section
              const Text(
                "Weight History",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  // Direct navigation routing instruction pushing user into full historical charts pages
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeightGraphScreen(
                        manager: widget.manager,
                        navManager: widget.navManager,
                      ),
                    ),
                  );
                },
                child: const Text("View Graph →"),
              ),
            ],
          ),
        ),
        
        // Downward visual arrow element pointing directly into target dock anchors
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}