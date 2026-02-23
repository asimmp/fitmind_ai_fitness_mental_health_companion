import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/bmi_calculator.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/fitness_module.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/mental_wellness.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/notification_service.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/notification_screen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/profile_screen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/todo_screen.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  Timer? _notifPoller;
  // Listen to unread notifications count from Firebase
  StreamSubscription? _notifSubscription;
  int _unreadNotifs = 0;

  @override
  void initState() {
    super.initState();
    _startNotifListener();
    // Start polling for tasks due (Active background monitor)
    _notifPoller = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkDueTasks(),
    );
  }

  void _startNotifListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _notifSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      if (mounted) {
        setState(() => _unreadNotifs = snap.docs.length);
      }
    });
  }

  @override
  void dispose() {
    _notifPoller?.cancel();
    _notifSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkDueTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();

      final notifService = NotificationService();

      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['scheduledTime'] as Timestamp?;
        if (ts == null) continue;

        final scheduled = ts.toDate();
        final diffSeconds = scheduled.difference(now).inSeconds;

        // Condition: Task is actually reaching/reached its time (now >= scheduled)
        // We look back up to 24 hours to catch missed ones.
        if (diffSeconds <= 0 && diffSeconds > -86400) {
          // Check memory set first for speed
          if (notifService.notifiedTaskIds.contains(doc.id)) continue;

          // Extra confirm from Firestore to prevent duplicates across devices/sessions
          final existingNotif = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notifications')
              .where('taskId', isEqualTo: doc.id)
              .limit(1)
              .get();

          if (existingNotif.docs.isEmpty) {
            notifService.notifiedTaskIds.add(doc.id);

            // 1. Persist
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .add({
              'title': 'Task Reminder',
              'message': 'Time for: ${data['title']}',
              'taskId': doc.id,
              'timestamp': FieldValue.serverTimestamp(),
              'isRead': false,
              'type': 'task_reminder'
            });

            // 2. UI Alert
            notifService.showWebNotification(
                "FitMind Reminder", data['title'] ?? 'Task is due!');
            if (mounted) {
              _showInAppBanner(data['title'] ?? 'Fitness Task');
            }
          } else {
            // Already in Firestore, mark as notified in memory to skip next time
            notifService.notifiedTaskIds.add(doc.id);
          }
        }
      }
    } catch (e) {
      debugPrint("Notification check loop error: $e");
    }
  }

  void _showInAppBanner(String taskTitle) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF2FA67A),
        leading: const Icon(Icons.alarm, color: Colors.white),
        content: Text(
          '⏰ Reminder: $taskTitle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  final List<Widget> _screens = [
    const FitnessModule(), // Default to Fitness as Home
    const MentalWellness(),
    const BMICalculator(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "FitMind AI",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TodoScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationScreen()),
                  );
                },
              ),
              if (_unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadNotifs',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2FA67A),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: "Fitness",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement),
              label: "Wellness",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: "BMI",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              backgroundColor: const Color(0xFF2FA67A),
              child: const Icon(Icons.psychology, color: Colors.white),
            )
          : null,
    );
  }
}
