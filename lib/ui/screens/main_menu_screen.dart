import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
      ),
      body: const Center(
        child: Text(
          'ну типа до',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}