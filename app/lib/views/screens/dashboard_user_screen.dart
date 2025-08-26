import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/language_controller.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import 'package:go_router/go_router.dart';

/// Dashboard tài khoản: bám theo theme và hỗ trợ đa ngôn ngữ
class DashboardUserScreen extends StatelessWidget {
  const DashboardUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi ngôn ngữ để rebuild UI khi đổi language
    return Consumer<LanguageController>(
      builder: (context, _, __) {
        final authController = context.watch<AuthController>();
        final user = authController.currentUser;
        final fullName = user?.fullName;
        final email = user?.email;

        // Fake data (placeholder) — có thể thay bằng dữ liệu thực sau
        const bookedCount = 1;
        const processingCount = 1;
        const points = 1000;
        const notifications = '99+';

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(fullName: fullName, email: email),
                const SizedBox(height: 16),

                // Grid các thẻ thống kê
                _StatsGrid(
                  booked: bookedCount,
                  processing: processingCount,
                  points: points,
                  notifications: notifications,
                ),

                const SizedBox(height: 12),

                // Menu mục hành động
                _ActionTile(
                  icon: LucideIcons.history,
                  title: 'account_booking_history'.tr,
                  onTap: () {},
                ),
                _ActionTile(
                  icon: LucideIcons.lifeBuoy,
                  title: 'account_support'.tr,
                  onTap: () {},
                ),
                _ActionTile(
                  icon: LucideIcons.settings2,
                  title: 'account_settings'.tr,
                  onTap: () {
                    context.push(AppRouter.optionSetting);
                  },
                ),

                const SizedBox(height: 20),

                // Nút đăng xuất
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authController.logout();
                      if (context.mounted) context.go(AppRouter.login);
                    },
                    child: Text('logout'.tr),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String? fullName;
  final String? email;
  const _Header({required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameText = fullName ?? 'Người dùng';
    final subtitle = email ?? '-';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: context.secondaryColor,
          child: Text(
            (nameText.isNotEmpty ? nameText[0].toUpperCase() : '?'),
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nameText,
                style: context.h4Style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.settings),
          color: context.textPrimaryColor,
          onPressed: () {
            context.push(AppRouter.profileUser);
          },
          tooltip: 'account_info'.tr,
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int booked;
  final int processing;
  final int points;
  final String notifications;
  const _StatsGrid({
    required this.booked,
    required this.processing,
    required this.points,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.8,
        ),
        children: [
          _StatCard(
            value: '$booked',
            label: 'account_booked'.tr,
            icon: LucideIcons.checkCircle,
          ),
          _StatCard(
            value: '$processing',
            label: 'account_processing'.tr,
            icon: LucideIcons.timer,
          ),
          _StatCard(
            value: '$points',
            label: 'account_badges_points'.tr,
            icon: LucideIcons.medal,
          ),
          _StatCard(
            value: notifications,
            label: 'account_notifications'.tr,
            icon: LucideIcons.bell,
            onTap: () => context.push(AppRouter.notifications),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : context.cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: context.primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: context.h4Style.copyWith(
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: context.bodyTwoStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _ActionTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: context.primaryColor),
        title: Text(title, style: context.subTitleOneStyle),
        trailing: Icon(
          LucideIcons.chevronRight,
          color: context.iconDisabledColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
