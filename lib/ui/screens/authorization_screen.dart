import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/data/services/auth_service.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/data/services/login_as_guest_service.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/session_service.dart';

class AuthorizationScreen extends StatefulWidget {
  const AuthorizationScreen({super.key});
  @override
  _AuthorizationScreenState createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _guestService = LoginAsGuestService();

  Future<void> _authorization() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите логин и пароль')),
      );
      return;
    }

    try {
      UserModel user = await _authService.authorizationUser(
        login: login,
        password: password,
      );
      if (user.id != null) {
        Provider.of<UserProvider>(context, listen: false).setUserId(user.id!);
        await SessionService.saveUserId(user.id!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добро пожаловать, ${user.login}!')),
      );
      _loginController.clear();
      _passwordController.clear();

      context.go('/sleepTracking');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка входа: $e')));
    }
  }

  Future<void> _guestLogin() async {
    try {
      UserModel guest = await _guestService.loginAsGuest();
      Provider.of<UserProvider>(context, listen: false).setUserId(guest.id!);
      await SessionService.saveUserId(guest.id!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Вы вошли как гость.')));

      context.go('/sleepTracking');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка гостевого входа: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 600 ? 400 : double.infinity,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _loginController,
                      decoration: const InputDecoration(labelText: 'Логин'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Пароль'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authorization,
                        child: const Text('Войти'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: const Text('Нет аккаунта? Зарегистрируйтесь'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _guestLogin,
                      child: const Text('Войти как гость'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
