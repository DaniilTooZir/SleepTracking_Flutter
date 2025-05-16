import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
//Сервис для отслеживания сна
class SleepTrackingService {
  final SupabaseClient _client;
  SleepTrackingService({SupabaseClient? client})
      : _client = client ?? SupabaseConnection.client;
  static double calculateSleepDuration(Duration sleepStart, Duration sleepEnd) {
    if (sleepStart == sleepEnd) {
      return 24.0;
    }
    final duration = sleepEnd - sleepStart;
    return duration.inMinutes < 0
        ? (duration + const Duration(hours: 24)).inMinutes / 60
        : duration.inMinutes / 60;
  }
  // Добавляет новую запись о сне
  Future<SleepRecording> addSleepRecord({
    required int userId,
    required DateTime date,
    required Duration sleepStart,
    required Duration sleepEnd,
    required String sleepQuality,
  }) async {
    try {
      final sleepDuration = calculateSleepDuration(sleepStart, sleepEnd);

      final newRecord = SleepRecording(
        userId: userId,
        date: date,
        sleepStart: sleepStart,
        sleepEnd: sleepEnd,
        sleepDuration: sleepDuration,
        sleepQuality: sleepQuality,
      );
      // Вставка записи и возврат результата
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
  // Получает все записи сна пользователя, отсортированные по дате
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
  // Удаляет запись сна по её ID
  Future<void> deleteSleepRecord(int recordId) async {
    try {
      await _client.from('SleepRecording').delete().eq('Id', recordId);
    } catch (e, stackTrace) {
      debugPrint('Ошибка при удалении записи: $e\n$stackTrace');
      throw Exception('Не удалось удалить запись о сне');
    }
  }
}
