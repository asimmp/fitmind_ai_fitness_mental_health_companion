import 'package:fitmind_ai_fitness_mental_health_companion/bmi_calculator.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/fitness_module.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/mental_wellness.dart';
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
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
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
