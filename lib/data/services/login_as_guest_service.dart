import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/database/connection_to_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class LoginAsGuestService {
  final SupabaseClient _client = SupabaseConnection.client;

  Future<UserModel> loginAsGuest() async {
    try {
      final guestLogin = 'Guest_${_generateRandomString(8)}';
      final guestPassword = _generateRandomString(16);

      final response =
          await _client
              .from('Users')
              .insert({
                'Login': guestLogin,
                'Password': guestPassword,
                'Email': '',
                'IsGuest': true,
              })
              .select()
              .single();

      return UserModel.fromMap(response);
    } catch (e) {
      throw Exception('Не удалось войти как гость: $e');
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
