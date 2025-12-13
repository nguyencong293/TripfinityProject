import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/services/points_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

/// Thành Tích & Điểm Thưởng - Dynamic with API
class BadgesAndPointsUserScreen extends StatefulWidget {
  const BadgesAndPointsUserScreen({super.key});

  @override
  State<BadgesAndPointsUserScreen> createState() =>
      _BadgesAndPointsUserScreenState();
}

class _BadgesAndPointsUserScreenState extends State<BadgesAndPointsUserScreen> {
  final PointsService _pointsService = PointsService();

  bool _loading = true;
  int _totalPoints = 0;
  int _userId = 0;
  List<Map<String, dynamic>> _pointsHistory = [];
  List<Map<String, dynamic>> _unlockedBadges = [];
  List<Map<String, dynamic>> _allBadges = [];
  String _currentTier = 'Đồng';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.userId;

      if (userId == null) {
        debugPrint('❌ User ID is null from AuthController');
        setState(() => _loading = false);
        return;
      }

      _userId = userId;
      debugPrint('✅ User ID from AuthController: $_userId');

      debugPrint('🔄 Calling API: /points/user/$_userId/summary');
      final summary = await _pointsService.getUserPointsSummary(_userId);
      debugPrint('✅ API Response: $summary');

      setState(() {
        _totalPoints = summary['totalPoints'] ?? 0;
        _pointsHistory = List<Map<String, dynamic>>.from(
          summary['recentPoints'] ?? [],
        );
        _unlockedBadges = List<Map<String, dynamic>>.from(
          summary['unlockedBadges'] ?? [],
        );
        _allBadges = List<Map<String, dynamic>>.from(
          summary['availableBadges'] ?? [],
        );
        _currentTier = _determineTier(_totalPoints);
        _loading = false;
      });

