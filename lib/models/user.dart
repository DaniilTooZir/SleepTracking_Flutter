import 'dart:typed_data';
// Модель пользователя
class UserModel{
  final int? id;
  final String login;
  final String password;
  final String email;
  final Uint8List? photo;
  final bool isGuest;

  UserModel({
    this.id,
    required this.login,
    required this.password,
    required this.email,
    this.photo,
    required this.isGuest
});
  // Создание объекта модели из карты (из Supabase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['Id'],
      login: map['Login'],
      password: map['Password'],
      email: map['Email'],
      photo: null,
      isGuest: map['IsGuest'],
    );
  }
  // Преобразование объекта модели в карту для отправки в Supabase
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'Login': login,
      'Password': password,
      'Email': email,
      'IsGuest': isGuest,
    };

    if(includeId && id != null){
      map['Id'] = id;
    }
    return map;
  }
}