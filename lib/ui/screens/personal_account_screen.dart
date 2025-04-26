import 'package:flutter/material.dart';

class PersonalAccountScreen extends StatefulWidget {
  const PersonalAccountScreen({super.key});

  @override
  _PersonalAccountScreenState createState() => _PersonalAccountScreenState();
}

class _PersonalAccountScreenState extends State<PersonalAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: const Center(
        child: Text(
          'Личный кабинет',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
