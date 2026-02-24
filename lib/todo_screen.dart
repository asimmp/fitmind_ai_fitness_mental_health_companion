import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/notification_service.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _taskController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> _showAddTaskDialog() async {
    _taskController.clear();
    _selectedDateTime = null;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Task',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Morning Run, Yoga...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Theme.of(c).colorScheme.primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (date == null) return;

                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: ColorScheme.light(
                            primary: Theme.of(c).colorScheme.primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (time == null) return;

                  setDState(() {
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedDateTime != null
                        ? Theme.of(ctx).colorScheme.primary.withOpacity(0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDateTime != null
                          ? Theme.of(ctx).colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        color: _selectedDateTime != null
                            ? Theme.of(ctx).colorScheme.primary
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDateTime != null
                            ? DateFormat('EEE, MMM d • hh:mm a')
                                .format(_selectedDateTime!)
                            : 'Set reminder date & time (optional)',
                        style: TextStyle(
                          color: _selectedDateTime != null
                              ? Theme.of(ctx).colorScheme.primary
                              : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _addTask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    if (_taskController.text.isEmpty) return;

    final taskData = <String, dynamic>{
      'title': _taskController.text,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledTime': _selectedDateTime != null
          ? Timestamp.fromDate(_selectedDateTime!)
          : null,
    };

    final docRef = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .add(taskData);

    // Schedule native notification if datetime was selected
    if (_selectedDateTime != null) {
      final notifId = docRef.id.hashCode.abs() % 100000;
      await NotificationService().scheduleTaskNotification(
        id: notifId,
        title: _taskController.text,
        scheduledTime: _selectedDateTime!,
      );
      // Store notifId for later cancellation
      await docRef.update({'notifId': notifId});
    }

    _taskController.clear();
    _selectedDateTime = null;
  }

  Future<void> _toggleTask(String docId, bool currentStatus) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(docId)
        .update({'isCompleted': !currentStatus});
  }

  Future<void> _deleteTask(String docId, int? notifId) async {
    // Cancel notification if exists
    if (notifId != null) {
      await NotificationService().cancelNotification(notifId);
    }
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('tasks')
        .doc(docId)
        .delete();
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  String _formatScheduled(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.isNegative) return 'Overdue';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'In ${diff.inHours}h';
    return DateFormat('MMM d, hh:mm a').format(dt);
  }

  Color _scheduledColor(Timestamp? ts) {
    if (ts == null) return Colors.grey;
    final dt = ts.toDate();
    if (dt.isBefore(DateTime.now())) return Colors.red;
    if (dt.difference(DateTime.now()).inHours < 1) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Tasks',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded,
                color: Theme.of(context).colorScheme.primary, size: 28),
            onPressed: _showAddTaskDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No tasks yet!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first task',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final pending = docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>?;
            return d != null && d['isCompleted'] == false;
          }).toList();
          final completed = docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>?;
            return d != null && d['isCompleted'] == true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                _buildSectionHeader('Pending', pending.length, Colors.orange),
                ...pending.map((doc) => _buildTaskCard(doc)),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionHeader('Completed', completed.length,
                    Theme.of(context).colorScheme.primary),
                ...completed.map((doc) => _buildTaskCard(doc)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSectionHeader(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$label · $count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isCompleted = data['isCompleted'] ?? false;
    final title = data['title'] ?? '';
    final scheduledTs = data['scheduledTime'] as Timestamp?;
    final notifId = data['notifId'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: GestureDetector(
          onTap: () => _toggleTask(doc.id, isCompleted),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: scheduledTs != null
            ? Row(
                children: [
                  Icon(Icons.alarm,
                      size: 13, color: _scheduledColor(scheduledTs)),
                  const SizedBox(width: 4),
                  Text(
                    _formatScheduled(scheduledTs),
                    style: TextStyle(
                        color: _scheduledColor(scheduledTs),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(scheduledTs.toDate()),
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline,
              color: Colors.redAccent, size: 22),
          onPressed: () => _deleteTask(doc.id, notifId),
        ),
      ),
    );
  }
}
