import 'package:flutter/cupertino.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConnection.client;

  Future<UserModel> authorizationUser({
    required String login,
    required String password,
  }) async {
    try {
      final response =
          await _client
              .from('Users')
              .select()
              .eq('Login', login)
              .eq('Password', password)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        throw Exception('Пользователь не найден или неверный пароль');
      }

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка авторизации: $e');
    }
  }
}
