import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/bmi_history_screen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/change_password_screen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/lifestyle_habits_screen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/login.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/cloudinary_service.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<Map<String, dynamic>?> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (image != null) {
      if (!mounted) return;

      setState(() {
        _isUploading = true;
      });

      try {
        final imageBytes = await image.readAsBytes();
        await CloudinaryService.uploadProfileImage(
          imageBytes,
          image.name,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
          // Refresh the UI by rebuilding the state
          setState(() {});
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firebase error: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading profile"));
        }

        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text("User not found"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: data['profileImageUrl'] != null
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      child: data['profileImageUrl'] == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: Colors.white),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['name'] ?? 'User',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                data['email'] ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _buildInfoCard("Age", "${data['age'] ?? '-'} years"),
              const SizedBox(height: 16),
              _buildInfoCard("Weight", "${data['weight'] ?? '-'} kg"),
              const SizedBox(height: 16),
              _buildInfoCard("Goals", data['goals'] ?? '-'),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Activity & Health",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                "Lifestyle Habits",
                Icons.favorite_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LifestyleHabitsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                "BMI History",
                Icons.history,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BMIHistoryScreen()),
                ),
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Security",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                "Change Password",
                Icons.lock_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
