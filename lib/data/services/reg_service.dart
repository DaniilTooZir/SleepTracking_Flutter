import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegService {
  final SupabaseClient _client = SupabaseConnection.client;
  // Регистрация пользователя с проверкой входных данных
  Future<UserModel> registerUser({
    required String login,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _validateInput(login, email, password, confirmPassword);
      // не зарегистрирован ли уже пользователь с таким логином или email
      if (await isUserExists(login, email)) {
        throw Exception(
          'Пользователь с таким логином или email уже существует',
        );
      }
      // Создание нового пользователя
      final newUser = UserModel(
        login: login,
        password: password,
        email: email,
        isGuest: false,
      );

      final response =
          await _client.from('Users').insert(newUser.toMap()).select().single();

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception('Ошибка: $e');
    }
  }
  // Проверка валидности входных данных
  void _validateInput(
    String login,
    String email,
    String password,
    String confirmPassword,
  ) {
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
  // Простая проверка корректности email через регулярное выражение
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  // Проверка наличия пользователя с таким логином или email в базе данных
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
