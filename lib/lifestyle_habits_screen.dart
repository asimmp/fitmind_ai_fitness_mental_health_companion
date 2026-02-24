import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LifestyleHabitsScreen extends StatefulWidget {
  const LifestyleHabitsScreen({super.key});

  @override
  State<LifestyleHabitsScreen> createState() => _LifestyleHabitsScreenState();
}

class _LifestyleHabitsScreenState extends State<LifestyleHabitsScreen> {
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();
  final _stepsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveHabits() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      String dateKey = DateTime.now().toIso8601String().split('T')[0];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(dateKey)
          .set({
        'water_ml': int.tryParse(_waterController.text) ?? 0,
        'sleep_hours': double.tryParse(_sleepController.text) ?? 0,
        'steps': int.tryParse(_stepsController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Habits saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving habits: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lifestyle Habits"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHabitField("Water Intake (ml)", Icons.local_drink,
                _waterController, "e.g. 2000"),
            const SizedBox(height: 16),
            _buildHabitField("Sleep Duration (hours)", Icons.bedtime,
                _sleepController, "e.g. 8"),
            const SizedBox(height: 16),
            _buildHabitField("Steps Count", Icons.directions_walk,
                _stepsController, "e.g. 5000"),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveHabits,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Daily Habits",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitField(String label, IconData icon,
      TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
