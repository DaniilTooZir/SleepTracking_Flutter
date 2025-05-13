import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
//Сервис для входа как гостя
class LoginAsGuestService {
  final SupabaseClient _client = SupabaseConnection.client;
  //Метод для входа в приложение как гость.
  //Создает нового пользователя с рандомными логином и паролем.
  Future<UserModel> loginAsGuest() async {
    try {
      final guestLogin = 'Guest_${_generateRandomString(8)}';
      final guestPassword = _generateRandomString(16);

      final response =
          await _client
              .from('Users')
              .insert({
                'Login': guestLogin,
                'Password': guestPassword,
                'Email': '',
                'IsGuest': true,
              })
              .select()
              .single();

      return UserModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw Exception('Ошибка при создании гостевого аккаунта: ${e.message}');
    }
    catch (e) {
      throw Exception('Не удалось войти как гость: $e');
    }
  }
  // Генерация случайной строки указанной длины.
  // Используется для логина и пароля.
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
