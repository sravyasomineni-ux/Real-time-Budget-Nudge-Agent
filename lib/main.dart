import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'ui/theme.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  await dbService.init();

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('onboardingComplete') ?? false;

  runApp(
    MultiProvider(
      providers: [Provider<DatabaseService>.value(value: dbService)],
      child: PersonaApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class PersonaApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const PersonaApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PersonaBudget',
      theme: PersonaTheme.darkTheme,
      home: hasCompletedOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
