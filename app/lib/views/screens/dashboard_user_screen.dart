import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/language_controller.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/services/points_service.dart';
import 'package:app/services/hotel_booking_api_service.dart';
import 'package:app/services/tour_booking_api_service.dart';
import 'package:app/services/restaurant_booking_api_service.dart';
import 'package:app/services/attraction_booking_api_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'confirmed_bookings_screen.dart';
import 'pending_bookings_screen.dart';

/// Dashboard tài khoản: bám theo theme và hỗ trợ đa ngôn ngữ
class DashboardUserScreen extends StatefulWidget {
  const DashboardUserScreen({super.key});

  @override
  State<DashboardUserScreen> createState() => _DashboardUserScreenState();
}

class _DashboardUserScreenState extends State<DashboardUserScreen> {
  final PointsService _pointsService = PointsService();
  int _totalPoints = 0;
  bool _loadingPoints = true;
  int _bookedCount = 0;
  int _processingCount = 0;
  bool _loadingBookings = true;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _loadBookingCounts();
  }

  Future<void> _loadBookingCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() => _loadingBookings = false);
        return;
      }

      int confirmed = 0;
      int pending = 0;

      final hotelApi = HotelBookingApiService(dio: dio, prefs: prefs);
      final tourApi = TourBookingApiService(dio: dio, prefs: prefs);
      final restaurantApi = RestaurantBookingApiService(dio: dio, prefs: prefs);
      final attractionApi = AttractionBookingApiService(dio: dio, prefs: prefs);

      // Hotel bookings
      try {
        final hotelBookings = await hotelApi.getBookingsByUser(userId);
        for (var b in hotelBookings) {
          if (b['providerConfirmed'] == 1) {
            confirmed++;
          } else if (b['providerConfirmed'] == 0 ||
              b['providerConfirmed'] == null) {
            pending++;
          }
        }
      } catch (e) {
        debugPrint('Error loading hotel bookings: $e');
      }

      // Tour bookings
      try {
        final tourBookings = await tourApi.getBookingsByUser(userId);
        for (var b in tourBookings) {
          if (b['providerConfirmed'] == 1) {
            confirmed++;
          } else if (b['providerConfirmed'] == 0 ||
              b['providerConfirmed'] == null) {
            pending++;
          }
        }
      } catch (e) {
        debugPrint('Error loading tour bookings: $e');
      }

      // Restaurant bookings
      try {
        final restaurantBookings = await restaurantApi.getBookingsByUser(
          userId,
        );
        for (var b in restaurantBookings) {
          if (b['providerConfirmed'] == 1) {
            confirmed++;
          } else if (b['providerConfirmed'] == 0 ||
              b['providerConfirmed'] == null) {
            pending++;
          }
        }
      } catch (e) {
        debugPrint('Error loading restaurant bookings: $e');
      }

      // Attraction bookings
      try {
        final attractionBookings = await attractionApi.getBookingsByUser(
          userId,
        );
        for (var b in attractionBookings) {
          if (b['providerConfirmed'] == 1) {
            confirmed++;
          } else if (b['providerConfirmed'] == 0 ||
              b['providerConfirmed'] == null) {
            pending++;
          }
        }
      } catch (e) {
        debugPrint('Error loading attraction bookings: $e');
      }

      if (mounted) {
        setState(() {
          _bookedCount = confirmed;
          _processingCount = pending;
          _loadingBookings = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading booking counts: $e');
      if (mounted) {
        setState(() => _loadingBookings = false);
      }
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.userId;

      if (userId != null) {
        debugPrint('📊 Loading points for user ID: $userId');
        final points = await _pointsService.getTotalPoints(userId);
        if (mounted) {
          setState(() {
            _totalPoints = points;
            _loadingPoints = false;
          });
        }
        debugPrint('✅ Total points loaded: $points');
      } else {
        debugPrint('⚠️ User ID is null');
        if (mounted) {
          setState(() => _loadingPoints = false);
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading points: $e');
      if (mounted) {
        setState(() => _loadingPoints = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi ngôn ngữ để rebuild UI khi đổi language
    return Consumer<LanguageController>(
      builder: (context, _, __) {
        final authController = context.watch<AuthController>();
        final user = authController.currentUser;
        final fullName = user?.fullName;
        final email = user?.email;

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
                  booked: _loadingBookings ? 0 : _bookedCount,
                  processing: _loadingBookings ? 0 : _processingCount,
                  points: _loadingPoints ? 0 : _totalPoints,
                  notifications: notifications,
                  loadingPoints: _loadingPoints,
                  loadingBookings: _loadingBookings,
                  onBookedTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmedBookingsScreen(),
                      ),
                    );
                  },
                  onProcessingTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingBookingsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Menu mục hành động
                _ActionTile(
                  icon: LucideIcons.history,
                  title: 'account_booking_history'.tr,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmedBookingsScreen(),
                      ),
                    );
                  },
                ),
                _ActionTile(
                  icon: LucideIcons.lifeBuoy,
                  title: 'account_support'.tr,
                  onTap: () {
                    context.push(AppRouter.chatHelpBot);
                  },
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
  final bool loadingPoints;
  final bool loadingBookings;
  final VoidCallback? onBookedTap;
  final VoidCallback? onProcessingTap;

  const _StatsGrid({
    required this.booked,
    required this.processing,
    required this.points,
    required this.notifications,
    this.loadingPoints = false,
    this.loadingBookings = false,
    this.onBookedTap,
    this.onProcessingTap,
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
            value: loadingBookings ? '...' : '$booked',
            label: 'account_booked'.tr,
            icon: LucideIcons.checkCircle,
            onTap: onBookedTap,
          ),
          _StatCard(
            value: loadingBookings ? '...' : '$processing',
            label: 'account_processing'.tr,
            icon: LucideIcons.timer,
            onTap: onProcessingTap,
          ),
          _StatCard(
            value: loadingPoints ? '...' : '$points',
            label: 'account_badges_points'.tr,
            icon: LucideIcons.medal,
            onTap: () => context.push(AppRouter.badgesPoints),
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
