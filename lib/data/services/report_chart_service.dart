import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';

final SupabaseClient _client = SupabaseConnection.client;

class ReportChartService {
  static const Map<String, int> _qualityScores = {
    'Ужасное': 1,
    'Плохое': 2,
    'Среднее': 3,
    'Хорошее': 4,
    'Отличное': 5,
  };

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
          .match({
            'UserId': userId,
            if (quality != null && quality.isNotEmpty) 'SleepQuality': quality,
          })
          .gte('Date', startDate.toIso8601String())
          .order('Date', ascending: false);

      final List<Map<String, dynamic>> records = await query;
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

    final totalQualityScore = sleepRecords.fold<int>(
      0,
      (previousValue, record) =>
          previousValue + (_qualityScores[record.sleepQuality] ?? 0),
    );
    final averageScore = totalQualityScore / sleepRecords.length;
    final roundedScore = averageScore.round();

    return _qualityScores.entries
        .firstWhere(
          (entry) => entry.value == roundedScore,
          orElse: () => const MapEntry('Нет данных', 0),
        )
        .key;
  }

  List<FlSpot> generateSleepDurationGraphData(
    List<SleepRecording> sleepRecords,
  ) {
    final data = <FlSpot>[];
    sleepRecords.sort((a, b) => a.date.compareTo(b.date));
    for (var record in sleepRecords) {
      data.add(
        FlSpot(
          record.date.millisecondsSinceEpoch.toDouble(),
          record.sleepDuration,
        ),
      );
    }

    return data;
  }
}
