import 'package:app/views/screens/onboarding/onboarding_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  // private constructor
  AppRouter._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';

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
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_completed') ?? false;
    final currentPath = state.uri.toString();

    // Chưa xem onboarding → redirect to onboarding
    if (!hasSeenOnboarding && currentPath != onboarding) {
      return onboarding;
    }

    // Đã xem onboarding nhưng vẫn ở onboarding → redirect to home
    if (hasSeenOnboarding && currentPath == onboarding) {
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
    ];
  }

  /// Build error page
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Trang không tìm thấy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
