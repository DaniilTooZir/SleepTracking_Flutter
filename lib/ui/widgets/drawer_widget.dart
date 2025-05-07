import 'package:flutter/material.dart';
import 'package:sleep_tracking/ui/screens/personal_account_screen.dart';
import 'package:sleep_tracking/ui/screens/setting_screen.dart';

class AccountDrawer extends StatefulWidget {
  const AccountDrawer({super.key});

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}
class _AccountDrawerState extends State<AccountDrawer> {
  bool showSettings = false;

  void toggleScreen() {
    setState(() {
      showSettings = !showSettings;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: showSettings
          ? SettingScreen(onBack: toggleScreen)
          : PersonalAccountScreen(onSettingsPressed: toggleScreen),
    );
  }
}
