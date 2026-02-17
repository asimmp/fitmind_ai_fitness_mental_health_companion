import 'package:flutter/material.dart';

class FitnessModule extends StatelessWidget {
  const FitnessModule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Fitness",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Daily Stats
          Row(
            children: [
              _buildStatCard(
                "Steps",
                "5,432",
                Icons.directions_walk,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                "Calories",
                "350 kcal",
                Icons.local_fire_department,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Workout Plans",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildWorkoutCard(
            "Full Body HIIT",
            "20 mins • High Intensity",
            Colors.purple.shade50,
          ),
          const SizedBox(height: 16),
          _buildWorkoutCard(
            "Yoga for Beginners",
            "30 mins • Low Intensity",
            Colors.green.shade50,
          ),
          const SizedBox(height: 16),
          _buildWorkoutCard(
            "Cardio Blast",
            "45 mins • Medium Intensity",
            Colors.red.shade50,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(String title, String subtitle, Color bgColor) {
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
            child: const Icon(Icons.fitness_center, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
