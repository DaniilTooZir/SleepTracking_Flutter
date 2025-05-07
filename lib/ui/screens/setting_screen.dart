import 'package:flutter/material.dart';

import 'package:sleep_tracking/data/services/setting_service.dart';

class SettingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingScreen({super.key, this.onBack});

  @override
  _SettSettingScreenState createState() => _SettSettingScreenState();
}

class _SettSettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Настройки",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Личные данные",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: "Имя",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Пол",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          items: const [
            DropdownMenuItem(value: "Мужской", child: Text("Мужской")),
            DropdownMenuItem(value: "Женский", child: Text("Женский")),
            DropdownMenuItem(
              value: "Не указывать",
              child: Text("Не указывать"),
            ),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Дата рождения",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          onTap: () {
            // TODO: добавить выбор даты
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: "Почта",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: сохранить личные данные
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Сохранить данные"),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Настройки аккаунта",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: "Новый логин",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: "Новая почта",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Старый пароль",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Новый пароль",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: сменить данные
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Обновить данные"),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: подтверждение и удаление аккаунта
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Удалить аккаунт"),
          ),
        ),
      ],
    );
  }
}
