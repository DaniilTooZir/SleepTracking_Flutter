import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class RegService {
  final SupabaseClient _client = SupabaseConnection.client;

  Future<UserModel> registerUser({
    required String login,
    required String email,
    required String password,
    required String confirmPassword,
    Uint8List? photo,
  }) async{
    try{
      _validateInput(login, email, password, confirmPassword);

      final newUser = UserModel(
        login: login,
        password: password,
        email: email,
        isGuest: false
      );

      final response = await _client.from('Users').insert(newUser.toMap()).select().single();

      return UserModel.fromMap(response);

    }
    catch(e){
      throw Exception('Ошибка: $e');
    }
  }
  void _validateInput(String login, String email, String password, String confirmPassword){
    if (login.isEmpty) {
      throw Exception('Логин не может быть пустым');
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      throw Exception('Некорректный email');
    }
    if (password.isEmpty) {
      throw Exception('Пароль не может быть пустым');
    }
    if (password != confirmPassword) {
      throw Exception('Пароли не совпадают');
    }
  }
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  Future<bool> isUserExists(String login, String email) async {
    try {
      final response = await _client
          .from('Users')
          .select('Id')
          .or('Login.eq.$login,Email.eq.$email')
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Ошибка при проверке существования пользователя: $e');
    }
  }
}

