import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/models/personal_data_user.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/setting_service.dart';

class SettingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingScreen({super.key, this.onBack});

  @override
  _SettSettingScreenState createState() => _SettSettingScreenState();
}

class _SettSettingScreenState extends State<SettingScreen> {
  final _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  final _settingService = SettingService();
  PersonalDataUser? _personalData;

  @override
  void initState() {
    super.initState();
    _loadPersonalData();
  }

  Future<void> _loadPersonalData() async {
    final userId = context.read<UserProvider>().userId!;
    final data = await _settingService.fetchPersonalData(userId);
    if (data != null) {
      setState(() {
        _personalData = data;
        _nameController.text = data.name;
        _selectedGender = data.gender;
        _selectedBirthDate = data.birthDate;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveData() async {
    final userId = context.read<UserProvider>().userId!;
    final data = PersonalDataUser(
      id: _personalData?.id,
      userId: userId,
      name: _nameController.text,
      gender: _selectedGender ?? '',
      birthDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
    );

    try {
      await _settingService.saveOrUpdatePersonalData(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Данные успешно обновлены')));
      setState(() {
        _personalData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при сохранении: $e')));
    }
  }

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
          controller: _nameController,
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
          value: _selectedGender,
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
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text:
                _selectedBirthDate != null
                    ? "${_selectedBirthDate!.day.toString().padLeft(2, '0')}.${_selectedBirthDate!.month.toString().padLeft(2, '0')}.${_selectedBirthDate!.year}"
                    : '',
          ),
          decoration: InputDecoration(
            labelText: "Дата рождения",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          onTap: _pickDate,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saveData,
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
            // TODO: смена данных аккаунта
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
              // TODO: удаление аккаунта с подтверждением
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Удалить аккаунт"),
          ),
        ),
      ],
    );
  }
}
