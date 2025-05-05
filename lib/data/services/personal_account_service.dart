import 'dart:typed_data';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/models/user_photo.dart';
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
  Future<UserPhoto?> getUserPhoto(int userId) async {
    try {
      final response = await _client
          .from('UserPhotos')
          .select()
          .eq('UserId', userId)
          .single();

      if (response != null) {
        return UserPhoto.fromMap(response);
      } else {
        return null;
      }
    } catch (e) {
      print('Ошибка при загрузке фото пользователя: $e');
      return null;
    }
  }
  Future<void> updateUserPhoto(int userId, Uint8List photoBytes) async {
    try {
      final existingPhoto = await getUserPhoto(userId);
      if (existingPhoto != null) {
        await _client
            .from('UserPhotos')
            .update({'Photo': photoBytes})
            .eq('UserId', userId);
      } else {
        await _client.from('UserPhotos').insert({
          'UserId': userId,
          'Photo': photoBytes,
        });
      }
    } catch (e) {
      print('Ошибка при обновлении фото пользователя: $e');
    }
  }
}