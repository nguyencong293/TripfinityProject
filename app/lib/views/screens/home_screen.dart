import 'package:app/routes/app_router.dart';
import 'package:app/views/screens/general_search_screen.dart';
import 'package:app/views/screens/trip__user_screen.dart';
import 'package:app/views/screens/trip_review_user_screen.dart';
import 'package:app/views/widgets/article_banner_card.dart';
import 'package:app/views/widgets/bottom_nav.dart';
import 'package:app/views/widgets/experience_card.dart';
import 'package:app/views/widgets/recent_item_tile.dart';
import 'package:app/views/widgets/section_header.dart';
import 'package:app/views/widgets/weekend_city_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String? _initialSearchQuery;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    DateTime? lastBackPressed;

    // Simple placeholder pages per tab (localized)
    final pages = [
      _HomeContent(
        user: user,
        onSubmitSearch: (q) {
          final query = q.trim();
          if (query.isEmpty) return;
          setState(() {
            _initialSearchQuery = query; // pass query to search screen
            _tabIndex = 1; // switch to Search tab
          });
        },
      ),
      GeneralSearchScreen(initialQuery: _initialSearchQuery),
      const TripUserScreen(),
      const TripReviewUserScreen(),
      const DashboardUserScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2)) {
          lastBackPressed = now;
          Fluttertoast.showToast(msg: "press_back_again_to_exit".tr);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        drawer: _AppDrawer(
          onNavigateToServices: () {
            setState(() {
              _tabIndex = 1; // Chuyển về tab Search
            });
          },
        ),
        body: pages[_tabIndex],
        bottomNavigationBar: BottomNav(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
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
  final ValueChanged<String> onSubmitSearch;
  const _HomeContent({required this.user, required this.onSubmitSearch});

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
                fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction:
                  TextInputAction.search, // show search action on keyboard
              onSubmitted: (value) =>
                  onSubmitSearch(value), // trigger navigation + query
              onTap: () {}, // keep existing if you want tap behavior
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
            // Categories grid (square cells, 4 per row)
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // square tiles: width == height
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 30),

            // Recently viewed
            SectionHeader(title: 'recently_viewed'.tr),
            const SizedBox(height: 8),
            SizedBox(
              height: RecentItemTile.kHeight,
              child: ListView.separated(
                key: const PageStorageKey('recently_viewed'),
                primary: false,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemBuilder: (_, i) => RecentItemTile(
                  leftImageAsset: i.isEven
                      ? 'assets/images/onboarding1.png'
                      : 'assets/images/onboarding2.png',
                  title: 'Cầu vàng',
                  subtitle: 'Chuyến tham quan ngắm cảnh...',
                  rating: 4.0,
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 10,
              ),
            ),

            const SizedBox(height: 30),

            // Fun experiences in city
            SectionHeader(
              title: 'fun_experiences_city'.tr,
              actionLabel: 'see_more'.tr,
              onAction: () {},
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: ExperienceCard.listHeight(context),
              child: ListView.separated(
                key: const PageStorageKey('experiences'),
                primary: false,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (_, i) => const ExperienceCard(
                  imageAsset: 'assets/images/onboarding1.png',
                  title: 'Sun World Bà Nà Hills',
                  rating: 4,
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: 8,
              ),
            ),

            const SizedBox(height: 30),

            // Weekend cities
            SectionHeader(title: 'weekend_ideas'.tr),
            const SizedBox(height: 8),
            SizedBox(
              height: WeekendCityCard.kHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => WeekendCityCard(
                  imageAsset: i.isEven
                      ? 'assets/images/onboarding2.png'
                      : 'assets/images/onboarding3.png',
                  city: i.isEven ? 'Nha Trang' : 'Huế',
                  country: 'Việt Nam',
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: 5,
              ),
            ),

            const SizedBox(height: 30),

            // Interesting articles banner
            SectionHeader(title: 'discover_interesting_posts'.tr),
            const SizedBox(height: 8),
            ArticleBannerCard(
              imageAsset: 'assets/images/onboarding4.png',
              title: 'Top 8 cây cầu Đà Nẵng',
              ctaLabel: 'explore_now'.tr,
            ),

            const SizedBox(height: 24),

            // Nearby restaurants (reuse ExperienceCard)
            SectionHeader(
              title: 'nearby_restaurants'.tr,
              actionLabel: 'see_more'.tr,
              onAction: () {},
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: ExperienceCard.listHeight(context),
              child: ListView.separated(
                key: const PageStorageKey('restaurants'),
                primary: false,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (_, i) => const ExperienceCard(
                  imageAsset: 'assets/images/onboarding3.png',
                  title: 'Bếp Cuốn Đà Nẵng',
                  rating: 4,
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: 10,
              ),
            ),
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
    final labelStyle = context.captionStyle.copyWith(
      color: onSurface,
      height: 1.15,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          // slightly tighter padding to avoid rounding overflows
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: context.textPrimaryColor),
              const SizedBox(height: 6),
              // Flexible text area prevents RenderFlex overflow in square tiles
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Left drawer menu
class _AppDrawer extends StatelessWidget {
  final VoidCallback onNavigateToServices;
  const _AppDrawer({required this.onNavigateToServices});

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
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                onNavigateToServices(); // Gọi callback để chuyển tab
              },
            ),
            _DrawerTile(
              title: 'drawer_contact'.tr,
              icon: LucideIcons.phone,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.contactUser),
              },
            ),
            _DrawerTile(
              title: 'drawer_posts'.tr,
              icon: LucideIcons.newspaper,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.postsList),
              },
            ),
            _DrawerTile(
              title: 'drawer_about'.tr,
              icon: LucideIcons.info,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.aboutTripfinity),
              },
            ),
            _DrawerTile(
              title: 'drawer_terms_policies'.tr,
              icon: LucideIcons.shield,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.termsPolicies),
              },
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
