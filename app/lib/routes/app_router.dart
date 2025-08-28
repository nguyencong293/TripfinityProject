import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/views/screens/badges_and_points_user_screen.dart';
import 'package:app/views/screens/forget_account_screen.dart';
import 'package:app/views/screens/login_screen.dart';
import 'package:app/views/screens/onboarding_screen.dart';
import 'package:app/views/screens/register_screen.dart';
import 'package:app/views/screens/profile_view_user_screen.dart';
import 'package:app/views/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/option_setting_screen.dart';

class AppRouter {
  // private constructor
  AppRouter._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgetAccount = '/forget-account';
  static const String profileUser = '/profile-user';
  static const String optionSetting = '/option-setting';
  static const String notifications = '/notifications';
  static const String badgesPoints = '/badges-and-points';

  // router configurations
  static late final GoRouter _router;

  static GoRouter get router => _router;

  /// Initialize the router configuration
  static void initialize() {
    _router = GoRouter(
      initialLocation: home,
      redirect: _handleRedirect,
      routes: _buildRoutes(),
      errorBuilder: _buildErrorPage,
    );
  }

  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    // Kiểm tra trạng thái đăng nhập
    final authController = context.read<AuthController>();
    final isLoggedIn = authController.isLoggedIn;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_completed') ?? false;
    final currentPath = state.uri.toString();

    const publicPaths = [login, register, forgetAccount];

    // Chưa xem onboarding → redirect to onboarding
    if (!hasSeenOnboarding && currentPath != onboarding) {
      return onboarding;
    }

    // Đã xem onboarding nhưng chưa đăng nhập
    if (hasSeenOnboarding &&
        !isLoggedIn &&
        !publicPaths.contains(currentPath)) {
      return login;
    }

    // Đã đăng nhập nhưng vào trang public → về home
    if (isLoggedIn && publicPaths.contains(currentPath)) {
      return home;
    }
    return null;
  }

  static List<RouteBase> _buildRoutes() {
    return [
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: forgetAccount,
        name: 'forget-account',
        builder: (context, state) => const ForgetAccountScreen(),
      ),
      GoRoute(
        path: profileUser,
        name: 'profile-user',
        builder: (context, state) => const ProfileViewUserScreen(),
      ),
      GoRoute(
        path: optionSetting,
        name: 'option-setting',
        builder: (context, state) => const OptionSettingScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: badgesPoints, // <-- add
        name: 'badges-and-points',
        builder: (context, state) => const BadgesAndPointsUserScreen(),
      ),
    ];
  }

  /// Build error page
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: context.backgroundColor,
      body: Center(
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: context.errorBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text('page_not_found'.tr, style: context.h5Style),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: Text('back_to_home'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
