import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/homescreen.dart';
import 'package:flutter/material.dart';

Future<void> Register(
  String name,
  String email,
  String password,
  String age,
  String weight,
  String goals,
  BuildContext context,
) async {
  try {
    UserCredential userCredetial = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredetial.user!.uid)
        .set({
          'name': name,
          'email': email,
          'password': password,
          'age': age,
          'weight': weight,
          'goals': goals,
          'createdAt': FieldValue.serverTimestamp(),
        });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Registration successful!')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> login(String email, String password, BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Login successful!')));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Homescreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}
