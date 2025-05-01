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
      final sleepDuration = sleepEnd.inMinutes - sleepStart.inMinutes;

      final newRecord = SleepRecording(
        userId: userId,
        date: date,
        sleepStart: sleepStart,
        sleepEnd: sleepEnd,
        sleepDuration: sleepDuration.toDouble(),
        sleepQuality: sleepQuality,
      );

      final response =
          await _client
              .from('SleepRecording')
              .insert(newRecord.toMap())
              .select()
              .single();

      return SleepRecording.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка при добавлении записи о сне: $e');
    }
  }

  Future<List<SleepRecording>> getSleepRecords(int userId) async {
    try {
      final response = await _client
          .from('SleepRecording')
          .select()
          .eq('UserId', userId)
          .order('Date', ascending: false);

      return (response as List)
          .map((record) => SleepRecording.fromMap(record))
          .toList();
    } catch (e) {
      throw Exception('Ошибка при получении записей о сне: $e');
    }
  }

  Future<void> deleteSleepRecord(int recordId) async {
    try {
      final response = await _client
          .from('SleepRecording')
          .delete()
          .eq('Id', recordId);

      if (response.error != null) {
        throw Exception('Ошибка при удалении записи о сне: ${response.error!.message}');
      }
      if (response.data == null || response.data.isEmpty) {
        throw Exception('Запись не найдена или не была удалена.');
      }
      print('Запись о сне удалена успешно.');
    } catch (e) {
      throw Exception('Ошибка при удалении записи о сне: $e');
    }
  }
}
