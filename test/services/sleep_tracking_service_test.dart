import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';
import 'package:sleep_tracking/data/services/sleep_tracking_service.dart';

import '../mocks/mock_supabase_client.mocks.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestTable extends Mock implements PostgrestTable {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late MockPostgrestTable mockTable;
  late MockPostgrestFilterBuilder mockFilter;
  late SleepTrackingService service;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockTable = MockPostgrestTable();
    mockFilter = MockPostgrestFilterBuilder();
    service = SleepTrackingService(client: mockClient);
  });
  test('calculateSleepDuration через полночь (22:00 - 06:30)', () {
    final start = Duration(hours: 22);
    final end = Duration(hours: 6, minutes: 30);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(8.5));
  });
  test('calculateSleepDuration в пределах суток (01:00 - 09:00)', () {
    final start = Duration(hours: 1);
    final end = Duration(hours: 9);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(8.0));
  });
  test('calculateSleepDuration 00:00 - 00:00 (полные сутки)', () {
    final start = Duration(hours: 0);
    final end = Duration(hours: 0);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(24.0));
  });
  test('calculateSleepDuration 12:00 - 12:00 (полные сутки)', () {
    final start = Duration(hours: 12);
    final end = Duration(hours: 12);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(24.0));
  });
  test(
    'calculateSleepDuration минимальное время сна (например, 1 минута)',
        () {
      final start = Duration(hours: 1);
      final end = Duration(hours: 1, minutes: 1);
      final result = SleepTrackingService.calculateSleepDuration(start, end);
      expect(result, equals(1.0 / 60));
    },
  );
  test(
    'calculateSleepDuration странный случай (23:59 - 00:01 = 2 минуты)',
        () {
      final start = Duration(hours: 23, minutes: 59);
      final end = Duration(minutes: 1);
      final result = SleepTrackingService.calculateSleepDuration(start, end);
      expect(result, closeTo(2.0 / 60, 0.0001));
    },
  );
  test('calculateSleepDuration 23:00 - 23:00 (полные сутки)', () {
    final start = Duration(hours: 23);
    final end = Duration(hours: 23);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(24.0));
  });
  test('calculateSleepDuration короткий сон (10 минут)', () {
    final start = Duration(hours: 2, minutes: 0);
    final end = Duration(hours: 2, minutes: 10);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(10.0 / 60));
  });
  test('calculateSleepDuration около полуночи (23:30 - 00:30)', () {
    final start = Duration(hours: 23, minutes: 30);
    final end = Duration(hours: 0, minutes: 30);
    final result = SleepTrackingService.calculateSleepDuration(start, end);
    expect(result, equals(1.0));
  });
  test(
    'calculateSleepDuration начало позже конца (05:00 - 03:00) через сутки',
        () {
      final start = Duration(hours: 5);
      final end = Duration(hours: 3);
      final result = SleepTrackingService.calculateSleepDuration(start, end);
      expect(result, equals(22.0));
    },
  );
  test(
    'calculateSleepDuration начало и конец в пределах суток (14:15 - 18:45)',
        () {
      final start = Duration(hours: 14, minutes: 15);
      final end = Duration(hours: 18, minutes: 45);
      final result = SleepTrackingService.calculateSleepDuration(start, end);
      expect(result, equals(4.5));
    },
  );
  test('calculateSleepDuration возвращает 24.0, если sleepStart == sleepEnd', () {
    final duration = SleepTrackingService.calculateSleepDuration(
      const Duration(hours: 22),
      const Duration(hours: 22),
    );
    expect(duration, 24.0);
  });
  test('calculateSleepDuration корректно считает разницу, если sleepEnd > sleepStart', () {
    final duration = SleepTrackingService.calculateSleepDuration(
      const Duration(hours: 22),
      const Duration(hours: 6),
    );
    expect(duration, 8);
  });

  test('calculateSleepDuration корректно считает при переходе через полночь', () {
    final duration = SleepTrackingService.calculateSleepDuration(
      const Duration(hours: 23),
      const Duration(hours: 2),
    );
    expect(duration, 3);
  });

  test('addSleepRecord возвращает SleepRecording при успешной вставке', () async {
    final newRecordMap = {
      'Id': 1,
      'UserId': 1,
      'Date': DateTime(2025, 5, 16).toIso8601String(),
      'SleepStart': 22 * 3600,
      'SleepEnd': 6 * 3600,
      'SleepDuration': 8.0,
      'SleepQuality': 'good',
    };

    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.insert(any)).thenReturn(mockFilter);
    when(mockFilter.select()).thenReturn(mockFilter);
    when(mockFilter.single()).thenAnswer((_) async => newRecordMap);

    final result = await service.addSleepRecord(
      userId: 1,
      date: DateTime(2025, 5, 16),
      sleepStart: const Duration(hours: 22),
      sleepEnd: const Duration(hours: 6),
      sleepQuality: 'good',
    );

    expect(result.userId, 1);
    expect(result.sleepQuality, 'good');
  });

  test('addSleepRecord бросает исключение при ошибке вставки', () async {
    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.insert(any)).thenThrow(Exception('Ошибка вставки'));

    expect(
          () => service.addSleepRecord(
        userId: 1,
        date: DateTime.now(),
        sleepStart: const Duration(hours: 22),
        sleepEnd: const Duration(hours: 6),
        sleepQuality: 'bad',
      ),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Не удалось добавить запись'))),
    );
  });

  test('getSleepRecords возвращает список записей', () async {
    final response = [
      {
        'Id': 1,
        'UserId': 1,
        'Date': DateTime(2025, 5, 16).toIso8601String(),
        'SleepStart': 22 * 3600,
        'SleepEnd': 6 * 3600,
        'SleepDuration': 8.0,
        'SleepQuality': 'good',
      }
    ];

    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.select()).thenReturn(mockFilter);
    when(mockFilter.eq('UserId', 1)).thenReturn(mockFilter);
    when(mockFilter.order('Date', ascending: false)).thenAnswer((_) async => response);

    final records = await service.getSleepRecords(1);

    expect(records.length, 1);
    expect(records.first.userId, 1);
  });

  test('getSleepRecords бросает исключение при ошибке получения', () async {
    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.select()).thenReturn(mockFilter);
    when(mockFilter.eq('UserId', 1)).thenReturn(mockFilter);
    when(mockFilter.order('Date', ascending: false)).thenThrow(Exception('Ошибка'));

    expect(
          () => service.getSleepRecords(1),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Не удалось получить записи'))),
    );
  });

  test('deleteSleepRecord успешно вызывает delete и eq', () async {
    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.delete()).thenReturn(mockFilter);
    when(mockFilter.eq('Id', 1)).thenAnswer((_) async => []);

    await service.deleteSleepRecord(1);

    verify(mockTable.delete()).called(1);
    verify(mockFilter.eq('Id', 1)).called(1);
  });
  test('deleteSleepRecord бросает исключение при ошибке удаления', () async {
    when(mockClient.from('SleepRecording')).thenReturn(mockTable);
    when(mockTable.delete()).thenReturn(mockFilter);
    when(mockFilter.eq('Id', 1)).thenThrow(Exception('Ошибка удаления'));

    expect(
          () => service.deleteSleepRecord(1),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Не удалось удалить запись'))),
    );
  });

}