      debugPrint('📊 Total Points: $_totalPoints');
      debugPrint('📜 Points History: ${_pointsHistory.length} items');
      debugPrint('🎖️ Unlocked Badges: ${_unlockedBadges.length} items');
      debugPrint('🏆 All Badges: ${_allBadges.length} items');
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải dữ liệu: $e')));
      }
    }
  }

  String _determineTier(int points) {
    if (points >= 5000) return 'Huyền thoại';
    if (points >= 2000) return 'Kim cương';
    if (points >= 1000) return 'Vàng';
    if (points >= 500) return 'Bạc';
    if (points >= 200) return 'Đồng';
    return 'Mới bắt đầu';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: context.textPrimaryColor),
          title: Text('account_badges_points'.tr, style: context.h5Style),
        ),
        body: Center(
          child: CircularProgressIndicator(color: context.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        title: Text('account_badges_points'.tr, style: context.h5Style),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Header KPI tiles
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        color: context.primaryColor,
                        icon: LucideIcons.star,
                        titleKey: 'badges_total_points',
                        valueText: _totalPoints.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        color: context.successColor,
                        icon: LucideIcons.badgeCheck,
                        titleKey: 'badges_current_tier',
                        valueText: _currentTier,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PillTabBar(
                  tabs: [
                    Tab(text: 'badges_member_levels'.tr),
                    Tab(text: 'badges_points_history'.tr),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    _MemberLevelsTab(
                      allBadges: _allBadges,
                      unlockedBadges: _unlockedBadges,
                      currentPoints: _totalPoints,
                    ),
                    _PointsHistoryTab(pointsHistory: _pointsHistory),
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

class _KpiTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String titleKey;
  final String valueText;

  const _KpiTile({
    required this.color,
    required this.icon,
    required this.titleKey,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color;
    final title = titleKey.tr;
    final value = valueText;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Single, clean icon chip
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.subTitleTwoStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: context.h4Style.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTabBar extends StatelessWidget {
  final List<Widget> tabs;
  const _PillTabBar({required this.tabs});

  @override
  Widget build(BuildContext context) {
    final pillColor = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : context.cardBackgroundColor;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.borderLineColor),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: context.primaryColor,
          borderRadius: BorderRadius.circular(22),
        ),
        indicatorSize: TabBarIndicatorSize.tab, // fill the tab width
        labelStyle: context.subTitleTwoStyle,
        unselectedLabelStyle: context.subTitleTwoStyle,
        labelColor: Colors.white, // selected text readable on green pill
        unselectedLabelColor: context.textSecondaryColor,
        dividerColor: Colors.transparent,
        tabs: tabs,
      ),
    );
  }
}

class _MemberLevelsTab extends StatelessWidget {
  final List<Map<String, dynamic>> allBadges;
  final List<Map<String, dynamic>> unlockedBadges;
  final int currentPoints;

  const _MemberLevelsTab({
    required this.allBadges,
    required this.unlockedBadges,
    required this.currentPoints,
  });

  IconData _getBadgeIcon(String badgeName) {
    if (badgeName.contains('Đồng')) return LucideIcons.badge;
    if (badgeName.contains('Bạc')) return LucideIcons.badgeCheck;
    if (badgeName.contains('Vàng')) return LucideIcons.award;
    if (badgeName.contains('Kim cương')) return LucideIcons.gem;
    if (badgeName.contains('Huyền thoại')) return LucideIcons.crown;
    return LucideIcons.sparkles;
  }

  bool _isUnlocked(int badgeId) {
    return unlockedBadges.any((ub) {
      final badge = ub['badge'];
      if (badge != null && badge is Map<String, dynamic>) {
        return badge['badgeId'] == badgeId;
      }
      return ub['badgeId'] == badgeId;
    });
  }

  int _getRequiredPoints(Map<String, dynamic> badge) {
    // Backend already parsed criteriaJson and returned requiredPoints
    final requiredPoints = badge['requiredPoints'];
    if (requiredPoints != null) {
      return requiredPoints is int
          ? requiredPoints
          : int.tryParse(requiredPoints.toString()) ?? 0;
    }

    // Fallback: parse criteriaJson if requiredPoints not available
    try {
      final criteriaJson = badge['criteriaJson'];
      if (criteriaJson != null && criteriaJson is String) {
        final criteria = jsonDecode(criteriaJson);
        return criteria['requiredPoints'] as int? ?? 0;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to parse criteriaJson: $e');
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (allBadges.isEmpty) {
      return Center(
        child: Text(
          'Không có huy hiệu nào',
          style: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemBuilder: (_, i) {
        final badge = allBadges[i];
        final badgeId = badge['badgeId'] ?? 0;
        final isUnlocked = _isUnlocked(badgeId);
        final requiredPoints = _getRequiredPoints(badge);

        return _LevelCard(
          icon: _getBadgeIcon(badge['badgeName'] ?? ''),
          title: badge['badgeName'] ?? '',
          description: badge['badgeDescription'] ?? '',
          isUnlocked: isUnlocked,
          currentPoints: currentPoints,
          requiredPoints: requiredPoints,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: allBadges.length,
    );
  }
}

class _LevelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final int currentPoints;
  final int requiredPoints;

  const _LevelCard({
    required this.icon,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    required this.currentPoints,
    required this.requiredPoints,
  });

  @override
  Widget build(BuildContext context) {
    final progress = requiredPoints > 0
        ? (currentPoints / requiredPoints).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderLineColor, width: 1),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? context.secondaryColor
                      : context.borderLineColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isUnlocked
                      ? context.primaryColor
                      : context.textSecondaryColor.withValues(alpha: 0.5),
                  size: 26,
                ),
              ),
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.subTitleOneStyle.copyWith(
                          color: isUnlocked
                              ? context.textPrimaryColor
                              : context.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.successColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '✓ Đã mở',
                          style: context.captionStyle.copyWith(
                            color: context.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodyTwoStyle.copyWith(
                    color: context.textSecondaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUnlocked
                              ? 'Hoàn thành'
                              : '$currentPoints / $requiredPoints điểm',
                          style: context.captionStyle.copyWith(
                            color: isUnlocked
                                ? context.successColor
                                : context.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isUnlocked && requiredPoints > currentPoints)
                          Text(
                            'Còn ${requiredPoints - currentPoints}',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: context.borderLineColor.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked
                              ? context.successColor
                              : context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsHistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> pointsHistory;

  const _PointsHistoryTab({required this.pointsHistory});

  String _formatDate(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pointsHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử điểm',
              style: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    final border = BorderSide(color: context.borderLineColor);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemBuilder: (_, i) {
        final point = pointsHistory[i];
        final reason = point['reason'] ?? 'Tích điểm';
        final points = point['points'] ?? 0;
        final date = _formatDate(point['createdAt']);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(border),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.successColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.plus,
                color: context.successColor,
                size: 20,
              ),
            ),
            title: Text(reason, style: context.subTitleTwoStyle),
            subtitle: Text(
              '+$points điểm',
              style: context.bodyTwoStyle.copyWith(
                color: context.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Text(
              date,
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: pointsHistory.length,
    );
  }
}
