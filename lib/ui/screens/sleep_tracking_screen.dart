import 'package:flutter/material.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отслеживание сна')),
      body: const Center(
        child: Text(
          'Отслеживание сна',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
