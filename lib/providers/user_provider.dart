import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  int? get userId => _userId;
  // Метод для установки userId
  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }
  // Метод для сброса userId
  void clearUserId() {
    _userId = null;
    notifyListeners();
  }
}