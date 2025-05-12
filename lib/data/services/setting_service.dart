import 'package:sleep_tracking/models/personal_data_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingService{
  final _client = Supabase.instance.client;
  // Сохраняет или обновляет личные данные пользователя
  Future<void> saveOrUpdatePersonalData(PersonalDataUser data) async {
    if (data.id == null) {
      await _client.from('PersonalData').insert(data.toMap(includeId: false));
    } else {
      await _client
          .from('PersonalData')
          .update(data.toMap(includeId: false))
          .eq('Id', data.id!);
    }
  }
  // Получает личные данные пользователя по его userId
  Future<PersonalDataUser?> fetchPersonalData(int userId) async {
    final response = await _client
        .from('PersonalData')
        .select()
        .eq('UserId', userId)
        .maybeSingle();
    return response == null ? null : PersonalDataUser.fromMap(response);
  }
  // Обновляет данные пользователя в таблице Users (логин, почта, пароль)
  Future<void> updateUserData({
    required int userId,
    String? newLogin,
    String? newEmail,
    String? newPassword,
  }) async {
    final updates = <String, dynamic>{};
    if (newLogin != null && newLogin.isNotEmpty) {
      updates['Login'] = newLogin;
    }
    if (newEmail != null && newEmail.isNotEmpty) {
      updates['Email'] = newEmail;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      updates['Password'] = newPassword;
    }
    if (updates.isNotEmpty) {
      await _client.from('Users').update(updates).eq('Id', userId);
    }
  }
  // Получает текущий пароль пользователя (для проверки при смене)
  Future<String?> getCurrentPassword(int userId) async {
    final response = await _client
        .from('Users')
        .select('Password')
        .eq('Id', userId)
        .maybeSingle();
    return response?['Password'];
  }
  // Полностью удаляет аккаунт и связанные данные пользователя
  Future<void> deleteAccount(int userId) async {
    await _client.from('PersonalData').delete().eq('UserId', userId);
    await _client.from('UserPhotos').delete().eq('UserId', userId);
    await _client.from('Users').delete().eq('Id', userId);
  }
}