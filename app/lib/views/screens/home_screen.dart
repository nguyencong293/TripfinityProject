import 'package:app/views/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import 'dashboard_user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    // Simple placeholder pages per tab
    final pages = [
      _HomeContent(user: user, authController: authController),
      const Center(child: Text('Tìm kiếm')),
      const Center(child: Text('Chuyến đi')),
      const Center(child: Text('Đánh giá')),
      const DashboardUserScreen(),
    ];

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: pages[_tabIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final dynamic user;
  final AuthController authController;
  const _HomeContent({required this.user, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user != null) ...[
            Text('ID: ${user.userId}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Tên: ${user.fullName}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Email: ${user.email}', style: const TextStyle(fontSize: 20)),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.login),
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}
