import 'package:fitmind_ai_fitness_mental_health_companion/login.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/service.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? emailError;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              /// Top Icon
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE8E4),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Color(0xFF2FA67A),
                ),
              ),

              const SizedBox(height: 30),

              /// Title
              const Text(
                "Create Your Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Join the journey to a healthier mind and\nbody with AI-powered insights.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 40),

              /// Full Name
              _buildLabel("Full Name"),
              const SizedBox(height: 8),
              _buildField(
                hint: "John Doe",
                icon: Icons.person_outline,
                controller: nameController,
              ),

              const SizedBox(height: 24),

              /// Email
              _buildLabel("Email Address"),
              const SizedBox(height: 8),
              _buildField(
                hint: "name@example.com",
                icon: Icons.email_outlined,
                controller: emailController,
                onChanged: (value) {
                  setState(() {
                    emailError = value.isEmpty
                        ? null
                        : _isValidEmail(value)
                        ? null
                        : 'Please enter a valid email address';
                  });
                },
                errorText: emailError,
              ),

              const SizedBox(height: 24),

              /// Password
              _buildLabel("Password"),
              const SizedBox(height: 8),
              _buildField(
                hint: "••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
                obscure: obscurePassword,
                controller: passwordController,
              ),

              /// Confirm Password
              _buildLabel("Confirm Password"),
              const SizedBox(height: 8),
              _buildField(
                hint: "••••••••",
                icon: Icons.lock_reset,
                isPassword: true,
                obscure: obscureConfirmPassword,
                controller: confirmPasswordController,
              ),

              /// Sign Up Button
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
                    final email = emailController.text.trim();

                    // Validate email format
                    if (!_isValidEmail(email)) {
                      setState(() {
                        emailError = 'Please enter a valid email address';
                      });
                      return;
                    }

                    Register(
                      nameController.text,
                      email,
                      passwordController.text,
                      context,
                    );
                  },
                  child: const Text(
                    "Sign Up  →",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Terms
              const Text(
                "By creating an account, you agree to our ",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const Text.rich(
                TextSpan(
                  text: "Terms of Service",
                  style: TextStyle(
                    color: Color(0xFF2FA67A),
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: " and ",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: "Privacy Policy.",
                      style: TextStyle(
                        color: Color(0xFF2FA67A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /// Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        color: Color(0xFF2FA67A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onChanged,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: toggle,
                  )
                : null,
            filled: true,
            fillColor: errorText != null
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFE9EEF3),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: errorText != null
                  ? const BorderSide(color: Color(0xFFEF5350), width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: errorText != null
                  ? const BorderSide(color: Color(0xFFEF5350), width: 1)
                  : BorderSide.none,
            ),
          ),
          controller: controller,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: Color(0xFFEF5350),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
