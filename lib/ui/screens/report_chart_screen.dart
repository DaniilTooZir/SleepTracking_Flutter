import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/report_chart_service.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/providers/user_provider.dart';

class ReportChartScreen extends StatefulWidget {
  const ReportChartScreen({super.key});

  @override
  _ReportChartScreenState createState() => _ReportChartScreenState();
}

class _ReportChartScreenState extends State<ReportChartScreen> {
  final ReportChartService _reportChartService = ReportChartService();
  List<SleepRecording> _sleepRecords = [];
  double _averageSleepDuration = 0.0;
  String _averageSleepQuality = 'Нет данных';

  String _selectedQuality = 'Все';
  String _selectedPeriod = '7 дней';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId == null) return;
    try {
      final sleepRecords = await _reportChartService.getFilteredSleepRecords(
        userId: userId,
        quality: _selectedQuality,
        period: _selectedPeriod,
      );

      setState(() {
        _sleepRecords = sleepRecords;
        _averageSleepDuration = _reportChartService.calculateAverageSleepDuration(sleepRecords);
        _averageSleepQuality = _reportChartService.calculateAverageSleepQuality(sleepRecords);
      });
    } catch (e) {
      debugPrint('Ошибка получения данных: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Отчеты и графики')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ваши данные сна',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Средняя продолжительность сна: ${_averageSleepDuration.toStringAsFixed(2)} ч'),
                            const SizedBox(height: 8),
                            Text('Среднее качество сна: $_averageSleepQuality'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedQuality,
                            decoration: const InputDecoration(
                              labelText: 'Фильтр по качеству',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Все', 'Ужасное', 'Плохое', 'Среднее', 'Хорошее', 'Отличное']
                                .map(
                                  (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedQuality = value!;
                                _fetchData();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPeriod,
                            decoration: const InputDecoration(
                              labelText: 'Период',
                              border: OutlineInputBorder(),
                            ),
                            items: ['7 дней', '30 дней', 'Все время']
                                .map(
                                  (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPeriod = value!;
                                _fetchData();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    isWide
                        ? SizedBox(
                      width: 600,
                      height: 300,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _sleepRecords.isNotEmpty
                            ? LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _reportChartService.generateSleepDurationGraphData(_sleepRecords),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        )
                            : const Center(
                          child: Text(
                            'Нет данных для графика',
                            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    )
                        : SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _sleepRecords.isNotEmpty
                            ? LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _reportChartService.generateSleepDurationGraphData(_sleepRecords),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        )
                            : const Center(
                          child: Text(
                            'Нет данных для графика',
                            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
