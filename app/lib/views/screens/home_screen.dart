import 'package:app/routes/app_router.dart';
import 'package:app/views/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

// + theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

import '../../controllers/auth_controller.dart';
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

    // Simple placeholder pages per tab (localized)
    final pages = [
      _HomeContent(user: user),
      Center(child: Text('nav_search'.tr, style: context.bodyOneStyle)),
      Center(child: Text('nav_trips'.tr, style: context.bodyOneStyle)),
      Center(child: Text('nav_reviews'.tr, style: context.bodyOneStyle)),
      const DashboardUserScreen(),
    ];

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      drawer: const _AppDrawer(),
      body: pages[_tabIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

// Dữ liệu danh mục: dùng key i18n thay vì label cứng
class _Category {
  final IconData icon;
  final String labelKey;
  const _Category(this.icon, this.labelKey);
}

// Redesigned home content to match the provided UI
class _HomeContent extends StatelessWidget {
  final dynamic user;
  const _HomeContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final categories = const <_Category>[
      _Category(LucideIcons.hotel, 'cat_hotels'),
      _Category(LucideIcons.utensils, 'cat_food'),
      _Category(LucideIcons.ticket, 'cat_tickets'),
      _Category(LucideIcons.partyPopper, 'cat_entertainment'),
      _Category(LucideIcons.map, 'cat_itinerary'),
      _Category(LucideIcons.tag, 'cat_deals'),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo + actions
            Row(
              children: [
                Image.asset(
                  'assets/images/logotripfinity.png',
                  height: 32,
                  color: context.textPrimaryColor,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(LucideIcons.bell, color: context.textPrimaryColor),
                  onPressed: () {
                    context.push(AppRouter.notifications);
                  },
                ),
                IconButton(
                  icon: Icon(LucideIcons.menu, color: context.textPrimaryColor),
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: context.textPrimaryColor,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                // dùng token từ theme
                fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // Optional greeting (uses user if available)
            if (user != null) ...[
              Text(
                '${'hello'.tr}, ${user.fullName} 👋',
                style: context.subTitleTwoStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Categories grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((c) {
                return _CategoryItem(
                  icon: c.icon,
                  label: c.labelKey.tr,
                  surface: context.cardBackgroundColor,
                  onSurface: context.textSecondaryColor,
                  onTap: () {},
                );
              }).toList(),
            ),
            // ...add more sections (banners, lists) here if needed...
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surface;
  final Color onSurface;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.surface,
    required this.onSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 16 * 2 - 12 * 3) / 4,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: context.textPrimaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.captionStyle.copyWith(
                color: onSurface,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Left drawer menu
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simple brand mark with logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logotripfinity.png',
                    height: 40,
                    color: context.textPrimaryColor,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerTile(
              title: 'drawer_home'.tr,
              icon: LucideIcons.home,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerTile(
              title: 'drawer_services'.tr,
              icon: LucideIcons.briefcase,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              title: 'drawer_contact'.tr,
              icon: LucideIcons.phone,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              title: 'drawer_posts'.tr,
              icon: LucideIcons.newspaper,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              title: 'drawer_about'.tr,
              icon: LucideIcons.info,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerTile(
              title: 'drawer_terms_policies'.tr,
              icon: LucideIcons.shield,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: context.textPrimaryColor),
      title: Text(title, style: context.bodyOneStyle),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: context.textPrimaryColor,
      ),
      onTap: onTap,
    );
  }
}
