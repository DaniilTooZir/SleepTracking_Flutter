import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sleep_tracking/data/services/auth_service.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../mocks/mock_supabase_client.mocks.dart';

void main() {
  group('AuthService', () {
    late MockSupabaseClient mockClient;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late AuthService authService;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      authService = AuthService(supabaseClient: mockClient);
    });

    test('authorizationUser - успешная авторизация', () async {
      final mockUserData = {
        'Id': 1,
        'Login': 'danik',
        'Password': '123456',
        'Email': 'danik@example.com',
        'IsGuest': false,
        'Photo': null,
      };

      // Настройка цепочки вызовов Supabase
      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Login', 'danik')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Password', '123456')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => mockUserData);

      final user = await authService.authorizationUser(
        login: 'danik',
        password: '123456',
      );

      expect(user.login, equals('danik'));
      expect(user.email, equals('danik@example.com'));
      expect(user.isGuest, isFalse);
    });

    test('authorizationUser - неверный логин или пароль', () async {
      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Login', anyNamed('column'), any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Password', anyNamed('column'), any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenAnswer((_) async => null);

      expect(
            () => authService.authorizationUser(
          login: 'wrong',
          password: 'wrong',
        ),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Неверный логин или пароль'))),
      );
    });

    test('authorizationUser - ошибка Supabase', () async {
      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle())
          .thenThrow(PostgrestException(message: 'Connection lost'));

      expect(
            () => authService.authorizationUser(
          login: 'danik',
          password: '123456',
        ),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Ошибка базы данных'))),
      );
    });
    test('authorizationUser - пустой логин вызывает AuthException', () async {
      expect(
            () => authService.authorizationUser(login: '', password: '123456'),
        throwsA(isA<AuthException>()),
      );
    });
    test('authorizationUser - пустой пароль вызывает AuthException', () async {
      expect(
            () => authService.authorizationUser(login: 'danik', password: ''),
        throwsA(isA<AuthException>()),
      );
    });
    test('authorizationUser - возвращает объект типа UserModel', () async {
      final userMap = {
        'Id': 10,
        'Login': 'admin',
        'Password': 'admin123',
        'Email': 'admin@test.com',
        'Photo': null,
        'IsGuest': false,
      };
      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Login', 'admin')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Password', 'admin123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => userMap);

      final user = await authService.authorizationUser(
        login: 'admin',
        password: 'admin123',
      );
      expect(user, isA<UserModel>());
    });
    test('AuthException toString() возвращает корректное сообщение', () {
      final exception = AuthException('Ошибка авторизации');
      expect(exception.toString(), equals('AuthException: Ошибка авторизации'));
    });
    test('authorizationUser - неизвестная ошибка выбрасывает Exception', () async {
      when(mockClient.from('Users')).thenThrow(Exception('Что-то пошло не так'));

      expect(
            () => authService.authorizationUser(login: 'any', password: 'any'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'description', contains('Неизвестная ошибка'))),
      );
    });
    test('authorizationUser - повторно выбрасывает AuthException', () async {
      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenThrow(AuthException('Повторный выброс'));

      expect(
            () => authService.authorizationUser(login: 'fail', password: 'fail'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', 'Повторный выброс')),
      );
    });
    test('authorizationUser - корректно обрабатывает null поля', () async {
      final userMap = {
        'Id': 5,
        'Login': 'nuller',
        'Password': 'qwerty',
        'Email': null,
        'Photo': null,
        'IsGuest': true,
      };

      when(mockClient.from('Users')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Login', 'nuller')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('Password', 'qwerty')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => userMap);

      final user = await authService.authorizationUser(login: 'nuller', password: 'qwerty');

      expect(user.login, equals('nuller'));
      expect(user.email, isNull);
      expect(user.isGuest, isTrue);
    });
  });
}
