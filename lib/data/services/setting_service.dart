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
}