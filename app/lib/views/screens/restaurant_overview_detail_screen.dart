import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, String> restaurant;
  // Các filter đang được chọn từ overview để highlight
  final Set<String> activeCuisines;
  final Set<String> activeServices;
  final Set<String> activeDietaries;
  final Set<int> activeStars;
  final bool activeOpenNow;
  final bool activeReservation;
  final bool activeTakeAway;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    this.activeCuisines = const {},
    this.activeServices = const {},
    this.activeDietaries = const {},
    this.activeStars = const {},
    this.activeOpenNow = false,
    this.activeReservation = false,
    this.activeTakeAway = false,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;
  final Map<String, bool> _expandedState = {};

  // ===== DANH MỤC ĐẶC ĐIỂM NHÀ HÀNG =====
  late final List<_RestaurantFeature> _cuisineFeatures = [
    _RestaurantFeature('Việt', LucideIcons.wine),
    _RestaurantFeature('Hải sản', LucideIcons.fish),
    _RestaurantFeature('Âu', LucideIcons.wine),
    _RestaurantFeature('Hàn', LucideIcons.wine),
    _RestaurantFeature('Nhật', LucideIcons.wine),
    _RestaurantFeature('Thái', LucideIcons.eggFried),
    _RestaurantFeature('Trung', LucideIcons.wine),
    _RestaurantFeature('Chay', LucideIcons.leaf),
    _RestaurantFeature('Nướng', LucideIcons.flame),
    _RestaurantFeature('Cà phê', LucideIcons.coffee),
  ];

  late final List<_RestaurantFeature> _serviceFeatures = [
    _RestaurantFeature('Ăn tại chỗ', LucideIcons.utensils),
    _RestaurantFeature('Mang đi', LucideIcons.shoppingBag),
    _RestaurantFeature('Giao hàng', LucideIcons.bike),
    _RestaurantFeature('Bar', LucideIcons.beer),
    _RestaurantFeature('Sân vườn', LucideIcons.treePine),
    _RestaurantFeature('Phòng riêng', LucideIcons.doorClosed),
  ];

  late final List<_RestaurantFeature> _dietaryFeatures = [
    _RestaurantFeature('Vegan', LucideIcons.leaf),
    _RestaurantFeature('Halal', LucideIcons.badgeCheck),
    _RestaurantFeature('Gluten-free', LucideIcons.wheatOff),
    _RestaurantFeature('Ít calo', LucideIcons.scale),
    _RestaurantFeature('Không sữa', LucideIcons.milkOff),
  ];

  // ===== GIỜ MỞ CỬA =====
  final List<Map<String, String>> _openingHours = [
    {'day': 'Thứ 2', 'hours': '09:00 - 22:00'},
    {'day': 'Thứ 3', 'hours': '09:00 - 22:00'},
    {'day': 'Thứ 4', 'hours': '09:00 - 22:00'},
    {'day': 'Thứ 5', 'hours': '09:00 - 22:00'},
    {'day': 'Thứ 6', 'hours': '09:00 - 23:00'},
    {'day': 'Thứ 7', 'hours': '08:00 - 23:00'},
    {'day': 'Chủ nhật', 'hours': '08:00 - 22:00'},
  ];

  // ===== ĐÁNH GIÁ =====
  final List<Map<String, dynamic>> _reviews = List.generate(4, (i) {
    return {
      'user': [
        'Nguyễn Thành Công',
        'Trần Thị Mai',
        'Lê Văn Nam',
        'Hoàng Thị Lan',
      ][i],
      'avatar': 'assets/images/onboarding${(i % 4) + 1}.png',
      'rating': [4.5, 5.0, 4.0, 4.8][i],
      'date': ['12/6/2025', '10/6/2025', '08/6/2025', '05/6/2025'][i],
      'content': [
        'Nhà hàng có không gian rất đẹp, món ăn ngon và phục vụ chu đáo. Đặc biệt là món hải sản tươi sống rất tuyệt. Giá cả hợp lý.',
        'Thức ăn ngon, không gian thoáng mát. Nhân viên phục vụ nhiệt tình. Sẽ quay lại lần sau khi có dịp.',
        'Món ăn đa dạng, vị trí thuận lợi. Chỉ có điều hơi ồn vào giờ cao điểm. Nhìn chung vẫn ok.',
        'Nhà hàng sạch sẽ, thức ăn tươi ngon. Đặc biệt có nhiều món chay đa dạng. Rất hài lòng với dịch vụ.',
      ][i],
      'reply': i == 0
          ? 'Cảm ơn bạn đã đánh giá. Chúng tôi rất vui khi bạn hài lòng với dịch vụ và sẽ tiếp tục cải thiện để phục vụ bạn tốt hơn.'
          : null,
    };
  });

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.share2, color: context.textPrimaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.heart, color: context.textPrimaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _heroImage(r['image']),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _headerInfo(context, r),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _quickMeta(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _priceAndAction(context, r),
          ),
          const SizedBox(height: 20),

          // ===== GIỚI THIỆU =====
          _sectionWrapper(
            context,
            title: 'Giới thiệu',
            child: _expandableText(
              context,
              text:
                  'Nhà hàng ${r['name']} là điểm đến lý tưởng cho những ai yêu thích ẩm thực ${r['cuisine']?.toLowerCase()}. Với không gian ấm cúng, thực đơn đa dạng và đội ngũ phục vụ chuyên nghiệp, chúng tôi cam kết mang đến cho quý khách những trải nghiệm ẩm thực tuyệt vời nhất. Nhà hàng sử dụng nguyên liệu tươi ngon, chế biến theo công thức truyền thống kết hợp với sự sáng tạo hiện đại.',
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),

          // ===== CÁC KHỐI TÍNH NĂNG =====
          _featuresBlock(
            context,
            title: 'Ẩm thực',
            features: _cuisineFeatures,
            activeFeatures: widget.activeCuisines,
            initiallyVisible: 6,
          ),

          _featuresBlock(
            context,
            title: 'Dịch vụ',
            features: _serviceFeatures,
            activeFeatures: widget.activeServices,
            initiallyVisible: 4,
          ),

          _featuresBlock(
            context,
            title: 'Chế độ ăn',
            features: _dietaryFeatures,
            activeFeatures: widget.activeDietaries,
            initiallyVisible: 3,
          ),

          // ===== GIỜ MỞ CỬA =====
          _sectionWrapper(
            context,
            title: 'Giờ mở cửa',
            child: Column(
              children: _openingHours.map((hour) {
                final isToday =
                    hour['day'] == 'Thứ 2'; // Demo: thứ 2 là hôm nay
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          hour['day']!,
                          style: context.bodyTwoStyle.copyWith(
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday
                                ? context.primaryColor
                                : context.textSecondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hour['hours']!,
                          style: context.bodyTwoStyle.copyWith(
                            fontWeight: isToday
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF23A455,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Đang mở',
                            style: context.captionStyle.copyWith(
                              color: const Color(0xFF23A455),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ===== KHU VỰC =====
          _sectionWrapper(
            context,
            title: 'Khu vực',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    '32-34 Trần Phú, Nha Trang 300200 Việt Nam',
                    style: context.bodyTwoStyle.copyWith(
                      color: context.primaryColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/onboarding2.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          // ===== THÔNG TIN KHÁCH HÀNG =====
          _sectionWrapper(
            context,
            title: 'Thông tin khách hàng',
            child: _ratingSummary(context),
          ),

          // ===== TẤT CẢ ĐÁNH GIÁ =====
          _sectionWrapper(
            context,
            title: 'Tất cả đánh giá',
            child: Column(
              children: [
                ...(_showAllReviews ? _reviews : _reviews.take(2)).map(
                  (review) => _reviewCard(context, review),
                ),
                if (_reviews.length > 2)
                  TextButton(
                    onPressed: () =>
                        setState(() => _showAllReviews = !_showAllReviews),
                    child: Text(
                      _showAllReviews
                          ? 'Thu gọn'
                          : 'Xem thêm ${_reviews.length - 2} đánh giá',
                      style: context.bodyTwoStyle.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===== HERO IMAGE =====
  Widget _heroImage(String? imagePath) {
    return Stack(
      children: [
        Image.asset(
          imagePath ?? 'assets/images/onboarding1.png',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 220,
            color: context.primaryColor.withValues(alpha: 0.15),
            child: const Icon(Icons.image, size: 48, color: Colors.white70),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.image, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                const Text(
                  '1 / 8',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== HEADER INFO =====
  Widget _headerInfo(BuildContext context, Map<String, String> r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r['name'] ?? '',
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, double.tryParse(r['rating'] ?? '4.0') ?? 4.0),
            const SizedBox(width: 6),
            Text(
              r['reviews'] ?? '(99.999)',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: [
            _inlineAction(context, 'Truy cập trang web'),
            _inlineAction(context, 'Gọi đặt bàn'),
            _inlineAction(context, 'Viết đánh giá'),
            _inlineAction(context, 'Chỉ đường'),
          ],
        ),
      ],
    );
  }

  // ===== QUICK META (DATE / GUEST) =====
  Widget _quickMeta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: '11 thg 6',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.users,
            label: '2 người',
          ),
        ),
      ],
    );
  }

  // ===== PRICE AND ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, String> r) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giá từ:',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                r['price'] ?? '120.000 đ',
                style: context.subTitleTwoStyle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.buttonTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              'Đặt bàn',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ===== SECTION WRAPPER =====
  Widget _sectionWrapper(
    BuildContext context, {
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ===== EXPANDABLE TEXT =====
  Widget _expandableText(
    BuildContext context, {
    required String text,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: context.bodyTwoStyle.copyWith(height: 1.4),
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onToggle,
          child: Text(
            expanded ? 'Thu gọn' : 'Xem thêm',
            style: context.bodyTwoStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===== FEATURES BLOCK (tương tự amenities trong hotel) =====
  Widget _featuresBlock(
    BuildContext context, {
    required String title,
    required List<_RestaurantFeature> features,
    required Set<String> activeFeatures,
    int initiallyVisible = 6,
  }) {
    final showAllKey = '_showAll_$title';
    final showingAll = _expandedState[showAllKey] ?? false;
    final visibleList = showingAll
        ? features
        : features.take(initiallyVisible.clamp(0, features.length)).toList();

    return _sectionWrapper(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleList.map((feature) {
              final isActive = activeFeatures.contains(feature.name);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.primaryColor.withValues(alpha: 0.1)
                      : context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? context.primaryColor
                        : context.dividerColor,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      feature.icon,
                      size: 16,
                      color: isActive
                          ? context.primaryColor
                          : context.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      feature.name,
                      style: context.bodyTwoStyle.copyWith(
                        color: isActive
                            ? context.primaryColor
                            : context.textSecondaryColor,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (features.length > initiallyVisible)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InkWell(
                onTap: () =>
                    setState(() => _expandedState[showAllKey] = !showingAll),
                child: Text(
                  showingAll
                      ? 'Thu gọn'
                      : 'Xem thêm ${features.length - initiallyVisible}',
                  style: context.bodyTwoStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== RATING SUMMARY =====
  Widget _ratingSummary(BuildContext context) {
    final ratingData = [
      {'label': 'Chất lượng', 'value': 0.85},
      {'label': 'Phục vụ', 'value': 0.92},
      {'label': 'Giá cả', 'value': 0.78},
      {'label': 'Vị trí', 'value': 0.88},
      {'label': 'Không gian', 'value': 0.90},
    ];

    return Column(
      children: [
        Row(
          children: [
            Text(
              '4.3',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _starsRow(context, 4.3),
                  const SizedBox(height: 4),
                  Text(
                    'Dựa trên ${_reviews.length} đánh giá',
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: ratingData
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          r['label'] as String,
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: r['value'] as double,
                            backgroundColor: context.dividerColor,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF23A455),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ((r['value'] as double) * 5).toStringAsFixed(1),
                        style: context.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: context.dividerColor),
            ),
            onPressed: () {},
            icon: Icon(
              LucideIcons.messageSquare,
              size: 18,
              color: context.textPrimaryColor,
            ),
            label: Text(
              'Viết đánh giá',
              style: context.bodyTwoStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== REVIEW CARD =====
  Widget _reviewCard(BuildContext context, Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(review['avatar']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user'],
                      style: context.bodyTwoStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _starsRow(context, review['rating'].toDouble()),
                        const SizedBox(width: 8),
                        Text(
                          review['date'],
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
          const SizedBox(height: 12),
          Text(
            review['content'],
            style: context.bodyTwoStyle.copyWith(height: 1.4),
          ),
          if (review['reply'] != null) ...[
            const SizedBox(height: 12),
            _managerReply(context, review['reply']),
          ],
        ],
      ),
    );
  }

  // ===== MANAGER REPLY =====
  Widget _managerReply(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF23A455), width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.award, size: 16, color: Color(0xFFB8860B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Quản lý nhà hàng',
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '12/6/2025',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: context.captionStyle.copyWith(
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===== STARS ROW =====
  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            color: context.primaryColor,
            size: 16,
          );
        } else if (i < rating) {
          return Icon(
            Icons.star_half_rounded,
            color: context.primaryColor,
            size: 16,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            color: context.primaryColor,
            size: 16,
          );
        }
      }),
    );
  }

  // ===== INLINE ACTION =====
  Widget _inlineAction(BuildContext context, String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: context.bodyTwoStyle.copyWith(
          color: context.primaryColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ===== OUTLINED CHIP =====
  Widget _outlinedChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: context.textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ===== MODEL =====
class _RestaurantFeature {
  final String name;
  final IconData icon;
  const _RestaurantFeature(this.name, this.icon);
}
