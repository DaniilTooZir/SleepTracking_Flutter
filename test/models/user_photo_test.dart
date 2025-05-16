import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracking/models/user_photo.dart';

void main() {
  group('UserPhoto model', () {
    final sampleBase64 = 'aGVsbG8gd29ybGQ=';
    final sampleBytes = Uint8List.fromList([104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100]);
    test('fromMap и toMap должны быть последовательными', () {
      final photo = UserPhoto(
        id: 1,
        userId: 123,
        photo: sampleBase64,
      );
      final map = photo.toMap(includeId: true);
      expect(map['Id'], equals(1));
      expect(map['UserId'], equals(123));
      expect(map['Photo'], equals(sampleBase64));
      final photoFromMap = UserPhoto.fromMap(map);
      expect(photoFromMap.id, equals(photo.id));
      expect(photoFromMap.userId, equals(photo.userId));
      expect(photoFromMap.photo, equals(photo.photo));
    });
    test('photoBytes корректно декодирует base64 в Uint8List', () {
      final photo = UserPhoto(userId: 1, photo: sampleBase64);
      expect(photo.photoBytes, equals(sampleBytes));
    });
    test('toMap без includeId не содержит поле Id', () {
      final photo = UserPhoto(
        id: 10,
        userId: 456,
        photo: sampleBase64,
      );
      final map = photo.toMap(includeId: false);
      expect(map.containsKey('Id'), isFalse);
      expect(map['UserId'], equals(456));
      expect(map['Photo'], equals(sampleBase64));
    });
    // Новый тест: fromMap с null id
    test('fromMap корректно работает с null Id', () {
      final map = {
        'Id': null,
        'UserId': 789,
        'Photo': sampleBase64,
      };
      final photo = UserPhoto.fromMap(map);
      expect(photo.id, isNull);
      expect(photo.userId, equals(789));
      expect(photo.photo, equals(sampleBase64));
    });
    test('fromMap выбрасывает исключение на неправильном формате photo', () {
      final badMap = {
        'Id': 1,
        'UserId': 123,
        'Photo': 12345,
      };
      expect(() => UserPhoto.fromMap(badMap), throwsException);
    });
  });
}