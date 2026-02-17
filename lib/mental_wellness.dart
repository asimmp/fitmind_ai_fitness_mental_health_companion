import 'package:flutter/material.dart';

class MentalWellness extends StatelessWidget {
  const MentalWellness({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Mental Wellness",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDailyCheckIn(context),
          const SizedBox(height: 24),
          const Text(
            "Meditation & Breathing",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            "Morning Meditation",
            "10 mins • Focus & Calm",
            Icons.self_improvement,
            Colors.teal.shade50,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            "Deep Breathing",
            "5 mins • Stress Relief",
            Icons.spa,
            Colors.blue.shade50,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            "Sleep Stories",
            "20 mins • Relaxation",
            Icons.nights_stay,
            Colors.indigo.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckIn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "How are you feeling today?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodEmoji(context, "😊", "Happy",
                  "Great job! Keep the positive energy flowing."),
              _buildMoodEmoji(context, "😐", "Neutral",
                  "Take a moment to reflect and relax."),
              _buildMoodEmoji(context, "😔", "Sad",
                  "It's okay to feel this way. Maybe a walk will help."),
              _buildMoodEmoji(context, "😫", "Stressed",
                  "Take deep breaths. Try the meditation exercises below."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEmoji(
    BuildContext context,
    String emoji,
    String label,
    String message,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("$emoji AI Insight"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Thanks"),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, size: 32, color: Colors.blueGrey),
        ],
      ),
    );
  }
}
