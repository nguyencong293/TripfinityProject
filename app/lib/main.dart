import 'package:app/providers/theme_provider.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/user_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  AppRouter.initialize();
  final langController = LanguageController();
  await langController.init();

  final dio = Dio();
  final authService = AuthService(dio: dio, prefs: prefs);
  final authController = AuthController(authService: authService, prefs: prefs);
  final userService = UserService(dio: dio);
  final userController = UserController(userService: userService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => langController),
        ChangeNotifierProvider(create: (_) => authController),
        ChangeNotifierProvider(create: (_) => userController),
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
        return MaterialApp.router(
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
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
