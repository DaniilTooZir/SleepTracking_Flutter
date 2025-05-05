import 'dart:typed_data';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalAccountService {
  final SupabaseClient _client = SupabaseConnection.client;
  Future<UserModel?> getUserData(int userId) async {
    try {
      final response = await _client
          .from('Users')
          .select()
          .eq('Id', userId)
          .single();

      if (response != null) {
        return UserModel.fromMap(response);
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при загрузке данных пользователя: $e');
      return null;
    }
  }
  Future<void> updateUserPhoto(String userId, Uint8List photoBytes) async {
    await _client
        .from('Users')
        .update({'Photo': photoBytes})
        .eq('Id', userId);
  }
}