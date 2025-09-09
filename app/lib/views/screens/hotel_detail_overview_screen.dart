import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class HotelDetailOverviewScreen extends StatefulWidget {
  final Map<String, String> hotel;
  // Tập tiện nghi đang được chọn ở màn overview (để highlight) – có thể null.
  final Set<String>? activeAmenities;

  const HotelDetailOverviewScreen({
    super.key,
    required this.hotel,
    this.activeAmenities,
  });

  @override
  State<HotelDetailOverviewScreen> createState() =>
      _HotelDetailOverviewScreenState();
}

class _HotelDetailOverviewScreenState extends State<HotelDetailOverviewScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;

  // Danh mục tiện nghi (khớp tên với bộ lọc ở HotelOverviewSearchScreen)
  late final List<_Amenity> _propertyAmenities = [
    _Amenity('Wifi miễn phí', LucideIcons.wifi),
    _Amenity('Bể bơi', LucideIcons.umbrella), // tạm dùng umbrella
    _Amenity('Spa', LucideIcons.leaf),
    _Amenity('Gym', LucideIcons.dumbbell),
    _Amenity('Nhà hàng', LucideIcons.chefHat),
    _Amenity('Bar', LucideIcons.wine),
    _Amenity('Đỗ xe miễn phí', LucideIcons.parkingCircle),
    _Amenity('Room service', LucideIcons.conciergeBell),
  ];

  late final List<_Amenity> _serviceAmenities = [
    _Amenity('Đưa đón sân bay', LucideIcons.plane),
    _Amenity('Lễ tân 24/7', LucideIcons.clock),
    _Amenity('Máy giặt/giặt ủi', LucideIcons.sparkles),
    _Amenity('Phòng gia đình', LucideIcons.users),
    _Amenity('Thân thiện thú cưng', LucideIcons.doorOpen),
    _Amenity('Không hút thuốc', LucideIcons.ban),
    _Amenity('Tiếp cận xe lăn', LucideIcons.accessibility),
  ];

  late final List<_Amenity> _roomAmenities = [
    _Amenity('Điều hòa', LucideIcons.snowflake),
    _Amenity('Ban công riêng', LucideIcons.doorOpen),
    _Amenity('Tủ lạnh nhỏ', LucideIcons.doorOpen),
    _Amenity('Két an toàn', LucideIcons.shield),
    _Amenity('TV màn hình phẳng', LucideIcons.tv),
    _Amenity('Ấm đun nước', LucideIcons.coffee),
    _Amenity('Máy sấy tóc', LucideIcons.wind),
    _Amenity('Bồn tắm', LucideIcons.bath),
  ];

  // Chính sách & tuỳ chọn (demo – có thể mở rộng từ filter)
  final List<String> _policies = [
    'Miễn phí huỷ (tùy loại phòng)',
    'Thanh toán tại nơi (một số ưu đãi)',
    'Bao gồm bữa sáng',
    'Có phòng còn trống',
  ];

  final List<String> _roomTypes = [
    'Ngắm cảnh biển',
    'Phòng cô dâu',
    'Phòng cho gia đình',
    'Có phòng hút thuốc',
  ];

  final List<Map<String, dynamic>> _reviews = List.generate(3, (i) {
    return {
      'user': 'Nguyễn Thành Công',
      'avatar': 'assets/images/onboarding${(i % 4) + 1}.png',
      'rating': 4.0,
      'date': '12/6/2025',
      'content':
          'InterContinental Nha Trang By IHG là một lựa chọn tuyệt vời cho kỳ nghỉ dưỡng sang trọng bên bờ biển. Vị trí đắc địa trên đường Trần Phú giúp du khách dễ dàng tiếp cận bãi biển và các điểm tham quan...',
      'reply':
          'We believe our role is to make as many of our guests as happy as possible, and by reading your comments posted from your recent stay with us, it seems that we did just that. Thank you for ...',
    };
  });

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;
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
          _heroImage(h['image']),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _headerInfo(context, h),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _quickMeta(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _priceAndAction(context, h),
          ),
          const SizedBox(height: 20),
          _sectionWrapper(
            context,
            title: 'Giới thiệu',
            child: _expandableText(
              context,
              text:
                  'Hãy tự hỏi tại sao khách du lịch đã lựa chọn InterContinental Nha Trang khi đến thăm Nha Trang. Khách sạn là sự tổng hợp của phong cách, dịch vụ và vị trí tuyệt vời ngay tại bờ biển... Phòng nghỉ hiện đại, tiện nghi đẳng cấp và tầm nhìn biển ngoạn mục giúp kỳ nghỉ của bạn trở nên đáng nhớ.',
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),
          // ===== TIỆN NGHI (chi tiết) =====
          _amenitiesBlock(
            context,
            title: 'Tiện nghi nổi bật',
            amenities: _propertyAmenities,
            initiallyVisible: 6,
          ),
          _amenitiesBlock(
            context,
            title: 'Dịch vụ & tiện ích bổ sung',
            amenities: _serviceAmenities,
            initiallyVisible: 5,
          ),
          _amenitiesBlock(
            context,
            title: 'Tiện nghi trong phòng',
            amenities: _roomAmenities,
            initiallyVisible: 6,
          ),
          _sectionWrapper(
            context,
            title: 'Chính sách & tuỳ chọn',
            child: _bulletList(context, _policies),
          ),
          _sectionWrapper(
            context,
            title: 'Loại phòng',
            child: _bulletList(context, _roomTypes),
          ),
          _sectionWrapper(
            context,
            title: 'Khu vực',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    '32-34 Tran Phu Street, Nha Trang 300200 Việt Nam',
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
          _sectionWrapper(
            context,
            title: 'Thông tin khách du lịch',
            child: _ratingSummary(context),
          ),
          _sectionWrapper(
            context,
            title: 'Tất cả đánh giá',
            child: Column(
              children: [
                ..._reviews.map((r) => _reviewItem(context, r)),
                const SizedBox(height: 8),
                if (!_showAllReviews)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _showAllReviews = true),
                      child: Text(
                        'Xem tất cả đánh giá',
                        style: context.captionStyle.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ===== HERO IMAGE =====
  Widget _heroImage(String? path) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            path ?? 'assets/images/onboarding1.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.image, size: 48, color: Colors.white70),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.image, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  const Text(
                    '1 / 12',
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
      ),
    );
  }

  // ===== HEADER =====
  Widget _headerInfo(BuildContext context, Map<String, String> h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          h['name'] ?? '',
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, 4.0),
            const SizedBox(width: 6),
            Text(
              '(99.999)',
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
            _inlineAction(context, 'Gọi'),
            _inlineAction(context, 'Viết đánh giá'),
            _inlineAction(context, 'Email'),
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
            label: '11 thg 6 → 12',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.bedSingle,
            label: '1  2',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, String> h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          h['price'] ?? '—',
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23A455),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              'Đặt khách sạn',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ===== GENERIC SECTION WRAPPER =====
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

  // ===== AMENITIES BLOCK (tolerant with List<String> or List<_Amenity>) =====
  Widget _amenitiesBlock(
    BuildContext context, {
    required String title,
    required List amenities, // chấp nhận dynamic list
    int initiallyVisible = 6,
  }) {
    final List<_Amenity> amenityObjs = _coerceAmenities(amenities);
    final active = widget.activeAmenities ?? const <String>{};
    final showAllKey = '_showAll_$title';
    final showingAll = _expandedState[showAllKey] ?? false;
    final visibleList = showingAll
        ? amenityObjs
        : amenityObjs
              .take(initiallyVisible.clamp(0, amenityObjs.length))
              .toList();

    return _sectionWrapper(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleList.map((a) {
              final highlighted = active.contains(a.name);
              return _amenityChip(context, a, highlighted);
            }).toList(),
          ),
          if (amenityObjs.length > initiallyVisible)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _expandedState[showAllKey] = !showingAll;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  showingAll ? 'Thu gọn' : 'Hiển thị thêm',
                  style: context.captionStyle.copyWith(
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

  List<_Amenity> _coerceAmenities(List raw) {
    return raw.map<_Amenity>((e) {
      if (e is _Amenity) return e;
      // Nếu chỉ là String -> gán icon mặc định
      return _Amenity(e.toString(), LucideIcons.check);
    }).toList();
  }

  final Map<String, bool> _expandedState = {};

  Widget _amenityChip(BuildContext context, _Amenity a, bool highlighted) {
    final bg = highlighted ? context.primaryColor : context.cardBackgroundColor;
    final fg = highlighted
        ? context.buttonTextColor
        : context.textSecondaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? context.primaryColor : context.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(a.icon, size: 16, color: fg),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              a.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== INTRO EXPANDABLE =====
  Widget _expandableText(
    BuildContext context, {
    required String text,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    final maxLines = expanded ? null : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: context.bodyTwoStyle.copyWith(
            height: 1.35,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onToggle,
          child: Text(
            expanded ? 'Thu gọn' : 'Đọc thêm',
            style: context.captionStyle.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ===== GENERIC LIST (POLICIES / ROOM TYPES) =====
  Widget _bulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $e',
                style: context.bodyTwoStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ===== RATING SUMMARY =====
  Widget _ratingSummary(BuildContext context) {
    final rows = [
      {'label': 'Xuất sắc', 'value': 0.9},
      {'label': 'Tốt', 'value': 0.8},
      {'label': 'Vừa', 'value': 0.7},
      {'label': 'Kém', 'value': 0.6},
      {'label': 'Rất tệ', 'value': 0.5},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  '4,0',
                  style: context.h5Style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Tốt',
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _starsRow(context, 4.0),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: rows
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
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
                              '99.999',
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
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: () {},
            icon: const Icon(LucideIcons.pencil),
            label: Text(
              'Viết đánh giá',
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ===== REVIEW ITEM =====
  Widget _reviewItem(BuildContext context, Map<String, dynamic> r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(r['avatar'] as String),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r['user'] as String,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                r['date'] as String,
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _starsRow(context, r['rating'] as double),
          const SizedBox(height: 6),
          Text(
            r['content'] as String,
            style: context.bodyTwoStyle.copyWith(height: 1.35),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {},
            child: Text(
              'Hiển thị thêm thêm',
              style: context.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ownerReply(context, r['reply'] as String),
        ],
      ),
    );
  }

  // ===== OWNER REPLY =====
  Widget _ownerReply(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
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
                  'IC Nha Trang',
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
          const SizedBox(height: 4),
          InkWell(
            onTap: () {},
            child: Text(
              'Hiển thị thêm thêm',
              style: context.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
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
        final filled = i < rating.round();
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            LucideIcons.star,
            size: 14,
            color: filled ? const Color(0xFF23A455) : context.dividerColor,
          ),
        );
      }),
    );
  }

  // ===== INLINE LINK =====
  Widget _inlineAction(BuildContext context, String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: context.captionStyle.copyWith(
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: context.textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MODEL =====
class _Amenity {
  final String name;
  final IconData icon;
  const _Amenity(this.name, this.icon);
}
