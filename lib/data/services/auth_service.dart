import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConnection.client;
  // Метод авторизации по логину и паролю
  Future<UserModel> authorizationUser({
    required String login,
    required String password,
  }) async {
    try {
      // Запрос к таблице Users с фильтрацией по логину и паролю
      final response =
          await _client
              .from('Users')
              .select()
              .eq('Login', login)
              .eq('Password', password)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        throw AuthException('Неверный логин или пароль');
      }
      // Преобразование полученных данных в модель пользователя
      return UserModel.fromMap(response);
    }
    on PostgrestException catch (e) {
      throw AuthException('Ошибка базы данных: ${e.message}');
    } on AuthException {
      rethrow; //чтобы пробросить свои ошибки дальше
    }
    catch (e) {
      throw Exception('Неизвестная ошибка при входе: $e');
    }
  }
}
// Кастомное исключение для ошибок авторизации
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
