import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tracking/models/personal_data_user.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/setting_service.dart';
import 'package:sleep_tracking/data/services/session_service.dart';

class SettingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const SettingScreen({super.key, this.onBack});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

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

  Future<void> _updateAccountSettings() async {
    final userId = context.read<UserProvider>().userId!;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    try {
      final actualPassword = await _settingService.getCurrentPassword(userId);

      if (newPassword.isNotEmpty && oldPassword != actualPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Старый пароль указан неверно')),
        );
        return;
      }
      await _settingService.updateUserData(
        userId: userId,
        newLogin: _loginController.text,
        newEmail: _emailController.text,
        newPassword: newPassword.isNotEmpty ? newPassword : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные аккаунта обновлены')),
      );
      _loginController.clear();
      _emailController.clear();
      _oldPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления: $e')),
      );
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: const Text('Вы уверены, что хотите удалить аккаунт? Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final userId = context.read<UserProvider>().userId!;
      try {
        await _settingService.deleteAccount(userId);
        context.read<UserProvider>().logout();
        await SessionService.clearSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аккаунт успешно удалён')),
        );
        context.go('/');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении: $e')),
        );
      }
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
          controller: _loginController,
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
          controller: _emailController,
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
          controller: _oldPasswordController,
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
          controller: _newPasswordController,
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
          onPressed:  _updateAccountSettings,
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
            onPressed:_confirmAndDeleteAccount,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Удалить аккаунт"),
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
