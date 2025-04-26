import 'package:flutter/material.dart';

class ReportChartScreen extends StatefulWidget {
  const ReportChartScreen({super.key});

  @override
  _ReportChartScreenState createState() => _ReportChartScreenState();
}

class _ReportChartScreenState extends State<ReportChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отчеты и графики')),
      body: const Center(
        child: Text(
          'Отчеты и графики',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
