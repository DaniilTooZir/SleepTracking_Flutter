import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tracking/ui/screens/personal_account_screen.dart';
import 'package:sleep_tracking/ui/widgets/drawer_widget.dart';

class MainMenuScreen extends StatefulWidget {
  final Widget child;
  const MainMenuScreen({super.key, required this.child});
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/sleepTracking',
    '/reportChart',
    '/recommendation',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/reportChart')) {
      _currentIndex = 1;
    } else if (location.startsWith('/recommendation')) {
      _currentIndex = 2;
    } else {
      _currentIndex = 0;
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      context.go(_routes[index]);
    }
  }
  void _openPersonalAccount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: isWideScreen ? 400 : screenWidth * 0.85,
              height: double.infinity,
              margin: const EdgeInsets.only(right: 0),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: Theme(
                  data: Theme.of(context),
                  child: const AccountDrawer(),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Placeholder(fallbackHeight: 40, fallbackWidth: 40),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _openPersonalAccount(context),
            ),
          ],
        ),
      ),
      drawer: const AccountDrawer(),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: 'Сон'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Графики',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Рекомендации',
          ),
        ],
      ),
    );
  }
}
