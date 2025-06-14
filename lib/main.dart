import 'package:exp_tracker/screens/home_screen.dart';
// import 'package:exp_tracker/screens/onboarding_screen.dart';
import 'package:exp_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",
      home: HomeScreen(),
      // home: OnboardingScreen(),
    );
  }
}
