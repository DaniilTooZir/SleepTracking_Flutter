import 'package:flutter/material.dart';

import 'package:sleep_tracking/data/services/setting_service.dart';

class SettingScreen extends StatefulWidget{
  const SettingScreen({super.key});

  @override
  _SettSettingScreenState createState() => _SettSettingScreenState();
}

class _SettSettingScreenState extends State<SettingScreen>{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Настройки", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildPersonalDataSection(),
              const SizedBox(height: 32),
              _buildAccountSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Личные данные", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Имя"),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Пол"),
          items: const [
            DropdownMenuItem(value: "Мужской", child: Text("Мужской")),
            DropdownMenuItem(value: "Женский", child: Text("Женский")),
            DropdownMenuItem(value: "Не указывать", child: Text("Не указывать")),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: const InputDecoration(labelText: "Дата рождения"),
          onTap: () {
            // TODO: добавить выбор даты
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Почта"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: сохранить личные данные
          },
          child: const Text("Сохранить данные"),
        ),
      ],
    );
  }
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Настройки аккаунта", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Новый логин"),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Новая почта"),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: "Старый пароль"),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: "Новый пароль"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: сменить данные
          },
          child: const Text("Обновить данные"),
        ),
        const SizedBox(height: 32),
        Divider(),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: подтверждение и удаление аккаунта
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Удалить аккаунт"),
          ),
        )
      ],
    );
  }
}