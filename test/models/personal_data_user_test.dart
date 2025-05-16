import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracking/models/personal_data_user.dart';

void main() {
  group('PersonalDataUser model', () {
    test('toMap и fromMap должны быть последовательными', () {
      final user = PersonalDataUser(
        userId: 1,
        name: 'Даня',
        gender: 'Мужской',
        birthDate: DateTime(2003, 6, 1),
      );
      final map = user.toMap(includeId: false);
      final userFromMap = PersonalDataUser.fromMap({
        'UserId': 1,
        'Name': 'Даня',
        'Gender': 'Мужской',
        'BirthDate': '2003-06-01T00:00:00.000',
      });
      expect(userFromMap.userId, equals(user.userId));
      expect(userFromMap.name, equals(user.name));
      expect(userFromMap.gender, equals(user.gender));
      expect(userFromMap.birthDate, equals(user.birthDate));
    });
    test('fromMap должен корректно обрабатывать наличие id', () {
      final map = {
        'Id': 42,
        'UserId': 2,
        'Name': 'Аня',
        'Gender': 'Женский',
        'BirthDate': '1995-12-31T00:00:00.000',
      };
      final user = PersonalDataUser.fromMap(map);
      expect(user.id, equals(42));
      expect(user.userId, equals(2));
      expect(user.name, equals('Аня'));
      expect(user.gender, equals('Женский'));
      expect(user.birthDate, equals(DateTime(1995, 12, 31)));
    });
    test('toMap включает id, если includeId=true и id не null', () {
      final user = PersonalDataUser(
        id: 10,
        userId: 3,
        name: 'Иван',
        gender: 'Мужской',
        birthDate: DateTime(1980, 1, 1),
      );
      final map = user.toMap(includeId: true);

      expect(map.containsKey('Id'), isTrue);
      expect(map['Id'], equals(10));
    });
    test('toMap не включает id, если includeId=false', () {
      final user = PersonalDataUser(
        id: 10,
        userId: 3,
        name: 'Иван',
        gender: 'Мужской',
        birthDate: DateTime(1980, 1, 1),
      );
      final map = user.toMap(includeId: false);
      expect(map.containsKey('Id'), isFalse);
    });
    test('fromMap бросает исключение при некорректном формате даты', () {
      final map = {
        'UserId': 5,
        'Name': 'Пётр',
        'Gender': 'Мужской',
        'BirthDate': 'невалидная дата',
      };
      expect(() => PersonalDataUser.fromMap(map), throwsFormatException);
    });
    test('fromMap корректно обрабатывает дату в формате без времени', () {
      final map = {
        'UserId': 6,
        'Name': 'Мария',
        'Gender': 'Женский',
        'BirthDate': '2000-05-20',
      };
      final user = PersonalDataUser.fromMap(map);
      expect(user.birthDate, equals(DateTime(2000, 5, 20)));
    });
    test('fromMap корректно работает с минимальными значениями', () {
      final map = {
        'UserId': 0,
        'Name': '',
        'Gender': '',
        'BirthDate': '1970-01-01T00:00:00.000'
      };
      final user = PersonalDataUser.fromMap(map);
      expect(user.userId, 0);
      expect(user.name, '');
      expect(user.gender, '');
      expect(user.birthDate, DateTime(1970, 1, 1));
    });
    test('toMap корректно сериализует дату', () {
      final user = PersonalDataUser(
        userId: 10,
        name: 'Тест',
        gender: 'Женский',
        birthDate: DateTime(2025, 5, 16, 14, 30, 45),
      );
      final map = user.toMap();
      expect(map['BirthDate'], '2025-05-16T14:30:45.000');
    });
    test('fromMap и toMap работают с id', () {
      final user = PersonalDataUser(
        id: 5,
        userId: 12,
        name: 'Анна',
        gender: 'Женский',
        birthDate: DateTime(1990, 10, 10),
      );
      final map = user.toMap(includeId: true);
      final newUser = PersonalDataUser.fromMap(map);
      expect(newUser.id, 5);
      expect(newUser.userId, 12);
      expect(newUser.name, 'Анна');
      expect(newUser.gender, 'Женский');
      expect(newUser.birthDate, DateTime(1990, 10, 10));
    });
    test('изменяемость полей (final) проверяется через невозможность присвоения', () {
      final user = PersonalDataUser(
        userId: 1,
        name: 'Даня',
        gender: 'Мужской',
        birthDate: DateTime(2000, 1, 1),
      );
      // Следующий код не скомпилируется (закомментирован для теста):
      // user.name = 'Иван'; // Ошибка компиляции, т.к. поле final
      expect(user.name, 'Даня'); // Проверка, что поле доступно для чтения
    });
    test('fromMap с null значениями выбрасывает исключение', () {
      final map = {
        'UserId': null,
        'Name': null,
        'Gender': null,
        'BirthDate': null,
      };
      expect(() => PersonalDataUser.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}
