import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text("Failed to initialize Firebase", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const Text("Try again later, by turning on internet", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}