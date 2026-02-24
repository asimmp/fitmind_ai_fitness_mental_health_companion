import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  double? bmiResult;
  String? bmiCategory;
  double? bmrResult;
  double? tdeeResult;
  double? bodyFatResult;
  bool _isSaving = false;

  String _gender = 'Male';
  int _age = 25;
  String _activityLevel = 'Sedentary';

  final Map<String, double> _activityMultipliers = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extra Active': 1.9,
  };

  void calculateBMI() {
    double height = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100;
      double bmi = weight / (heightInMeters * heightInMeters);

      String category;
      if (bmi < 18.5) {
        category = "Underweight";
      } else if (bmi < 24.9) {
        category = "Normal Weight";
      } else if (bmi < 29.9) {
        category = "Overweight";
      } else {
        category = "Obese";
      }

      // Accurate BMR estimation (Mifflin-St Jeor Equation)
      double bmr;
      if (_gender == 'Male') {
        bmr = (10 * weight) + (6.25 * height) - (5 * _age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * _age) - 161;
      }

      double tdee = bmr * (_activityMultipliers[_activityLevel] ?? 1.2);

      // Body Fat Percentage Estimate (Adult)
      // BFP = (1.20 × BMI) + (0.23 × Age) − (10.8 × gender) − 5.4
      // gender: male = 1, female = 0
      double genderFactor = _gender == 'Male' ? 1 : 0;
      double bfp = (1.20 * bmi) + (0.23 * _age) - (10.8 * genderFactor) - 5.4;

      setState(() {
        bmiResult = bmi;
        bmiCategory = category;
        bmrResult = bmr;
        tdeeResult = tdee;
        bodyFatResult = bfp;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid height and weight")),
      );
    }
  }

  Future<void> _saveBMIData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || bmiResult == null) return;

    setState(() => _isSaving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final historyDoc = userDoc.collection('bmi_history').doc();

      final data = {
        'bmi': bmiResult,
        'category': bmiCategory,
        'bmr': bmrResult,
        'tdee': tdeeResult,
        'bodyFat': bodyFatResult,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Update primary user doc for quick access to "latest"
      batch.update(userDoc, {
        'lastBMI': bmiResult,
        'lastBMICategory': bmiCategory,
        'lastBMR': bmrResult,
        'lastTDEE': tdeeResult,
        'lastBodyFat': bodyFatResult,
        'bmiUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Add to history sub-collection
      batch.set(historyDoc, data);

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("BMI metrics synced to Cloud and History!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _getCategoryColor() {
    if (bmiCategory == "Underweight") return Colors.orangeAccent;
    if (bmiCategory == "Normal Weight") return Colors.green;
    if (bmiCategory == "Overweight") return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "BMI Calculator",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Get a detailed analysis of your body metrics",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Gender Selection
            Row(
              children: [
                _buildGenderCard('Male', Icons.male, Colors.blue),
                const SizedBox(width: 16),
                _buildGenderCard('Female', Icons.female, Colors.pink),
              ],
            ),
            const SizedBox(height: 24),

            // Age and Activity
            Row(
              children: [
                Expanded(
                  child: _buildInputContainer(
                    "Age",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRoundButton(Icons.remove,
                            () => setState(() => _age > 1 ? _age-- : null)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("$_age",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        _buildRoundButton(Icons.add,
                            () => setState(() => _age < 120 ? _age++ : null)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Height and Weight in one Row for compactness
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Height (cm)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.height,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.monitor_weight_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity Level Dropdown
            _buildInputContainer(
              "Activity Level",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _activityLevel,
                  isExpanded: true,
                  items: _activityMultipliers.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _activityLevel = val!),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "CALCULATE PRO METRICS",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2),
              ),
            ),

            const SizedBox(height: 32),

            if (bmiResult != null) ...[
              _buildProResultsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, Color color) {
    bool isSelected = _gender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 32),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer(String label, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9), shape: BoxShape.circle),
        child:
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildProResultsSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(),
                _getCategoryColor().withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: _getCategoryColor().withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              Text(
                bmiCategory!.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                bmiResult!.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Text(
                "BMI Score",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProMetricItem(
                      "BMR", bmrResult!.toStringAsFixed(0), "kcal/day"),
                  _buildProMetricItem(
                      "TDEE", tdeeResult!.toStringAsFixed(0), "kcal/day"),
                ],
              ),
              const SizedBox(height: 24),
              _buildProMetricItem(
                  "Est. Body Fat", "${bodyFatResult!.toStringAsFixed(1)}%", ""),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _saveBMIData,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined),
            label: const Text("SYNC DATA TO CLOUD",
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              foregroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProMetricItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(width: 4),
            Text(unit,
                style: const TextStyle(fontSize: 10, color: Colors.white60)),
          ],
        ),
      ],
    );
  }
}
