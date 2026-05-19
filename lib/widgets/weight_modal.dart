import 'package:flutter/material.dart';
import '../screens/weight_graph_screen.dart';
import '../managers/weight_manager.dart';
import '../managers/nav_manager.dart';

class WeightModal extends StatefulWidget {
  final WeightManager manager;
  final NavManager navManager;

  const WeightModal({
    super.key,
    required this.manager,
    required this.navManager,
  });

  @override
  State<WeightModal> createState() => _WeightModalState();
}

class _WeightModalState extends State<WeightModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isConfirmed = false;
  bool _showSuccessIcon = false;

  @override
  void initState() {
    super.initState();
    _checkTodayWeight();
  }

  // Check if there is already a weight for today in the manager
  // 1. Import collection if you want firstWhereOrNull, or just use try/catch safely:
  void _checkTodayWeight() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      // Look through history for an entry matching today
      final existingEntry = widget.manager.history.firstWhere((entry) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        return entryDate.isAtSameMomentAs(today);
      });

      // If found, populate the modal state
      _controller.text = existingEntry.value.toString();
      _isConfirmed = true;
    } catch (_) {
      // No entry found for today, smoothly default to false without crashing the UI
      _isConfirmed = false;
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
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
              TextField(
                controller: _controller,
                enabled: !_isConfirmed,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: _isConfirmed
                      ? FontWeight.bold
                      : FontWeight.normal,
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isConfirmed) {
                      double? value = double.tryParse(_controller.text);
                      if (value != null) {
                        widget.manager.addWeight(value);
                        FocusScope.of(context).unfocus();

                        setState(() {
                          _showSuccessIcon = true;
                          _isConfirmed = true;
                        });

                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _showSuccessIcon = false);
                        });
                      }
                    } else {
                      setState(() {
                        _isConfirmed = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmed
                        ? Colors.grey[800]
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isConfirmed ? "Change" : "Confirm",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(),
              const Text(
                "Weight History",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
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
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
      ],
    );
  }
}
