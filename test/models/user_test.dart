import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_tracking/models/user.dart';

void main() {
  group('UserModel', () {
    test('toMap и fromMap должны быть последовательными', () {
      final user = UserModel(
        id: 1,
        login: 'daniel',
        password: 'securePass123',
        email: 'daniel@example.com',
        photo: Uint8List.fromList([1, 2, 3]),
        isGuest: false,
      );
      final map = user.toMap(includeId: true);
      final userFromMap = UserModel.fromMap({
        'Id': 1,
        'Login': 'daniel',
        'Password': 'securePass123',
        'Email': 'daniel@example.com',
        'IsGuest': false,
      });
      expect(userFromMap.id, user.id);
      expect(userFromMap.login, user.login);
      expect(userFromMap.password, user.password);
      expect(userFromMap.email, user.email);
      expect(userFromMap.photo, null); // photo из fromMap всегда null
      expect(userFromMap.isGuest, user.isGuest);
    });
    test('toMap корректно формирует карту без id', () {
      final user = UserModel(
        login: 'guest',
        password: 'guestPass',
        email: 'guest@example.com',
        isGuest: true,
      );
      final map = user.toMap(includeId: false);
      expect(map.containsKey('Id'), false);
      expect(map['Login'], 'guest');
      expect(map['IsGuest'], true);
    });
    test('fromMap с отсутствующими необязательными полями', () {
      final map = {
        'Login': 'user1',
        'Password': 'pass',
        'Email': 'user1@example.com',
        'IsGuest': true,
      };
      final user = UserModel.fromMap(map);
      expect(user.login, 'user1');
      expect(user.password, 'pass');
      expect(user.email, 'user1@example.com');
      expect(user.isGuest, true);
      expect(user.photo, null);
      expect(user.id, null);
    });
    test('fromMap с null значениями в обязательных полях должен выбрасывать ошибку', () {
      final map = {
        'Id': null,
        'Login': null,
        'Password': null,
        'Email': null,
        'IsGuest': null,
      };
      expect(() => UserModel.fromMap(map), throwsA(isA<TypeError>()));
    });
    test('toMap с includeId=true добавляет id в карту', () {
      final user = UserModel(
        id: 42,
        login: 'testuser',
        password: '12345',
        email: 'test@example.com',
        isGuest: false,
      );
      final map = user.toMap(includeId: true);
      expect(map['Id'], 42);
    });
    test('toMap с includeId=false не содержит id', () {
      final user = UserModel(
        id: 42,
        login: 'testuser',
        password: '12345',
        email: 'test@example.com',
        isGuest: false,
      );
      final map = user.toMap(includeId: false);
      expect(map.containsKey('Id'), false);
    });
    test('photo всегда null при создании из Map', () {
      final map = {
        'Id': 10,
        'Login': 'photoUser',
        'Password': 'pwd',
        'Email': 'photo@example.com',
        'IsGuest': false,
        'Photo': Uint8List.fromList([10, 20, 30]),
      };
      final user = UserModel.fromMap(map);
      expect(user.photo, null);
    });
  });
  group('UserModel дополнительные тесты', () {
    test('Создание UserModel с минимальными параметрами', () {
      final user = UserModel(
        login: 'minimal',
        password: 'minpass',
        email: 'minimal@example.com',
        isGuest: false,
      );
      expect(user.id, isNull);
      expect(user.photo, isNull);
      expect(user.login, 'minimal');
      expect(user.password, 'minpass');
      expect(user.email, 'minimal@example.com');
      expect(user.isGuest, false);
    });
    test('toMap не модифицирует оригинальный объект', () {
      final user = UserModel(
        id: 5,
        login: 'orig',
        password: 'origpass',
        email: 'orig@example.com',
        isGuest: false,
      );
      final map = user.toMap(includeId: true);
      expect(user.id, 5);
      expect(user.login, 'orig');
    });
    test('fromMap не ломается при наличии лишних полей', () {
      final map = {
        'Id': 7,
        'Login': 'extra',
        'Password': 'extrapass',
        'Email': 'extra@example.com',
        'IsGuest': true,
        'ExtraField': 'should be ignored',
      };
      final user = UserModel.fromMap(map);
      expect(user.id, 7);
      expect(user.login, 'extra');
      expect(user.isGuest, true);
    });
    test('toMap правильно сериализует булево поле isGuest', () {
      final userTrue = UserModel(
        login: 'trueUser',
        password: 'pwd',
        email: 'true@example.com',
        isGuest: true,
      );
      final userFalse = UserModel(
        login: 'falseUser',
        password: 'pwd',
        email: 'false@example.com',
        isGuest: false,
      );
      expect(userTrue.toMap()['IsGuest'], isTrue);
      expect(userFalse.toMap()['IsGuest'], isFalse);
    });
    test('fromMap с некорректным типом поля isGuest выбрасывает ошибку', () {
      final map = {
        'Id': 1,
        'Login': 'wrongguest',
        'Password': 'pwd',
        'Email': 'wrong@example.com',
        'IsGuest': 'not_a_bool',
      };
      expect(() => UserModel.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}