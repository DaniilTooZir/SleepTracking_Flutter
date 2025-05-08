import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'userId';

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    bool isSaved = await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt(_userIdKey);
    return userId;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool isCleared = await prefs.remove(_userIdKey);
    await prefs.remove(_userIdKey);
  }
}