import 'dart:typed_data';
import 'dart:convert';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/models/user_photo.dart';
import 'package:sleep_tracking/models/personal_data_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalAccountService {
  final SupabaseClient _client = SupabaseConnection.client;
  // Получение данных аккаунта пользователя из таблицы Users
  Future<UserModel?> getUserData(int userId) async {
    try {
      final response = await _client
          .from('Users')
          .select()
          .eq('Id', userId)
          .maybeSingle();

      return response != null ? UserModel.fromMap(response) : null;
    } catch (e) {
      print('Ошибка при загрузке данных пользователя: $e');
      return null;
    }
  }
  // Получение личных данных пользователя из таблицы PersonalData
  Future<PersonalDataUser?> getPersonalData(int userId) async {
    try {
      final response = await _client
          .from('PersonalData')
          .select()
          .eq('UserId', userId)
          .maybeSingle();

      return response != null ? PersonalDataUser.fromMap(response) : null;
    } catch (e) {
      print('Ошибка при загрузке личных данных пользователя: $e');
      return null;
    }
  }
  // Получение фото пользователя из таблицы UserPhotos
  Future<UserPhoto?> getUserPhoto(int userId) async {
    try {
      final response = await _client
          .from('UserPhotos')
          .select()
          .eq('UserId', userId)
          .maybeSingle();

      return response != null ? UserPhoto.fromMap(response) : null;
    } catch (e) {
      print('Ошибка при загрузке фото пользователя: $e');
      return null;
    }
  }
  // Обновление или добавление фото пользователя
  Future<void> updateUserPhoto(int userId, Uint8List photoBytes) async {
    try {
      final photoBase64 = base64Encode(photoBytes);
      // есть ли уже фото у пользователя
      final existingPhoto = await getUserPhoto(userId);
      if (existingPhoto != null) {
        await _client
            .from('UserPhotos')
            .update({'Photo': photoBase64})
            .eq('UserId', userId);
      } else {
        await _client.from('UserPhotos').insert({
          'UserId': userId,
          'Photo': photoBase64,
        });
      }
    } catch (e) {
      print('Ошибка при обновлении фото пользователя: $e');
    }
  }
}