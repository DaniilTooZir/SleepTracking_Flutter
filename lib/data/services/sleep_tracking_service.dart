import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';

class SleepTrackingService {
  final SupabaseClient _client = SupabaseConnection.client;

  Future<SleepRecording> addSleepRecord({
    required int userId,
    required DateTime date,
    required Duration sleepStart,
    required Duration sleepEnd,
    required String sleepQuality,
  }) async {
    try {
      final duration = sleepEnd - sleepStart;
      final sleepDuration = duration.inMinutes < 0
          ? (duration + const Duration(hours: 24)).inMinutes / 60
          : duration.inMinutes / 60;

      final newRecord = SleepRecording(
        userId: userId,
        date: date,
        sleepStart: sleepStart,
        sleepEnd: sleepEnd,
        sleepDuration: sleepDuration,
        sleepQuality: sleepQuality,
      );

      final response =
          await _client
              .from('SleepRecording')
              .insert(newRecord.toMap())
              .select()
              .single();

      return SleepRecording.fromMap(response);
    } catch (e, stackTrace) {
      debugPrint('Ошибка при добавлении записи о сне: $e\n$stackTrace');
      throw Exception('Не удалось добавить запись о сне');
    }
  }

  Future<List<SleepRecording>> getSleepRecords(int userId) async {
    try {
      final response = await _client
          .from('SleepRecording')
          .select()
          .eq('UserId', userId)
          .order('Date', ascending: false);

      final List<Map<String, dynamic>> records = response;
      return records.map(SleepRecording.fromMap).toList();
    } catch (e, stackTrace) {
      debugPrint('Ошибка при получении записей: $e\n$stackTrace');
      throw Exception('Не удалось получить записи о сне');
    }
  }

  Future<void> deleteSleepRecord(int recordId) async {
    try {
      final response = await _client
          .from('SleepRecording')
          .delete()
          .eq('Id', recordId);
    } catch (e, stackTrace) {
      debugPrint('Ошибка при удалении записи: $e\n$stackTrace');
      throw Exception('Не удалось удалить запись о сне');
    }
  }
}
