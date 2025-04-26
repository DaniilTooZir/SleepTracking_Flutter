import 'package:flutter/material.dart';
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
    GoRoute(path: '/main', builder: (context, state) => MainMenuScreen()),
    GoRoute(path: '/sleepTracking', builder: (context, state) => SleepTrackingScreen()),
    GoRoute(path: '/reportChart', builder: (context, state) => ReportChartScreen()),
    GoRoute(path: '/recommendation', builder: (context, state) => RecommendationsScreen()),
    GoRoute(path: '/personalAccount', builder: (context, state) => PersonalAccountScreen()),
  ],
);
