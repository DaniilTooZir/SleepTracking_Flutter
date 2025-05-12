import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'userId';
  // Сохраняет userId в локальное хранилище
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }
  // Получает сохранённый userId
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_userIdKey);
    return userId;
  }
  // Очищает сохранённую сессию
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}