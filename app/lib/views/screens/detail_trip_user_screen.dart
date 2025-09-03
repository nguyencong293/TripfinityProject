import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';

class DetailTripUserScreen extends StatelessWidget {
  final int initialTab;
  const DetailTripUserScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              automaticallyImplyLeading: false,
              backgroundColor: context.backgroundColor,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Main background image
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/onboarding1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay for better text readability
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.black54],
                        ),
                      ),
                    ),
                    // Top navigation buttons
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _ActionButton(
                            icon: LucideIcons.chevronLeft,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _ActionButton(icon: LucideIcons.share, onTap: () {}),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: LucideIcons.settings,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    // Title and date information
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'trip_badge'.tr,
                              style: context.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'da_nang_trip'.tr,
                            style: context.h2Style.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.calendar,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '12 thg 6 — 20 thg 6, 2025',
                                      style: context.captionStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: context.dividerColor.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TabBar(
                    isScrollable: false,
                    indicatorColor: context.primaryColor,
                    indicatorWeight: 3,
                    labelColor: context.primaryColor,
                    unselectedLabelColor: context.textSecondaryColor,
                    labelStyle: context.subTitleTwoStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: context.subTitleTwoStyle,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'saved_items'.tr),
                      Tab(text: 'itinerary'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [_SavedTab(), _ItineraryTab()],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: context.textPrimaryColor, size: 20),
          ),
        ),
      ),
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _SectionHeader(title: '${'hotels'.tr} (2)', icon: LucideIcons.building),
        const SizedBox(height: 16),
        const _SavedItemCard(
          image: 'assets/images/onboarding2.png',
          title: 'Cầu Vàng',
          subtitle: 'Khu du lịch nổi tiếng',
          rating: 4.0,
          reviews: 99999,
        ),
        const SizedBox(height: 16),
        const _SavedItemCard(
          image: 'assets/images/onboarding3.png',
          title: 'Sun World Bà Nà Hills',
          subtitle: 'Điểm check-in hot nhất',
          rating: 4.0,
          reviews: 99999,
        ),
        const SizedBox(height: 32),
        _SectionHeader(
          title: '${'restaurants'.tr} (3)',
          icon: LucideIcons.utensils,
        ),
        const SizedBox(height: 16),
        const _SavedItemCard(
          image: 'assets/images/onboarding1.png',
          title: 'Nhà hàng Waterfront',
          subtitle: 'Hải sản tươi ngon',
          rating: 4.5,
          reviews: 2847,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: context.primaryColor),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: context.h5Style.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: context.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            'see_all'.tr,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final String image;
  final String title;
  final String? subtitle;
  final double rating;
  final int reviews;

  const _SavedItemCard({
    required this.image,
    required this.title,
    this.subtitle,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.asset(image, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(top: 12, right: 12, child: _FavButton()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.subTitleOneStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: context.bodyTwoStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.star,
                                size: 14,
                                color: context.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: context.captionStyle.copyWith(
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_formatNumber(reviews)})',
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toString();
  }
}

class _FavButton extends StatefulWidget {
  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton> {
  bool isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => setState(() => isFavorite = !isFavorite),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              LucideIcons.heart,
              size: 16,
              color: isFavorite ? Colors.red : context.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _DayCard(
          title: 'Thứ Năm, 12 thg 6',
          items: const ['Cầu Vàng', 'Bà Nà Hills'],
          isExpanded: true,
        ),
        const SizedBox(height: 16),
        _DayCard(
          title: 'Thứ Sáu, 13 thg 6',
          items: const ['Chợ Hàn', 'Bãi biển Mỹ Khê'],
          isExpanded: false,
        ),
      ],
    );
  }
}

class _DayCard extends StatefulWidget {
  final String title;
  final List<String> items;
  final bool isExpanded;

  const _DayCard({
    required this.title,
    required this.items,
    this.isExpanded = false,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 20,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: context.dividerColor.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: widget.items.asMap().entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key == widget.items.length - 1 ? 0 : 16,
                        ),
                        child: _TimelineItem(
                          index: entry.key + 1,
                          title: entry.value,
                        ),
                      );
                    }).toList(),
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

class _TimelineItem extends StatelessWidget {
  final int index;
  final String title;

  const _TimelineItem({required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$index',
              style: context.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      'assets/images/onboarding2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.subTitleTwoStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.star,
                                  size: 12,
                                  color: context.primaryColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '4.0',
                                  style: context.captionStyle.copyWith(
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(99,999)',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
