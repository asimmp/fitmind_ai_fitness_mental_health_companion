import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
              
                  // Logo
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 11, 238, 22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.psychology, size: 42, color: Colors.white),
                  ),
              
                  const SizedBox(height: 10),
              
                  Text(
                    "Create Your Account",
                    style:TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.topLeft, child: Text("Fullname")),
                  TextField(
                    decoration:InputDecoration(
                      prefixIcon: Icon(Icons.person_2_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ))),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.topLeft, child: Text("Email Address")),
                  TextField(
                    decoration:InputDecoration(
                      prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ))),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.topLeft, child: Text("Password")),
                  TextField(
                    decoration:InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ))),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.topLeft, child: Text("Confirm Password")),
                  TextField(
                    decoration:InputDecoration(
                      prefixIcon: Icon(Icons.refresh),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ))),
                  SizedBox(
              height: 50,
              width: 250,
              child:ElevatedButton(onPressed:  () {
                
              }, child: Text("CREATE A Account")) ),
                  
              
                  
                 ] ),
            ),))));
                
  }

}
