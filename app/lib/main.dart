import 'package:app/providers/theme_provider.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/user_service.dart';
import 'package:app/services/fcm_service.dart';
import 'package:app/services/recommendation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

import 'config/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/user_controller.dart';

// Instance cho local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background message handler - MUST be top-level function
/// Xử lý FCM notification khi app đóng hoặc background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📱 Background notification: ${message.data['title']}');

  // Hiển thị notification từ data payload
  if (message.data.containsKey('title') && message.data.containsKey('body')) {
    await _showNotification(
      title: message.data['title']!,
      body: message.data['body']!,
    );
  }
}

/// Hiển thị local notification
Future<void> _showNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'tripfinity_notifications',
    'TripFinity Notifications',
    channelDescription: 'Notifications for booking updates',
    importance: Importance.high,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const DarwinNotificationDetails macOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    title,
    body,
    const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macOSDetails,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Local Notifications for all platforms
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Register background message handler (only for mobile)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  debugPrint('Package name: ${packageInfo.packageName}');
  debugPrint('App name: ${packageInfo.appName}');
  debugPrint('Version: ${packageInfo.version}');
  debugPrint('Build number: ${packageInfo.buildNumber}');

  final prefs = await SharedPreferences.getInstance();
  AppRouter.initialize();
  final langController = LanguageController();
  await langController.init();

  final dio = Dio();
  final authService = AuthService(dio: dio, prefs: prefs);
  final userService = UserService(dio: dio);
  final recommendationService = RecommendationService(dio: dio);
  final authController = AuthController(
    authService: authService,
    prefs: prefs,
    userService: userService,
    recommendationService: recommendationService,
  );
  final userController = UserController(userService: userService);

  // Initialize FCM Service với authController
  final fcmService = FCMService(authController: authController);
  await fcmService.initialize();

  // Kết nối FCMService với AuthController
  authController.setFCMService(fcmService);

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
