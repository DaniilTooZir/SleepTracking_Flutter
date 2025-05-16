import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/services/reg_service.dart';

import '../mocks/mock_supabase_client.mocks.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestTable extends Mock implements PostgrestTable {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late MockPostgrestTable mockTable;
  late MockPostgrestFilterBuilder mockFilter;
  late RegService regService;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockTable = MockPostgrestTable();
    mockFilter = MockPostgrestFilterBuilder();
    regService = RegService()
      .._client = mockClient;
  });
  test('Успешная регистрация возвращает UserModel', () async {
    when(mockClient.from('Users')).thenReturn(mockTable);
    when(mockTable.select('Id')).thenReturn(mockFilter);
    when(mockFilter.or(any)).thenAnswer((_) async => []);
    when(mockTable.insert(any)).thenReturn(mockFilter);
    when(mockFilter.select()).thenReturn(mockFilter);
    when(mockFilter.single()).thenAnswer((_) async =>
    {
      'Id': 1,
      'Login': 'newuser',
      'Password': '123456',
      'Email': 'test@example.com',
      'IsGuest': false,
      'Photo': null,
    });

    final user = await regService.registerUser(
      login: 'newuser',
      email: 'test@example.com',
      password: '123456',
      confirmPassword: '123456',
    );

    expect(user.login, equals('newuser'));
  });
  test('Пустой логин вызывает исключение', () {
    expect(
          () =>
          regService.registerUser(
            login: '',
            email: 'test@test.com',
            password: '123',
            confirmPassword: '123',
          ),
      throwsA(predicate((e) =>
          e.toString().contains('Логин не может быть пустым'))),
    );
  });
  test('Пустой email вызывает исключение', () {
    expect(
          () =>
          regService.registerUser(
            login: 'user',
            email: '',
            password: '123',
            confirmPassword: '123',
          ),
      throwsA(predicate((e) => e.toString().contains('Некорректный email'))),
    );
  });
  test('Некорректный email вызывает исключение', () {
    expect(
          () =>
          regService.registerUser(
            login: 'user',
            email: 'not-an-email',
            password: '123',
            confirmPassword: '123',
          ),
      throwsA(predicate((e) => e.toString().contains('Некорректный email'))),
    );
  });
  test('Пустой пароль вызывает исключение', () {
    expect(
          () =>
          regService.registerUser(
            login: 'user',
            email: 'test@test.com',
            password: '',
            confirmPassword: '',
          ),
      throwsA(predicate((e) =>
          e.toString().contains('Пароль не может быть пустым'))),
    );
  });
  test('Пароли не совпадают вызывает исключение', () {
    expect(
          () =>
          regService.registerUser(
            login: 'user',
            email: 'test@test.com',
            password: '123',
            confirmPassword: '456',
          ),
      throwsA(predicate((e) => e.toString().contains('Пароли не совпадают'))),
    );
  });
  test('Пользователь с таким логином или email уже существует', () async {
    when(mockClient.from('Users')).thenReturn(mockTable);
    when(mockTable.select('Id')).thenReturn(mockFilter);
    when(mockFilter.or(any)).thenAnswer((_) async => [{'Id': 1}]);

    expect(
          () =>
          regService.registerUser(
            login: 'existing',
            email: 'exist@mail.com',
            password: '123456',
            confirmPassword: '123456',
          ),
      throwsA(predicate((e) => e.toString().contains('уже существует'))),
    );
  });
  test(
      'Ошибка при проверке существующего пользователя пробрасывается', () async {
    when(mockClient.from('Users')).thenReturn(mockTable);
    when(mockTable.select('Id')).thenThrow(Exception('supabase error'));

    expect(
          () => regService.isUserExists('user', 'mail'),
      throwsA(isA<Exception>().having((e) => e.toString(), 'msg',
          contains('Ошибка при проверке'))),
    );
  });
  test('isValidEmail правильно валидирует email', () {
    expect(regService._isValidEmail('valid@mail.com'), isTrue);
    expect(regService._isValidEmail('nope'), isFalse);
  });
  test('_validateInput - валидные данные не вызывают исключение', () {
    expect(
          () =>
          regService._validateInput(
              'user', 'user@mail.com', '123456', '123456'),
      returnsNormally,
    );
  });
  test('Возвращаемый UserModel содержит правильный email', () async {
    when(mockClient.from('Users')).thenReturn(mockTable);
    when(mockTable.select('Id')).thenReturn(mockFilter);
    when(mockFilter.or(any)).thenAnswer((_) async => []);
    when(mockTable.insert(any)).thenReturn(mockFilter);
    when(mockFilter.select()).thenReturn(mockFilter);
    when(mockFilter.single()).thenAnswer((_) async =>
    {
      'Id': 5,
      'Login': 'newbie',
      'Password': '111222',
      'Email': 'newbie@test.com',
      'IsGuest': false,
      'Photo': null,
    });

    final user = await regService.registerUser(
      login: 'newbie',
      email: 'newbie@test.com',
      password: '111222',
      confirmPassword: '111222',
    );

    expect(user.email, equals('newbie@test.com'));
  });
  test('Ошибка при вставке нового пользователя пробрасывается', () async {
    when(mockClient.from('Users')).thenReturn(mockTable);
    when(mockTable.select('Id')).thenReturn(mockFilter);
    when(mockFilter.or(any)).thenAnswer((_) async => []);
    when(mockTable.insert(any)).thenThrow(Exception('Ошибка вставки'));

    expect(
          () =>
          regService.registerUser(
            login: 'failman',
            email: 'fail@fail.com',
            password: 'fail',
            confirmPassword: 'fail',
          ),
      throwsA(predicate((e) => e.toString().contains('Ошибка:'))),
    );
  });
}
