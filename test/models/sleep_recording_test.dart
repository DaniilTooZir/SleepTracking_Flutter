import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracking/models/sleep_recording.dart';

void main() {
  group('SleepRecording модель', () {
    test('fromMap корректно создает объект из карты с временем без дней', () {
      final map = {
        'Id': 1,
        'UserId': 42,
        'Date': '2025-05-16T00:00:00.000',
        'SleepStart': '22:30:00',
        'SleepEnd': '06:30:00',
        'SleepDuration': 8.0,
        'SleepQuality': 'Хорошее',
      };
      final recording = SleepRecording.fromMap(map);
      expect(recording.id, 1);
      expect(recording.userId, 42);
      expect(recording.date, DateTime.parse('2025-05-16T00:00:00.000'));
      expect(recording.sleepStart, Duration(hours: 22, minutes: 30));
      expect(recording.sleepEnd, Duration(hours: 6, minutes: 30));
      expect(recording.sleepDuration, 8.0);
      expect(recording.sleepQuality, 'Хорошее');
    });
    test('fromMap корректно парсит время с количеством дней', () {
      final map = {
        'Id': 2,
        'UserId': 99,
        'Date': '2025-05-15T00:00:00.000',
        'SleepStart': '1 days 22:30:00',
        'SleepEnd': '2 days 06:30:00',
        'SleepDuration': 8.0,
        'SleepQuality': 'Среднее',
      };
      final recording = SleepRecording.fromMap(map);
      expect(recording.sleepStart, Duration(days: 1, hours: 22, minutes: 30));
      expect(recording.sleepEnd, Duration(days: 2, hours: 6, minutes: 30));
    });
    test('_parseInterval возвращает Duration.zero для пустой или некорректной строки', () {
      expect(SleepRecording.parseInterval(''), Duration.zero);
      expect(SleepRecording.parseInterval('invalid'), Duration.zero);
      expect(SleepRecording.parseInterval('5 days x:y:z'), Duration.zero);
    });
    test('toMap корректно сериализует объект без id', () {
      final recording = SleepRecording(
        userId: 3,
        date: DateTime(2025, 5, 16),
        sleepStart: Duration(hours: 22, minutes: 0),
        sleepEnd: Duration(hours: 6, minutes: 30),
        sleepDuration: 8.5,
        sleepQuality: 'Отличное',
      );
      final map = recording.toMap();
      expect(map['UserId'], 3);
      expect(map['Date'], '2025-05-16T00:00:00.000');
      expect(map['SleepStart'], 'PT22H0M0S');
      expect(map['SleepEnd'], 'PT6H30M0S');
      expect(map['SleepDuration'], 8.5);
      expect(map['SleepQuality'], 'Отличное');
      expect(map.containsKey('Id'), false);
    });
    test('toMap корректно сериализует объект с id', () {
      final recording = SleepRecording(
        id: 10,
        userId: 3,
        date: DateTime(2025, 5, 16),
        sleepStart: Duration(hours: 22, minutes: 0),
        sleepEnd: Duration(hours: 6, minutes: 30),
        sleepDuration: 8.5,
        sleepQuality: 'Отличное',
      );
      final map = recording.toMap(includeId: true);
      expect(map['Id'], 10);
    });
    test('fromMap с sleepDuration как int и double корректно парсит', () {
      final mapInt = {
        'UserId': 5,
        'Date': '2025-05-16T00:00:00.000',
        'SleepStart': '22:00:00',
        'SleepEnd': '06:00:00',
        'SleepDuration': 8,
        'SleepQuality': 'Хорошее',
      };
      final mapDouble = {
        'UserId': 5,
        'Date': '2025-05-16T00:00:00.000',
        'SleepStart': '22:00:00',
        'SleepEnd': '06:00:00',
        'SleepDuration': 8.5,
        'SleepQuality': 'Хорошее',
      };
      final recInt = SleepRecording.fromMap(mapInt);
      final recDouble = SleepRecording.fromMap(mapDouble);
      expect(recInt.sleepDuration, 8.0);
      expect(recDouble.sleepDuration, 8.5);
    });
    test('fromMap выбрасывает исключение при отсутствии обязательных полей', () {
      final incompleteMap = {
        'UserId': 1,
        'Date': '2025-05-16T00:00:00.000',
        // Нет SleepStart
        'SleepEnd': '06:00:00',
        'SleepDuration': 8.0,
        'SleepQuality': 'Хорошее',
      };
      expect(() => SleepRecording.fromMap(incompleteMap), throwsA(isA<ArgumentError>()));
    });
  });
  group('SleepRecording модель - дополнительные тесты', () {
    test('fromMap корректно парсит sleepStart и sleepEnd с нулями', () {
      final map = {
        'UserId': 7,
        'Date': '2025-05-16T00:00:00.000',
        'SleepStart': '00:00:00',
        'SleepEnd': '00:00:00',
        'SleepDuration': 24.0,
        'SleepQuality': 'Отличное',
      };
      final recording = SleepRecording.fromMap(map);
      expect(recording.sleepStart, Duration.zero);
      expect(recording.sleepEnd, Duration.zero);
      expect(recording.sleepDuration, 24.0);
    });
    test('toMap корректно сериализует sleepStart и sleepEnd с минутами и секундами', () {
      final recording = SleepRecording(
        userId: 11,
        date: DateTime(2025, 5, 17),
        sleepStart: Duration(hours: 23, minutes: 59, seconds: 59),
        sleepEnd: Duration(hours: 7, minutes: 15, seconds: 30),
        sleepDuration: 7.25,
        sleepQuality: 'Хорошее',
      );
      final map = recording.toMap();
      expect(map['SleepStart'], 'PT23H59M59S');
      expect(map['SleepEnd'], 'PT7H15M30S');
    });
    test('fromMap корректно обрабатывает sleepStart и sleepEnd с разными форматами', () {
      final map1 = {
        'UserId': 12,
        'Date': '2025-05-18T00:00:00.000',
        'SleepStart': '0 days 23:00:00',
        'SleepEnd': '1 days 07:00:00',
        'SleepDuration': 8.0,
        'SleepQuality': 'Среднее',
      };
      final map2 = {
        'UserId': 12,
        'Date': '2025-05-18T00:00:00.000',
        'SleepStart': '23:00:00',
        'SleepEnd': '07:00:00',
        'SleepDuration': 8.0,
        'SleepQuality': 'Среднее',
      };
      final rec1 = SleepRecording.fromMap(map1);
      final rec2 = SleepRecording.fromMap(map2);
      expect(rec1.sleepStart, rec2.sleepStart);
      expect(rec1.sleepEnd, equals(Duration(days: 1) + rec2.sleepEnd));
    });
    test('toMap не включает поле Id, если includeId = false', () {
      final recording = SleepRecording(
        id: 5,
        userId: 10,
        date: DateTime(2025, 5, 19),
        sleepStart: Duration(hours: 22),
        sleepEnd: Duration(hours: 6),
        sleepDuration: 8.0,
        sleepQuality: 'Хорошее',
      );

      final map = recording.toMap(includeId: false);
      expect(map.containsKey('Id'), false);
    });
    test('toMap корректно включает поле Id, если includeId = true', () {
      final recording = SleepRecording(
        id: 5,
        userId: 10,
        date: DateTime(2025, 5, 19),
        sleepStart: Duration(hours: 22),
        sleepEnd: Duration(hours: 6),
        sleepDuration: 8.0,
        sleepQuality: 'Хорошее',
      );
      final map = recording.toMap(includeId: true);
      expect(map.containsKey('Id'), true);
      expect(map['Id'], 5);
    });
  });
}