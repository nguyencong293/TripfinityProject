import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class TourServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tour;
  // Tập các tùy chọn đang được chọn ở màn overview (để highlight) – có thể null.
  final Set<String>? activeTourTypes;
  final Set<String>? activeServices;
  final String? activeDifficulty;

  const TourServiceDetailScreen({
    super.key,
    required this.tour,
    this.activeTourTypes,
    this.activeServices,
    this.activeDifficulty,
  });

  @override
  State<TourServiceDetailScreen> createState() =>
      _TourServiceDetailScreenState();
}

class _TourServiceDetailScreenState extends State<TourServiceDetailScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;
  bool _showAllItinerary = false;

  // Lịch trình tour (mock data)
  final List<Map<String, dynamic>> _itinerary = [
    {
      'day': 1,
      'title': 'Khởi hành - Tham quan thành phố',
      'activities': [
        'Đón khách tại khách sạn (7:00 - 8:00)',
        'Tham quan Tháp Bà Ponagar',
        'Khám phá chợ Đầm Nha Trang',
        'Ăn trưa tại nhà hàng địa phương',
        'Thời gian tự do tại bãi biển',
      ],
      'meals': 'Trưa, Tối',
      'accommodation': 'Khách sạn 4 sao',
    },
    {
      'day': 2,
      'title': 'Tour 4 đảo - Khám phá biển',
      'activities': [
        'Khởi hành đi tour 4 đảo (8:30)',
        'Tham quan Hòn Mun - lặn ngắm san hô',
        'Hòn Tằm - tắm biển và nghỉ ngơi',
        'Bãi Tranh - thưởng thức hải sản',
        'Hòn Miễu - tham quan làng chài',
      ],
      'meals': 'Sáng, Trưa, Tối',
      'accommodation': 'Khách sạn 4 sao',
    },
    {
      'day': 3,
      'title': 'Tham quan VinWonders - Trở về',
      'activities': [
        'Ăn sáng tại khách sạn',
        'Đi VinWonders Nha Trang',
        'Trải nghiệm các trò chơi',
        'Mua sắm tại VinCom Plaza',
        'Tiễn khách ra sân bay/ga tàu',
      ],
      'meals': 'Sáng, Trưa',
      'accommodation': null,
    },
  ];

  // Dịch vụ bao gồm
  final List<_ServiceItem> _includedServices = [
    _ServiceItem(
      'Vận chuyển',
      'Xe du lịch điều hòa theo chương trình',
      LucideIcons.bus,
    ),
    _ServiceItem(
      'Hướng dẫn viên',
      'HDV tiếng Việt nhiệt tình, kinh nghiệm',
      LucideIcons.userCheck,
    ),
    _ServiceItem(
      'Bữa ăn',
      'Theo chương trình (3 bữa sáng, 3 bữa trưa, 2 bữa tối)',
      LucideIcons.utensils,
    ),
    _ServiceItem(
      'Khách sạn',
      '2 đêm khách sạn 4 sao (phòng đôi)',
      LucideIcons.bed,
    ),
    _ServiceItem(
      'Vé tham quan',
      'Vé các điểm tham quan trong chương trình',
      LucideIcons.ticket,
    ),
    _ServiceItem(
      'Bảo hiểm',
      'Bảo hiểm du lịch theo quy định',
      LucideIcons.shieldCheck,
    ),
  ];

  // Dịch vụ không bao gồm
  final List<_ServiceItem> _excludedServices = [
    _ServiceItem(
      'Chi phí cá nhân',
      'Giặt ủi, điện thoại, đồ uống...',
      LucideIcons.wallet,
    ),
    _ServiceItem(
      'Hành lý quá cước',
      'Phí hành lý vượt quá quy định hàng không',
      LucideIcons.luggage,
    ),
    _ServiceItem(
      'Tip HDV',
      'Tip cho hướng dẫn viên và tài xế',
      LucideIcons.dollarSign,
    ),
    _ServiceItem(
      'VAT',
      'Thuế VAT (8% nếu xuất hóa đơn đỏ)',
      LucideIcons.receipt,
    ),
  ];

  // Chính sách tour
  final List<String> _policies = [
    'Miễn phí hủy tour trước 7 ngày (trừ vé máy bay)',
    'Hủy trước 3-6 ngày: thu 50% tổng tiền tour',
    'Hủy trong 3 ngày: thu 100% tiền tour',
    'Trẻ em dưới 2 tuổi: Miễn phí (không gồm ghế ngồi)',
    'Trẻ em 2-11 tuổi: 75% giá tour người lớn',
    'Trẻ em từ 12 tuổi: 100% giá tour người lớn',
  ];

  // Loại tour và dịch vụ (từ bộ lọc)
  final List<_TagOption> _tourTypes = const [
    _TagOption('City tour', LucideIcons.building2),
    _TagOption('Thiên nhiên', LucideIcons.treePine),
    _TagOption('Văn hoá', LucideIcons.landmark),
    _TagOption('Ẩm thực', LucideIcons.utensils),
    _TagOption('Mạo hiểm', LucideIcons.mountain),
    _TagOption('Đảo/biển', LucideIcons.umbrella),
    _TagOption('Du thuyền', LucideIcons.ship),
    _TagOption('Lịch sử', LucideIcons.bookOpen),
  ];

  final List<_TagOption> _serviceOptions = const [
    _TagOption('Đón khách sạn', LucideIcons.mapPin),
    _TagOption('Nhóm nhỏ', LucideIcons.users),
    _TagOption('Riêng tư', LucideIcons.lock),
    _TagOption('Hướng dẫn EN', LucideIcons.messageSquare),
    _TagOption('Hướng dẫn VI', LucideIcons.messageSquare),
    _TagOption('Bao gồm bữa ăn', LucideIcons.pizza),
    _TagOption('Bảo hiểm', LucideIcons.shieldCheck),
  ];

  // Reviews mock data
  final List<Map<String, dynamic>> _reviews = List.generate(3, (i) {
    return {
      'user': ['Nguyễn Văn A', 'Trần Thị B', 'Lê Minh C'][i],
      'avatar': 'assets/images/onboarding${(i % 4) + 1}.png',
      'rating': [4.5, 4.2, 4.8][i],
      'date': ['15/8/2024', '10/8/2024', '5/8/2024'][i],
      'content': [
        'Tour rất tuyệt vời! Hướng dẫn viên nhiệt tình, lịch trình hợp lý. Đặc biệt là tour 4 đảo rất đẹp, nước biển trong xanh. Sẽ giới thiệu bạn bè.',
        'Chuyến đi ổn, khách sạn sạch sẽ, đồ ăn ngon. Chỉ có điều thời gian hơi gấp một chút. Nhìn chung hài lòng với dịch vụ.',
        'Tuyệt vời! Tour được tổ chức chuyên nghiệp, HDV am hiểu và vui tính. VinWonders rất đáng để trải nghiệm. Giá cả hợp lý.',
      ][i],
      'reply': i == 0
          ? 'Cảm ơn anh/chị đã lựa chọn dịch vụ của chúng tôi. Chúng tôi rất vui khi tour đã mang lại trải nghiệm tuyệt vời cho anh/chị và gia đình...'
          : null,
    };
  });

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;
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
          _heroImage(tour['image']),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _headerInfo(context, tour),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _quickMeta(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _priceAndAction(context, tour),
          ),
          const SizedBox(height: 20),
          _sectionWrapper(
            context,
            title: 'Giới thiệu tour',
            child: _expandableText(
              context,
              text:
                  'Khám phá vẻ đẹp tuyệt vời của Nha Trang với tour 3 ngày 2 đêm đầy thú vị. Từ những di tích lịch sử cổ kính đến những bãi biển xanh ngọc bích, từ ẩm thực địa phương đặc sắc đến những hoạt động giải trí hiện đại tại VinWonders. Chuyến đi này sẽ mang đến cho bạn những trải nghiệm khó quên về vùng đất biển miền Trung.',
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),
          // ===== LOẠI TOUR & DỊCH VỤ =====
          _tourTypeBlock(
            context,
            title: 'Loại tour',
            options: _tourTypes,
            selected: widget.activeTourTypes ?? {},
          ),
          _tourTypeBlock(
            context,
            title: 'Dịch vụ bao gồm',
            options: _serviceOptions,
            selected: widget.activeServices ?? {},
          ),
          // ===== LỊCH TRÌNH =====
          _sectionWrapper(
            context,
            title: 'Lịch trình chi tiết',
            child: _itinerarySection(context),
          ),
          // ===== DỊCH VỤ BAO GỒM/KHÔNG BAO GỒM =====
          _serviceBlock(
            context,
            title: 'Dịch vụ bao gồm',
            services: _includedServices,
            isIncluded: true,
          ),
          _serviceBlock(
            context,
            title: 'Dịch vụ không bao gồm',
            services: _excludedServices,
            isIncluded: false,
          ),
          _sectionWrapper(
            context,
            title: 'Chính sách tour',
            child: _bulletList(context, _policies),
          ),
          _sectionWrapper(
            context,
            title:
                'Độ khó: ${widget.activeDifficulty ?? tour['difficulty'] ?? 'Dễ'}',
            child: _difficultyInfo(
              context,
              widget.activeDifficulty ?? tour['difficulty'] ?? 'Dễ',
            ),
          ),
          _sectionWrapper(
            context,
            title: 'Điểm khởi hành',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    'Nha Trang Center, 18-20 Biet Thu Street, Nha Trang',
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
            title: 'Thông tin đánh giá',
            child: _ratingSummary(context),
          ),
          _sectionWrapper(
            context,
            title: 'Tất cả đánh giá',
            child: Column(
              children: [
                ...(_showAllReviews ? _reviews : _reviews.take(2)).map(
                  (r) => _reviewItem(context, r),
                ),
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
                    '1 / 15',
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
  Widget _headerInfo(BuildContext context, Map<String, dynamic> tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tour['name'] ?? '',
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, double.tryParse(tour['rating'] ?? '4.0') ?? 4.0),
            const SizedBox(width: 6),
            Text(
              tour['reviews'] ?? '(999)',
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
            _inlineAction(context, 'Xem thêm ảnh'),
            _inlineAction(context, 'Liên hệ'),
            _inlineAction(context, 'Viết đánh giá'),
            _inlineAction(context, 'Chia sẻ'),
          ],
        ),
      ],
    );
  }

  // ===== QUICK META (DATE / GUESTS) =====
  Widget _quickMeta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: '11 thg 6 → 15',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.users,
            label: '2 khách',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, dynamic> tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tour['price'] ?? '—',
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
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              'Đặt tour ngay',
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
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: context.bodyTwoStyle.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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

  // ===== LỊCH TRÌNH =====
  Widget _itinerarySection(BuildContext context) {
    final visibleItems = _showAllItinerary
        ? _itinerary
        : _itinerary.take(2).toList();

    return Column(
      children: [
        ...visibleItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _itineraryItem(
            context,
            item,
            index == visibleItems.length - 1,
          );
        }),
        if (!_showAllItinerary && _itinerary.length > 2)
          TextButton(
            onPressed: () => setState(() => _showAllItinerary = true),
            child: Text(
              'Xem lịch trình đầy đủ',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _itineraryItem(
    BuildContext context,
    Map<String, dynamic> item,
    bool isLast,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item['day']}',
                    style: context.captionStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: context.dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày ${item['day']}: ${item['title']}',
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...item['activities'].map<Widget>(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $activity',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (item['meals'] != null)
                  _itineraryDetail(
                    context,
                    LucideIcons.utensils,
                    'Bữa ăn: ${item['meals']}',
                  ),
                if (item['accommodation'] != null)
                  _itineraryDetail(
                    context,
                    LucideIcons.bed,
                    'Lưu trú: ${item['accommodation']}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itineraryDetail(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TOUR TYPE BLOCK =====
  Widget _tourTypeBlock(
    BuildContext context, {
    required String title,
    required List<_TagOption> options,
    required Set<String> selected,
  }) {
    final relevantOptions = options
        .where(
          (o) => title.contains('Loại tour')
              ? (widget.tour['type'] == o.label || selected.contains(o.label))
              : selected.contains(o.label),
        )
        .toList();

    if (relevantOptions.isEmpty) return const SizedBox.shrink();

    return _sectionWrapper(
      context,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: relevantOptions.map((option) {
          final isSelected =
              selected.contains(option.label) ||
              (title.contains('Loại tour') &&
                  widget.tour['type'] == option.label);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primaryColor.withValues(alpha: .12)
                  : context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? context.primaryColor : context.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: 16,
                  color: isSelected
                      ? context.primaryColor
                      : context.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  option.label,
                  style: context.captionStyle.copyWith(
                    color: isSelected
                        ? context.primaryColor
                        : context.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== SERVICE BLOCK =====
  Widget _serviceBlock(
    BuildContext context, {
    required String title,
    required List<_ServiceItem> services,
    required bool isIncluded,
  }) {
    return _sectionWrapper(
      context,
      title: title,
      child: Column(
        children: services
            .map((service) => _serviceItem(context, service, isIncluded))
            .toList(),
      ),
    );
  }

  Widget _serviceItem(
    BuildContext context,
    _ServiceItem service,
    bool isIncluded,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isIncluded
                  ? context.primaryColor.withValues(alpha: .12)
                  : Colors.red.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncluded ? LucideIcons.check : LucideIcons.x,
              size: 14,
              color: isIncluded ? context.primaryColor : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Icon(service.icon, size: 18, color: context.textSecondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service.description,
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== DIFFICULTY INFO =====
  Widget _difficultyInfo(BuildContext context, String difficulty) {
    final info = {
      'Dễ': {
        'icon': LucideIcons.smile,
        'color': Colors.green,
        'description':
            'Phù hợp với mọi lứa tuổi, không yêu cầu thể lực đặc biệt',
      },
      'Vừa': {
        'icon': LucideIcons.meh,
        'color': Colors.orange,
        'description':
            'Cần thể lực trung bình, có thể đi bộ trong thời gian dài',
      },
      'Khó': {
        'icon': LucideIcons.frown,
        'color': Colors.red,
        'description': 'Yêu cầu thể lực tốt, có hoạt động mạo hiểm',
      },
    };

    final current = info[difficulty] ?? info['Dễ']!;

    return Row(
      children: [
        Icon(
          current['icon'] as IconData,
          color: current['color'] as Color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            current['description'] as String,
            style: context.bodyTwoStyle.copyWith(
              color: context.textSecondaryColor,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // ===== GENERIC LIST (POLICIES) =====
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
      {'label': 'Xuất sắc', 'value': 0.8},
      {'label': 'Tốt', 'value': 0.9},
      {'label': 'Trung bình', 'value': 0.1},
      {'label': 'Kém', 'value': 0.0},
      {'label': 'Tệ', 'value': 0.0},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: .3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '4.6',
                    style: context.subTitleOneStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  _starsRow(context, 4.6),
                  const SizedBox(height: 4),
                  Text(
                    '1.234 đánh giá',
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: rows
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
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
                                    valueColor: AlwaysStoppedAnimation(
                                      context.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${((r['value'] as double) * 1234).round()}',
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
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: context.dividerColor),
              ),
              icon: Icon(
                LucideIcons.messageSquare,
                size: 18,
                color: context.textPrimaryColor,
              ),
              label: Text(
                'Viết đánh giá',
                style: context.bodyTwoStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ===== REVIEW ITEM =====
  Widget _reviewItem(BuildContext context, Map<String, dynamic> review) {
    final text = review['content'] as String;
    final replyText = review['reply'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
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
            text,
            style: context.bodyTwoStyle.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (replyText != null) ...[
            const SizedBox(height: 12),
            _replySection(context, replyText),
          ],
        ],
      ),
    );
  }

  Widget _replySection(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.primaryColor, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.award, size: 16, color: context.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tripfinity Travel',
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '13/8/2024',
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

  // ===== HELPERS =====
  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= (i + 1) - 0.25;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: context.primaryColor,
          size: 16,
        );
      }),
    );
  }

  Widget _inlineAction(BuildContext context, String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: context.captionStyle.copyWith(
          color: context.primaryColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _outlinedChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.textSecondaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: context.bodyTwoStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagOption {
  final String label;
  final IconData icon;
  const _TagOption(this.label, this.icon);
}

class _ServiceItem {
  final String title;
  final String description;
  final IconData icon;
  const _ServiceItem(this.title, this.description, this.icon);
}
