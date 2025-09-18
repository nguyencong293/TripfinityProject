import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/attraction_api_service.dart';

class AttractionsOverviewDetailScreen extends StatefulWidget {
  final int? attractionId; // Cho phép truyền id
  final Map<String, dynamic>? attraction; // Fallback data khi chưa có id

  // Các filter đang được chọn để highlight
  final Set<String>? activeTypes;
  final Set<String>? activeServices;
  final Set<String>? activeTimes;
  final Set<String>? activeSuitability;

  const AttractionsOverviewDetailScreen({
    super.key,
    this.attractionId,
    this.attraction,
    this.activeTypes,
    this.activeServices,
    this.activeTimes,
    this.activeSuitability,
  }) : assert(
         attractionId != null || attraction != null,
         'Cần truyền attractionId hoặc attraction',
       );

  @override
  State<AttractionsOverviewDetailScreen> createState() =>
      _AttractionsOverviewDetailScreenState();
}

class _AttractionsOverviewDetailScreenState
    extends State<AttractionsOverviewDetailScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;
  bool _showAllGallery = false;

  // Dynamic state from backend
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _errorMessage;
  int? _attractionId;

  // Reviews dynamic (backend endpoint có thể chưa có; để trống)
  final List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    // Ưu tiên id truyền vào; fallback sang id trong map nếu có
    _attractionId =
        widget.attractionId ??
        _parseId(
          widget.attraction?['attractionId'] ?? widget.attraction?['id'],
        );
    _fetchDetail();
  }

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  Future<void> _fetchDetail() async {
    // Nếu không có id nhưng có map fallback => render từ map, không gọi API
    if (_attractionId == null) {
      setState(() {
        _loading = false;
        if (widget.attraction == null) {
          _errorMessage = 'Thiếu attractionId để tải dữ liệu.';
        }
      });
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final api = AttractionApiService(dio: Dio(), prefs: prefs);

      final data = await api.getAttractionById(_attractionId!);
      // Optional: fetch reviews nếu backend có
      // final reviews = await api.getAttractionReviews(_attractionId!);

      setState(() {
        _detail = data;
        // _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  // ===== Helpers để đọc dữ liệu an toàn =====
  Map<String, dynamic> get _data {
    // Gộp dữ liệu truyền từ list + dữ liệu fetch (fetch ưu tiên)
    return {...?widget.attraction, if (_detail != null) ..._detail!};
  }

  String _title(Map<String, dynamic> d) =>
      (d['title'] ?? d['name'] ?? '').toString();

  String _locationText(Map<String, dynamic> d) {
    final loc = d['location'];
    final addr = d['address'];
    return (loc ?? addr ?? '').toString();
  }

  double _rating(Map<String, dynamic> d) {
    final r = d['ratingAverage'] ?? d['rating'];
    if (r == null) return 0.0;
    if (r is num) return r.toDouble();
    return double.tryParse(r.toString()) ?? 0.0;
  }

  num? _price(Map<String, dynamic> d) {
    final p = d['price'];
    if (p == null) return null;
    if (p is num) return p;
    return num.tryParse(p.toString());
  }

  String? _currency(Map<String, dynamic> d) {
    final c = d['currencyCode'];
    return c is String ? c : c?.toString();
  }

  List<String> _images(Map<String, dynamic> d) {
    final imgs = d['imageUrls'];
    if (imgs is List) {
      return imgs.map((e) => e.toString()).toList();
    }
    return const [];
  }

  String? _thumbnail(Map<String, dynamic> d) {
    final t = d['thumbnailUrl'];
    return t?.toString();
  }

  List<String> _listOfStrings(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  List<String> _visitTypes(Map<String, dynamic> d) =>
      _listOfStrings(d['visitTypesJson']);

  List<String> _features(Map<String, dynamic> d) =>
      _listOfStrings(d['featuresJson']);

  List<String> _suitableFor(Map<String, dynamic> d) =>
      _listOfStrings(d['suitableForJson']);

  List<String> _availableTimes(Map<String, dynamic> d) {
    final v = d['availableTimesJson'];
    if (v is List) return _listOfStrings(v);
    if (v is Map) {
      // Map -> "key: value"
      return v.entries.map((e) => '${e.key}: ${e.value}').toList();
    }
    return const [];
  }

  String _intro(Map<String, dynamic> d) =>
      (d['serviceDescription'] ?? '').toString();

  List<String> _highlights(Map<String, dynamic> d) =>
      _listOfStrings(d['highlightsJson']);

  List<String> _openingHours(Map<String, dynamic> d) {
    final oh = d['openingHoursJson'];
    if (oh is List) return _listOfStrings(oh);
    if (oh is Map) {
      return oh.entries.map((e) => '${e.key}: ${e.value}').toList();
    }
    return const [];
  }

  List<String> _tips(Map<String, dynamic> d) {
    final t = d['tipsText'];
    if (t == null) return const [];
    return t
        .toString()
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _formatPrice(num? price, {String? currency}) {
    if (price == null || price == 0) return 'Miễn phí';
    final isVnd = (currency ?? '').toUpperCase() == 'VND';
    String compact;
    if (price >= 1000000) {
      compact = '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      compact = '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      compact = price.toStringAsFixed(0);
    }
    return isVnd ? '$compactđ' : '$compact ${currency ?? ''}'.trim();
  }

  bool _isHttpUrl(String? s) {
    if (s == null) return false;
    return s.startsWith('http://') || s.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.backgroundColor,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.backgroundColor,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, style: context.bodyTwoStyle),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _errorMessage = null;
                  });
                  _fetchDetail();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final attraction = _data;
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
              text: _intro(attraction).isNotEmpty
                  ? _intro(attraction)
                  : 'Chưa có mô tả chi tiết.',
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),
          // ===== ĐIỂM NỔI BẬT =====
          if (_highlights(attraction).isNotEmpty)
            _sectionWrapper(
              context,
              title: 'Điểm nổi bật',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _highlights(
                  attraction,
                ).map((h) => _highlightItemText(context, h)).toList(),
              ),
            ),
          // ===== LOẠI VÀ DỊCH VỤ =====
          _typeAndServiceBlock(
            context,
            title: 'Loại hình tham quan',
            options: _visitTypes(attraction),
            activeSet: widget.activeTypes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Dịch vụ có sẵn',
            options: _features(attraction),
            activeSet: widget.activeServices ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Thời gian hoạt động',
            options: _availableTimes(attraction),
            activeSet: widget.activeTimes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'Phù hợp cho',
            options: _suitableFor(attraction),
            activeSet: widget.activeSuitability ?? {},
          ),
          // ===== VÉ THAM QUAN ===== (giữ nguyên demo)
          _sectionWrapper(
            context,
            title: 'Vé tham quan',
            child: _ticketSection(context),
          ),
          // ===== THÔNG TIN THỰC TẾ =====
          _sectionWrapper(
            context,
            title: 'Thông tin thực tế',
            child: _practicalInfoSectionDynamic(context, attraction),
          ),
          // ===== GALLERY =====
          _sectionWrapper(
            context,
            title: 'Thư viện ảnh',
            child: _gallerySection(context, attraction),
          ),
          // ===== BẢN ĐỒ =====
          _sectionWrapper(
            context,
            title: 'Vị trí',
            child: _mapSection(context, attraction),
          ),
          // ===== ĐÁNH GIÁ =====
          _sectionWrapper(
            context,
            title: 'Đánh giá từ du khách',
            child: _ratingSummary(context, attraction),
          ),
          if (_reviews.isNotEmpty)
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
    final images = _images(attraction);
    final thumb = _thumbnail(attraction);
    final first = (thumb?.isNotEmpty == true)
        ? thumb!
        : (images.isNotEmpty ? images.first : null);
    final total = (images.isNotEmpty ? images.length : (first != null ? 1 : 0));

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (first != null && _isHttpUrl(first))
            Image.network(
              first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroFallback(),
            )
          else if (first != null)
            Image.asset(
              first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroFallback(),
            )
          else
            _heroFallback(),
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
                  const Icon(LucideIcons.image, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    total > 0 ? '1 / $total' : '0 / 0',
                    style: const TextStyle(
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

  Widget _heroFallback() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 48, color: Colors.white70),
    );
  }

  // ===== HEADER =====
  Widget _headerInfo(BuildContext context, Map<String, dynamic> attraction) {
    final rating = _rating(attraction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title(attraction),
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
                _locationText(attraction),
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
            _starsRow(context, rating),
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(đánh giá)',
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
    final price = _price(attraction);
    final currency = _currency(attraction);
    final priceText = _formatPrice(price, currency: currency);

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
              priceText,
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

  // ===== HIGHLIGHTS SECTION (text bullets) =====
  Widget _highlightItemText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.topCenter,
            child: Icon(
              LucideIcons.sparkles,
              size: 16,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
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

  // ===== TICKET SECTION (demo) =====
  Widget _ticketSection(BuildContext context) {
    final List<_TicketInfo> ticketOptions = [
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
    return Column(
      children: ticketOptions
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
                _formatPrice(ticket.price),
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

  // ===== PRACTICAL INFO SECTION (từ backend nếu có) =====
  Widget _practicalInfoSectionDynamic(
    BuildContext context,
    Map<String, dynamic> d,
  ) {
    final infos = <Map<String, dynamic>>[];

    final opening = _openingHours(d);
    if (opening.isNotEmpty) {
      infos.add({'title': 'Giờ mở cửa', 'content': opening});
    }

    final addr = _locationText(d);
    if (addr.isNotEmpty) {
      infos.add({
        'title': 'Vị trí',
        'content': ['Địa chỉ: $addr'],
      });
    }

    final tips = _tips(d);
    if (tips.isNotEmpty) {
      infos.add({'title': 'Lưu ý khi tham quan', 'content': tips});
    }

    if (infos.isEmpty) {
      return Text(
        'Chưa có thêm thông tin thực tế.',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

    return Column(
      children: infos
          .map(
            (info) => _practicalInfoItem(
              context,
              info['title'] as String,
              (info['content'] as List).cast<String>(),
            ),
          )
          .toList(),
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
  Widget _gallerySection(BuildContext context, Map<String, dynamic> d) {
    final allImages = _images(d);
    final displayImages = _showAllGallery
        ? allImages
        : allImages.take(6).toList();

    if (allImages.isEmpty) {
      return Text(
        'Chưa có ảnh.',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

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
            final url = displayImages[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _isHttpUrl(url)
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: context.primaryColor.withValues(alpha: .1),
                        child: Icon(
                          LucideIcons.image,
                          color: context.primaryColor,
                        ),
                      ),
                    )
                  : Image.asset(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: context.primaryColor.withValues(alpha: .1),
                        child: Icon(
                          LucideIcons.image,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
            );
          },
        ),
        if (!_showAllGallery && allImages.length > 6)
          TextButton(
            onPressed: () => setState(() => _showAllGallery = true),
            child: Text(
              'Xem tất cả ${allImages.length} ảnh',
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
  Widget _mapSection(BuildContext context, Map<String, dynamic> d) {
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
  Widget _ratingSummary(BuildContext context, Map<String, dynamic> d) {
    final rating = _rating(d);

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
                    rating.toStringAsFixed(1),
                    style: context.subTitleOneStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  _starsRow(context, rating),
                  const SizedBox(height: 4),
                  Text(
                    'đánh giá',
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
                                '',
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
    if (_reviews.isEmpty) {
      return Text(
        'Chưa có đánh giá.',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

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
    final images =
        (review['images'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
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
                backgroundImage: const AssetImage(
                  'assets/images/onboarding1.png',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (review['user'] ?? 'Khách').toString(),
                      style: context.bodyTwoStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _starsRow(
                          context,
                          (review['rating'] as num?)?.toDouble() ?? 0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (review['date'] ?? '').toString(),
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
            (review['content'] ?? '').toString(),
            style: context.bodyTwoStyle.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _reviewImages(context, images),
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
                '${review['helpful'] ?? 0} hữu ích',
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
          final url = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isHttpUrl(url)
                ? Image.network(url, width: 60, height: 60, fit: BoxFit.cover)
                : Image.asset(url, width: 60, height: 60, fit: BoxFit.cover),
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
