import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () async {
              await authController.logout();
              if (!mounted) return;
              context.go(AppRouter.login);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text('ID: ${user.userId}', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text('Tên: ${user.fullName}', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
