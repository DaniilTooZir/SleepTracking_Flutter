import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/data/services/personal_account_service.dart';
import 'package:sleep_tracking/models/user.dart';
import 'package:sleep_tracking/models/user_photo.dart';

class PersonalAccountScreen extends StatefulWidget {
  const PersonalAccountScreen({super.key});

  @override
  _PersonalAccountScreenState createState() => _PersonalAccountScreenState();
}

class _PersonalAccountScreenState extends State<PersonalAccountScreen> {
  UserModel? user;
  bool isLoading = true;
  Uint8List? userPhoto;

  final PersonalAccountService _accountService = PersonalAccountService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    if (userId != null) {
      final fetchedUser = await _accountService.getUserData(userId);
      final fetchedUserPhoto = await _accountService.getUserPhoto(userId);
      setState(() {
        user = fetchedUser;
        userPhoto = fetchedUserPhoto?.photo;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId != null) {
        await _accountService.updateUserPhoto(userId, bytes);
        setState(() {
          userPhoto = bytes;
        });
      }
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
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: userPhoto != null
                                ? MemoryImage(userPhoto!)
                                : null,
                            child: userPhoto == null
                                ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                                : null,
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
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Изменить фото'),
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
