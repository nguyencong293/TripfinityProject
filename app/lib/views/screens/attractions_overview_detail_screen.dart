import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class AttractionsOverviewDetailScreen extends StatefulWidget {
  final Map<String, dynamic> attraction;
  // Các filter đang được chọn để highlight
  final Set<String>? activeTypes;
  final Set<String>? activeServices;
  final Set<String>? activeTimes;
  final Set<String>? activeSuitability;

  const AttractionsOverviewDetailScreen({
    super.key,
    required this.attraction,
    this.activeTypes,
    this.activeServices,
    this.activeTimes,
    this.activeSuitability,
  });

  @override
  State<AttractionsOverviewDetailScreen> createState() =>
      _AttractionsOverviewDetailScreenState();
}

class _AttractionsOverviewDetailScreenState
    extends State<AttractionsOverviewDetailScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;
  bool _showAllGallery = false;

  // Thông tin chi tiết điểm tham quan
  final List<_HighlightInfo> _highlights = [
    _HighlightInfo(
      'Kiến trúc độc đáo',
      'Kiến trúc Chăm cổ từ thế kỷ 8-13',
      LucideIcons.building,
    ),
    _HighlightInfo(
      'Lịch sử văn hóa',
      'Tìm hiểu về nền văn minh Chăm Pa',
      LucideIcons.bookOpen,
    ),
    _HighlightInfo(
      'Tầm nhìn đẹp',
      'Ngắm toàn cảnh thành phố Nha Trang',
      LucideIcons.eye,
    ),
    _HighlightInfo(
      'Hoạt động tâm linh',
      'Cầu nguyện, dâng hương theo tập tục',
      LucideIcons.sparkles,
    ),
  ];

  final List<_TicketInfo> _ticketOptions = [
    _TicketInfo(
      title: 'Vé người lớn',
      price: 120000,
      description: 'Từ 12 tuổi trở lên',
      features: ['Tham quan tự do', 'Hướng dẫn cơ bản'],
    ),
    _TicketInfo(
      title: 'Vé trẻ em',
      price: 60000,
      description: '6-11 tuổi',
      features: ['Tham quan tự do', 'Hướng dẫn cơ bản'],
    ),
    _TicketInfo(
      title: 'Combo hướng dẫn viên',
      price: 200000,
      description: 'Người lớn + HDV riêng',
      features: [
        'Hướng dẫn viên chuyên nghiệp',
        'Giải thích chi tiết lịch sử',
        'Chụp ảnh miễn phí',
      ],
    ),
  ];

  final Map<String, dynamic> _practicalInfo = {
    'opening_hours': {
      'title': 'Giờ mở cửa',
      'content': [
        'Hàng ngày: 6:00 - 18:00',
        'Lễ tết: 5:30 - 19:00',
        'Thời gian tham quan đề xuất: 1-2 tiếng',
      ],
    },
    'location': {
      'title': 'Vị trí',
      'content': [
        'Địa chỉ: 2 Tháng 4, Vĩnh Hải, Nha Trang',
        'Cách trung tâm: 2km về phía Bắc',
        'Gần các điểm: Chợ Đầm, Bãi biển Nha Trang',
      ],
    },
    'transport': {
      'title': 'Phương tiện di chuyển',
      'content': [
        'Xe máy: Bãi đỗ miễn phí',
        'Taxi/Grab: 50.000 - 80.000đ từ trung tâm',
        'Xe buýt: Tuyến 04 (15.000đ)',
        'Đi bộ: Từ chợ Đầm khoảng 15 phút',
      ],
    },
    'tips': {
      'title': 'Lưu ý khi tham quan',
      'content': [
        'Ăn mặc lịch sự, tôn trọng nơi tâm linh',
        'Không chụp ảnh flash bên trong tháp',
        'Mang theo nước uống và kem chống nắng',
        'Tháo giày khi vào khu vực thờ cúng',
      ],
    },
  };

  // Gallery ảnh
  final List<String> _galleryImages = [
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
    'assets/images/onboarding4.png',
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
  ];

  // Reviews mock data
  final List<Map<String, dynamic>> _reviews = [
    {
      'user': 'Minh Anh',
      'avatar': 'assets/images/onboarding1.png',
      'rating': 5.0,
      'date': '20/8/2024',
      'content':
          'Điểm tham quan rất đẹp và ý nghĩa! Kiến trúc Chăm cổ kính rất ấn tượng. Hướng dẫn viên nhiệt tình giải thích về lịch sử. View nhìn xuống thành phố cũng tuyệt vời.',
      'helpful': 12,
      'images': ['assets/images/onboarding2.png'],
    },
    {
      'user': 'Thành Đạt',
      'avatar': 'assets/images/onboarding3.png',
      'rating': 4.5,
      'date': '15/8/2024',
      'content':
          'Nơi rất linh thiêng và yên tĩnh. Phù hợp để tìm hiểu văn hóa Chăm. Giá vé hợp lý. Chỉ có điều hơi nóng vào buổi trưa.',
      'helpful': 8,
      'images': null,
    },
    {
      'user': 'Thu Hằng',
      'avatar': 'assets/images/onboarding4.png',
      'rating': 4.8,
      'date': '10/8/2024',
      'content':
          'Tháp Po Nagar là điểm đến không thể bỏ qua ở Nha Trang. Kiến trúc độc đáo, không gian thiêng liêng. Đi cùng gia đình rất thích hợp.',
      'helpful': 15,
      'images': [
        'assets/images/onboarding1.png',
        'assets/images/onboarding3.png',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final attraction = widget.attraction;
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
          _heroImage(attraction),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _headerInfo(context, attraction),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _priceAndBooking(context, attraction),
          ),
          const SizedBox(height: 20),
          _sectionWrapper(
            context,
            title: 'Giới thiệu',
            child: _expandableText(
              context,
              text:
                  'Tháp Chăm Po Nagar là một trong những di tích lịch sử văn hóa quan trọng nhất của Nha Trang, được xây dựng từ thế kỷ 8-13 bởi người Chăm. Tháp thờ nữ thần Thiên Y Thánh Mẫu Ana Po Nagar, được người Chăm và Việt tôn kính như một vị thần linh thiêng bảo vệ ngư dân và nông dân. Kiến trúc độc đáo với những chi tiết chạm khắc tinh xảo thể hiện nền văn minh Chăm Pa phát triển. Từ đây, du khách có thể ngắm nhìn toàn cảnh sông Cái và thành phố Nha Trang.',
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),
          // ===== ĐIỂM NỔI BẬT =====
          _sectionWrapper(
            context,
            title: 'Điểm nổi bật',
            child: _highlightsSection(context),
          ),
          // ===== LOẠI VÀ DỊCH VỤ =====
          _typeAndServiceBlock(
            context,
            title: 'Loại hình tham quan',
            options: attraction['types']?.cast<String>() ?? [],
            activeSet: widget.activeTypes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Dịch vụ có sẵn',
            options: attraction['services']?.cast<String>() ?? [],
            activeSet: widget.activeServices ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Thời gian hoạt động',
            options: attraction['times']?.cast<String>() ?? [],
            activeSet: widget.activeTimes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Phù hợp cho',
            options: attraction['suit']?.cast<String>() ?? [],
            activeSet: widget.activeSuitability ?? {},
          ),
          // ===== VÉ THAM QUAN =====
          _sectionWrapper(
            context,
            title: 'Vé tham quan',
            child: _ticketSection(context),
          ),
          // ===== THÔNG TIN THỰC TẾ =====
          _sectionWrapper(
            context,
            title: 'Thông tin thực tế',
            child: _practicalInfoSection(context),
          ),
          // ===== GALLERY =====
          _sectionWrapper(
            context,
            title: 'Thư viện ảnh',
            child: _gallerySection(context),
          ),
          // ===== BẢN ĐỒ =====
          _sectionWrapper(
            context,
            title: 'Vị trí',
            child: _mapSection(context),
          ),
          // ===== ĐÁNH GIÁ =====
          _sectionWrapper(
            context,
            title: 'Đánh giá từ du khách',
            child: _ratingSummary(context),
          ),
          _sectionWrapper(
            context,
            title: 'Tất cả đánh giá',
            child: _reviewsSection(context),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ===== HERO IMAGE =====
  Widget _heroImage(Map<String, dynamic> attraction) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding${(attraction['img'] ?? 1) % 4 + 1}.png',
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
      ),
    );
  }

  // ===== HEADER =====
  Widget _headerInfo(BuildContext context, Map<String, dynamic> attraction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attraction['name'] ?? '',
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(LucideIcons.mapPin, size: 16, color: context.primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                attraction['location'] ?? '',
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _starsRow(context, attraction['rating']?.toDouble() ?? 4.0),
            const SizedBox(width: 8),
            Text(
              '${attraction['rating']?.toStringAsFixed(1) ?? '4.0'}',
              style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(2.341 đánh giá)',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: [
            _inlineAction(context, 'Xem bản đồ'),
            _inlineAction(context, 'Liên hệ'),
            _inlineAction(context, 'Viết đánh giá'),
            _inlineAction(context, 'Chia sẻ'),
          ],
        ),
      ],
    );
  }

  // ===== PRICE & BOOKING =====
  Widget _priceAndBooking(
    BuildContext context,
    Map<String, dynamic> attraction,
  ) {
    final price = attraction['price'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Từ ',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            Text(
              price == 0 ? 'Miễn phí' : '${_formatPrice(price)}đ',
              style: context.bodyOneStyle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: context.primaryColor,
              ),
            ),
            Text(
              '/người',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
              'Đặt vé ngay',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ===== HIGHLIGHTS SECTION =====
  Widget _highlightsSection(BuildContext context) {
    return Column(
      children: _highlights
          .map((highlight) => _highlightItem(context, highlight))
          .toList(),
    );
  }

  Widget _highlightItem(BuildContext context, _HighlightInfo highlight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(highlight.icon, size: 20, color: context.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.description,
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

  // ===== TYPE AND SERVICE BLOCK =====
  Widget _typeAndServiceBlock(
    BuildContext context, {
    required String title,
    required List<String> options,
    required Set<String> activeSet,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    return _sectionWrapper(
      context,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isActive = activeSet.contains(option);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? context.primaryColor.withValues(alpha: .12)
                  : context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? context.primaryColor : context.dividerColor,
              ),
            ),
            child: Text(
              option,
              style: context.captionStyle.copyWith(
                color: isActive
                    ? context.primaryColor
                    : context.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== TICKET SECTION =====
  Widget _ticketSection(BuildContext context) {
    return Column(
      children: _ticketOptions
          .map((ticket) => _ticketItem(context, ticket))
          .toList(),
    );
  }

  Widget _ticketItem(BuildContext context, _TicketInfo ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: context.bodyTwoStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.description,
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_formatPrice(ticket.price)}đ',
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...ticket.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.check,
                    size: 14,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      feature,
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
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

  // ===== PRACTICAL INFO SECTION =====
  Widget _practicalInfoSection(BuildContext context) {
    return Column(
      children: _practicalInfo.entries.map((entry) {
        final info = entry.value;
        return _practicalInfoItem(context, info['title'], info['content']);
      }).toList(),
    );
  }

  Widget _practicalInfoItem(
    BuildContext context,
    String title,
    List<String> content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...content.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== GALLERY SECTION =====
  Widget _gallerySection(BuildContext context) {
    final displayImages = _showAllGallery
        ? _galleryImages
        : _galleryImages.take(6).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: displayImages.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                displayImages[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.primaryColor.withValues(alpha: .1),
                  child: Icon(LucideIcons.image, color: context.primaryColor),
                ),
              ),
            );
          },
        ),
        if (!_showAllGallery && _galleryImages.length > 6)
          TextButton(
            onPressed: () => setState(() => _showAllGallery = true),
            child: Text(
              'Xem tất cả ${_galleryImages.length} ảnh',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ===== MAP SECTION =====
  Widget _mapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/onboarding2.png',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(LucideIcons.map, size: 18, color: context.primaryColor),
          label: Text(
            'Mở bản đồ',
            style: context.bodyTwoStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // ===== RATING SUMMARY =====
  Widget _ratingSummary(BuildContext context) {
    final rows = [
      {'label': 'Xuất sắc', 'value': 0.7},
      {'label': 'Rất tốt', 'value': 0.8},
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
                    '2.341 đánh giá',
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
                                '${((r['value'] as double) * 2341).round()}',
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
        ],
      ),
    );
  }

  // ===== REVIEWS SECTION =====
  Widget _reviewsSection(BuildContext context) {
    final displayReviews = _showAllReviews
        ? _reviews
        : _reviews.take(2).toList();

    return Column(
      children: [
        ...displayReviews.map((review) => _reviewItem(context, review)),
        if (!_showAllReviews && _reviews.length > 2)
          TextButton(
            onPressed: () => setState(() => _showAllReviews = true),
            child: Text(
              'Xem tất cả đánh giá',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _reviewItem(BuildContext context, Map<String, dynamic> review) {
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
            review['content'],
            style: context.bodyTwoStyle.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (review['images'] != null) ...[
            const SizedBox(height: 12),
            _reviewImages(context, review['images']),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.thumbsUp,
                size: 14,
                color: context.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${review['helpful']} hữu ích',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewImages(BuildContext context, List<String> images) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              images[index],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
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

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toString();
  }
}

class _HighlightInfo {
  final String title;
  final String description;
  final IconData icon;
  const _HighlightInfo(this.title, this.description, this.icon);
}

class _TicketInfo {
  final String title;
  final int price;
  final String description;
  final List<String> features;
  const _TicketInfo({
    required this.title,
    required this.price,
    required this.description,
    required this.features,
  });
}
