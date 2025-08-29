import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// UI tĩnh: Thành Tích & Điểm Thưởng
/// - Bám theo theme + .tr localization
/// - Dùng icon Lucide
class BadgesAndPointsUserScreen extends StatelessWidget {
  const BadgesAndPointsUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tĩnh mô phỏng theo thiết kế
    const totalPoints = 1000;
    const currentTierKey = 'badges_tier_potential'; // "Cấp độ Tiềm năng"

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
                        color:
                            context.primaryColor, // dùng màu chủ đạo từ theme
                        icon: LucideIcons.star,
                        titleKey: 'badges_total_points',
                        valueText: totalPoints.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        color:
                            context.successColor, // dùng màu success từ theme
                        icon: LucideIcons.badgeCheck,
                        titleKey: 'badges_current_tier',
                        valueKey: currentTierKey,
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
                  children: const [_MemberLevelsTab(), _PointsHistoryTab()],
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
  final String? valueText; // nếu muốn truyền text trực tiếp
  final String? valueKey; // hoặc dùng key để .tr
  const _KpiTile({
    required this.color,
    required this.icon,
    required this.titleKey,
    this.valueText,
    this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color;
    final title = titleKey.tr;
    final value = valueText ?? valueKey?.tr ?? '';

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
  final levels = const [
    (
      icon: LucideIcons.sparkles,
      titleKey: 'badges_tier_potential_title',
      descKey: 'badges_tier_potential_desc',
    ),
    (
      icon: LucideIcons.badge,
      titleKey: 'badges_tier_bronze_title',
      descKey: 'badges_tier_bronze_desc',
    ),
    (
      icon: LucideIcons.badgeHelp,
      titleKey: 'badges_tier_silver_title',
      descKey: 'badges_tier_silver_desc',
    ),
  ];

  const _MemberLevelsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemBuilder: (_, i) {
        final item = levels[i];
        return _LevelCard(
          icon: item.icon,
          title: item.titleKey.tr,
          description: item.descKey.tr,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: levels.length,
    );
  }
}

class _LevelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _LevelCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: context.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: context.subTitleOneStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: context.bodyTwoStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
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
  // Dữ liệu mẫu cho lịch sử điểm
  final items = const [
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
    ('badges_hist_login_7days', '+10', '12/6/2025'),
  ];

  const _PointsHistoryTab();

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: context.borderLineColor);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemBuilder: (_, i) {
        final (titleKey, points, date) = items[i];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(border),
          ),
          child: ListTile(
            title: Text(titleKey.tr, style: context.subTitleTwoStyle),
            subtitle: Text(
              points,
              style: context.bodyTwoStyle.copyWith(color: context.successColor),
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
      itemCount: items.length,
    );
  }
}
