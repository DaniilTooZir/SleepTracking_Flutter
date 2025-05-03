import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';

final SupabaseClient _client = SupabaseConnection.client;

class ReportChartService {
  Future<List<SleepRecording>> getFilteredSleepRecords({
    required int userId,
    String? quality,
    required String period,
  }) async {
    try {
      final dateNow = DateTime.now();
      DateTime startDate;

      switch (period) {
        case '7 дней':
          startDate = dateNow.subtract(const Duration(days: 7));
          break;
        case '30 дней':
          startDate = dateNow.subtract(const Duration(days: 30));
          break;
        default:
          startDate = DateTime(1970);
      }

      var query = _client
          .from('SleepRecording')
          .select()
          .gte('Date', startDate.toIso8601String())
          .order('Date', ascending: false);

      final response = await query;

      final List<Map<String, dynamic>> records = response;
      return records.map(SleepRecording.fromMap).toList();
    } catch (e, stackTrace) {
      debugPrint('Ошибка при получении записей: $e\n$stackTrace');
      throw Exception('Не удалось получить записи о сне');
    }
  }

  double calculateAverageSleepDuration(List<SleepRecording> sleepRecords) {
    if (sleepRecords.isEmpty) return 0.0;

    final totalDuration = sleepRecords.fold<double>(
      0.0,
          (previousValue, record) => previousValue + record.sleepDuration,
    );

    return totalDuration / sleepRecords.length;
  }

  String calculateAverageSleepQuality(List<SleepRecording> sleepRecords) {
    if (sleepRecords.isEmpty) return 'Нет данных';

    Map<String, int> qualityScores = {
      'Ужасное': 1,
      'Плохое': 2,
      'Среднее': 3,
      'Хорошее': 4,
      'Отличное': 5,
    };

    final totalQualityScore = sleepRecords.fold<int>(
      0,
          (previousValue, record) =>
      previousValue + (qualityScores[record.sleepQuality] ?? 0),
    );

    final averageScore = totalQualityScore / sleepRecords.length;
    return qualityScores.keys
        .firstWhere((key) => qualityScores[key] == averageScore.toInt());
  }

  List<FlSpot> generateSleepDurationGraphData(
      List<SleepRecording> sleepRecords) {
    final data = <FlSpot>[];

    for (var record in sleepRecords) {
      data.add(FlSpot(
        record.date.millisecondsSinceEpoch.toDouble(),
        record.sleepDuration,
      ));
    }

    return data;
  }
}