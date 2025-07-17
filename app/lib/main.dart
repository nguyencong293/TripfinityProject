import 'package:app/providers/theme_provider.dart';
import 'package:app/views/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final langController = LanguageController();
  await langController.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => langController),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageController>(
      builder: (context, themeProvider, langController, child) {
        return MaterialApp(
          title: 'TripFinity App Project',
          locale: Locale(langController.currentLanguage),
          supportedLocales: langController.languages.keys
              .map((code) => Locale(code))
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.flutterThemeMode,
          home: OnboardingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
