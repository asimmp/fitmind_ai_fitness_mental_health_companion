import 'package:flutter/material.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE3ECE8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF2FA67A),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// Center Icon Section
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 140,
                    width: 140,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDE8E4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.lock_reset,
                    size: 60,
                    color: Color(0xFF2FA67A),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// Title
              const Text(
                "Forgot Password?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              /// Description
              const Text.rich(
                TextSpan(
                  text:
                      "Don’t worry! Enter the email address associated with your ",
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                  children: [
                    TextSpan(
                      text: "FitMind",
                      style: TextStyle(
                        color: Color(0xFF2FA67A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                          " account and we’ll send a link to reset your password.",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// Email Label
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Email Address",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "name@example.com",
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFE9EEF3),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// Send Reset Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2FA67A),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF2FA67A).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement reset password logic
                  },
                  child: const Text(
                    "Send Reset Link",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Back to Login
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.login, color: Color(0xFF2FA67A)),
                label: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: Color(0xFF2FA67A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// Bottom Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3ECE8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "●  AI POWERED RECOVERY",
                  style: TextStyle(
                    color: Color(0xFF2FA67A),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
