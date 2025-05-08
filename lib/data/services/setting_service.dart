import 'package:sleep_tracking/models/personal_data_user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingService{
  final _client = Supabase.instance.client;
  Future<void> saveOrUpdatePersonalData(PersonalDataUser data) async {
    if (data.id == null) {
      await _client.from('PersonalData').insert(data.toMap());
    } else {
      await _client
          .from('PersonalData')
          .update(data.toMap())
          .eq('Id', data.id!);
    }
  }
  Future<PersonalDataUser?> fetchPersonalData(int userId) async {
    final response = await _client
        .from('PersonalData')
        .select()
        .eq('UserId', userId)
        .maybeSingle();
    if (response == null) return null;
    return PersonalDataUser.fromMap(response);
  }

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

  Future<String?> getCurrentPassword(int userId) async {
    final response = await _client
        .from('Users')
        .select('Password')
        .eq('Id', userId)
        .maybeSingle();
    return response?['Password'];
  }

  Future<void> deleteAccount(int userId) async {
    await _client.from('PersonalData').delete().eq('UserId', userId);
    await _client.from('UserPhotos').delete().eq('UserId', userId);
    await _client.from('Users').delete().eq('Id', userId);
  }
}