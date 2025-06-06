import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//Экраны для маршрутов
import 'package:sleep_tracking/ui/screens/authorization_screen.dart';
import 'package:sleep_tracking/ui/screens/personal_account_screen.dart';
import 'package:sleep_tracking/ui/screens/recommendations_screen.dart';
import 'package:sleep_tracking/ui/screens/registration_screen.dart';
import 'package:sleep_tracking/ui/screens/main_menu_screen.dart';
import 'package:sleep_tracking/ui/screens/report_chart_screen.dart';
import 'package:sleep_tracking/ui/screens/sleep_tracking_screen.dart';
import 'package:sleep_tracking/providers/user_provider.dart';
import 'package:sleep_tracking/ui/screens/setting_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => AuthorizationScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => MainMenuScreen(child: child),
      routes: [
        GoRoute(
          path: '/personalAccount',
          builder: (context, state) => PersonalAccountScreen(),
        ),
        GoRoute(
          path: '/sleepTracking',
          builder: (context, state) => SleepTrackingScreen(),
        ),
        GoRoute(
          path: '/reportChart',
          builder: (context, state) => ReportChartScreen(),
        ),
        GoRoute(
          path: '/recommendation',
          builder: (context, state) => RecommendationsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final isAtLogin = state.matchedLocation == '/';
    final isAtRegister = state.matchedLocation == '/register';

    if (userId == null && !(isAtLogin || isAtRegister)) {
      return '/';
    }

    if (userId != null && (isAtLogin || isAtRegister)) {
      return '/sleepTracking';
    }
    return null;
  },
);
