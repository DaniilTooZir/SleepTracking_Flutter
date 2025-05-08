import 'package:flutter/foundation.dart';
import 'package:sleep_tracking/data/services/session_service.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  int? get userId => _userId;
  // Метод для установки userId
  void setUserId(int id) {
    _userId = id;
    SessionService.saveUserId(id);
    notifyListeners();
  }
  // Метод для сброса userId
  void clearUserId() {
    _userId = null;
    SessionService.clearSession();
    notifyListeners();
  }

  void setUserIdIfExists(int? id) {
    if (id != null) {
      _userId = id;
      notifyListeners();
    }
  }
  void logout() async {
    _userId = null;
    notifyListeners();
    await SessionService.clearSession();
  }
}