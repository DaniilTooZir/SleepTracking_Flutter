import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracking/data/services/sleep_tracking_service.dart';

void main() {
  group('SleepTrackingService', () {
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
  });
}
