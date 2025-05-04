import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/report_chart_service.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/providers/user_provider.dart';

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
    final series = [
      {
        'color': Colors.blue,
        'label': 'Длительность сна',
        'data': _reportChartService.generateSleepDurationGraphData(
          _sleepRecords,
        ),
      },
    ];

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
              child:
                  _sleepRecords.isEmpty
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
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 1,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameWidget: const Text(
                                'Продолжительность сна (ч)',
                              ),
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text('Дни'),
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData:
                              series.map<LineChartBarData>((s) {
                                return LineChartBarData(
                                  spots: s['data'] as List<FlSpot>,
                                  isCurved: true,
                                  color: s['color'] as Color,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: (s['color'] as Color).withOpacity(
                                      0.3,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
            ),
          ),
          if (series.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children:
                    series.map((s) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: _legendItem(
                          s['color'] as Color,
                          s['label'] as String,
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
