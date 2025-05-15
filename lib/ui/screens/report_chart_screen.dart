import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/report_chart_service.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:intl/intl.dart';

const List<String> sleepQualityOptions = [
  'Все',
  'Ужасное',
  'Плохое',
  'Нормальное',
  'Хорошее',
  'Отличное',
];
const List<String> periodOptions = ['7 дней', '30 дней', 'Все время'];

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

  String _selectedQuality = sleepQualityOptions.first;
  String _selectedPeriod = periodOptions.first;

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
        quality: _selectedQuality == 'Все' ? null : _selectedQuality,
        period: _selectedPeriod,
      );

      setState(() {
        _sleepRecords = sleepRecords;
        _averageSleepDuration = _reportChartService
            .calculateAverageSleepDuration(sleepRecords);
        _averageSleepQuality = _reportChartService.calculateAverageSleepQuality(
          sleepRecords,
        );
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
                    _buildAverageDataCard(),
                    const SizedBox(height: 16),
                    _buildDropdownFilters(isWide),
                    const SizedBox(height: 24),
                    _buildSleepChartWithLegend(isWide),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAverageDataCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Средняя продолжительность сна: ${_averageSleepDuration.toStringAsFixed(2)} ч',
            ),
            const SizedBox(height: 8),
            Text('Среднее качество сна: $_averageSleepQuality'),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilters(bool isWide) {
    return isWide
        ? Row(
          children: [
            Expanded(child: _qualityDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _periodDropdown()),
          ],
        )
        : Column(
          children: [
            _qualityDropdown(),
            const SizedBox(height: 16),
            _periodDropdown(),
          ],
        );
  }

  Widget _qualityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedQuality,
      decoration: const InputDecoration(
        labelText: 'Качество',
        border: OutlineInputBorder(),
      ),
      items:
          sleepQualityOptions
              .map((q) => DropdownMenuItem(value: q, child: Text(q)))
              .toList(),
      onChanged: (v) {
        setState(() {
          _selectedQuality = v!;
          _fetchData();
        });
      },
    );
  }

  Widget _periodDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPeriod,
      decoration: const InputDecoration(
        labelText: 'Период',
        border: OutlineInputBorder(),
      ),
      items:
          periodOptions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
      onChanged: (v) {
        setState(() {
          _selectedPeriod = v!;
          _fetchData();
        });
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildSleepChartWithLegend(bool isWide) {
    final maxPoints = 30;
    final sortedRecords = List.from(_sleepRecords)
      ..sort((a, b) => a.date.compareTo(b.date));
    final records = sortedRecords.length > maxPoints
        ? sortedRecords.sublist(sortedRecords.length - maxPoints)
        : sortedRecords;
    final spots = List.generate(records.length, (index) {
      final r = records[index];
      final durationHours = r.sleepDuration;
      return FlSpot(index.toDouble(), durationHours);
    });
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: isWide ? 1.6 : 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: records.isEmpty
                  ? const Center(
                child: Text(
                  'Нет данных для графика',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
                  : LineChart(
                LineChartData(
                  minY: 0,
                  maxX: 24,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Продолжительность сна (ч)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value <= 24) {
                            final hours = value.toInt();
                            return Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                hours.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Дата'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= records.length) {
                            return const SizedBox.shrink();
                          }
                          final date = records[index].date;
                          final formatted =
                          DateFormat('dd.MM').format(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -1.10,
                              child: Text(
                                formatted,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                        interval: (records.length > 10)
                            ? (records.length / 5).floorToDouble()
                            : 1,
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _legendItem(Colors.blue, 'Длительность сна'),
        ],
      ),
    );
  }
}
