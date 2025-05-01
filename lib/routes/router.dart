import 'package:go_router/go_router.dart';

//Экраны для маршрутов
import 'package:sleep_tracking/ui/screens/authorization_screen.dart';
import 'package:sleep_tracking/ui/screens/personal_account_screen.dart';
import 'package:sleep_tracking/ui/screens/recommendations_screen.dart';
import 'package:sleep_tracking/ui/screens/registration_screen.dart';
import 'package:sleep_tracking/ui/screens/main_menu_screen.dart';
import 'package:sleep_tracking/ui/screens/report_chart_screen.dart';
import 'package:sleep_tracking/ui/screens/sleep_tracking_screen.dart';

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
          builder: (context, state) {
            final userId = state.extra as int;
            return SleepTrackingScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/reportChart',
          builder: (context, state) => ReportChartScreen(),
        ),
        GoRoute(
          path: '/recommendation',
          builder: (context, state) => RecommendationsScreen(),
        ),
      ],
    ),
  ],
);
