import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/personal_account_service.dart';
import 'package:sleep_tracking/models/user.dart';

class PersonalAccountScreen extends StatefulWidget {
  const PersonalAccountScreen({super.key});

  @override
  _PersonalAccountScreenState createState() => _PersonalAccountScreenState();
}

class _PersonalAccountScreenState extends State<PersonalAccountScreen> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      final service = PersonalAccountService();
      final fetchedUser = await service.getUserData(userId);
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Личный кабинет',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              user?.login ?? 'Имя пользователя',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Основные данные',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.badge),
                        title: Text('Имя:'),
                        subtitle: Text('пусто'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.transgender),
                        title: Text('Пол:'),
                        subtitle: Text('пусто'),
                      ),
                      const ListTile(
                        leading: Icon(Icons.cake),
                        title: Text('Дата рождения:'),
                        subtitle: Text('пусто'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Контактная информация',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Электронная почта:'),
                        subtitle: Text(user?.email ?? 'пусто'),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              //реализовать открытие формы добавления данных
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить данные'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              //реализовать открытие настроек
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Настройки'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
