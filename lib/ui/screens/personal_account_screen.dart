import 'package:flutter/material.dart';

class PersonalAccountScreen extends StatefulWidget {
  const PersonalAccountScreen({super.key});

  @override
  _PersonalAccountScreenState createState() => _PersonalAccountScreenState();
}

class _PersonalAccountScreenState extends State<PersonalAccountScreen> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок и кнопка закрытия
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
                      // Аватар и имя
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
                          const Flexible(
                            child: Text(
                              'Имя пользователя',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Основные данные
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
                      // Контактная информация
                      const Text(
                        'Контактная информация',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Электронная почта:'),
                        subtitle: Text('пусто'),
                      ),
                      const SizedBox(height: 24),
                      // Кнопки
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: реализовать открытие формы добавления данных
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить данные'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: реализовать открытие настроек
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
