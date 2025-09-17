import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

// NEW: API
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/hotel_api_service.dart';

class HotelDetailOverviewScreen extends StatefulWidget {
  // Prefer id to fetch live detail
  final int? hotelId;

  // Optional fallback for instant UI while fetching (from search list)
  final Map<String, String>? hotel;

  // Set of selected amenities to highlight (optional)
  final Set<String>? activeAmenities;

  const HotelDetailOverviewScreen({
    super.key,
    this.hotelId,
    this.hotel,
    this.activeAmenities,
  }) : assert(
         hotelId != null || hotel != null,
         'hotelId or hotel fallback must be provided',
       );

  @override
  State<HotelDetailOverviewScreen> createState() =>
      _HotelDetailOverviewScreenState();
}

class _HotelDetailOverviewScreenState extends State<HotelDetailOverviewScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;

  // Loading state
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _reviews = [];

  int? _resolvedId;

  // Amenity catalogs for UI grouping (icons only)
  late final List<_Amenity> _propertyAmenities = [
    _Amenity('Wifi miễn phí', LucideIcons.wifi),
    _Amenity('Bể bơi', LucideIcons.umbrella),
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

  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _resolvedId = widget.hotelId ?? _tryParseInt(widget.hotel?['hotelId']);
    _fetchDetail();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data; // merged view

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
      body: _loading
          ? Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.primaryColor,
                ),
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: context.bodyOneStyle.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _heroImage(_primaryImage(data)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(context, data),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _quickMeta(context),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _priceAndAction(context, data),
                ),
                const SizedBox(height: 20),

                // Giới thiệu
                _sectionWrapper(
                  context,
                  title: 'Giới thiệu',
                  child: _expandableText(
                    context,
                    text: data['serviceDescription']?.toString() ?? '—',
                    expanded: _introExpanded,
                    onToggle: () =>
                        setState(() => _introExpanded = !_introExpanded),
                  ),
                ),

                // Highlights (from highlightsJson)
                if (_listOfString(data['highlightsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Điểm nổi bật',
                    child: _bulletList(
                      context,
                      _listOfString(data['highlightsJson']),
                    ),
                  ),

                // Amenity blocks
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

                // Amenities from backend (amenitiesJson)
                if (_listOfString(data['amenitiesJson']).isNotEmpty)
                  _amenitiesBlock(
                    context,
                    title: 'Tiện nghi theo khách sạn',
                    amenities: _listOfString(data['amenitiesJson']),
                    initiallyVisible: 8,
                  ),

                // Policies
                if ((data['policiesText'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chính sách & tuỳ chọn',
                    child: _bulletList(
                      context,
                      (data['policiesText'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Khu vực
                _sectionWrapper(
                  context,
                  title: 'Khu vực',
                  child: _locationBlock(context, data),
                ),

                // Thông tin khách du lịch (rating summary placeholder)
                _sectionWrapper(
                  context,
                  title: 'Thông tin khách du lịch',
                  child: _ratingSummary(context, data),
                ),

                // Reviews
                _sectionWrapper(
                  context,
                  title: 'Tất cả đánh giá',
                  child: _reviewsBlock(context),
                ),

                const SizedBox(height: 28),
              ],
            ),
    );
  }

  // ===== Fetch & merge =====
  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? detail;
      List<Map<String, dynamic>> reviews = [];

      if (_resolvedId != null) {
        final prefs = await SharedPreferences.getInstance();
        final api = HotelApiService(dio: Dio(), prefs: prefs);

        detail = await api.getHotelById(_resolvedId!);
        // Reviews are optional; load but don't fail the whole screen
        try {
          reviews = await api.getHotelReviews(_resolvedId!);
        } catch (_) {}
      } else {
        // No id: render fallback only
        detail = null;
      }

      setState(() {
        _detail = detail;
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải chi tiết khách sạn. Vui lòng thử lại.';
      });
    }
  }

  Map<String, dynamic> get _data {
    // Merge: fetched detail wins over fallback
    final merged = <String, dynamic>{};
    if (widget.hotel != null) merged.addAll(widget.hotel!);
    if (_detail != null) merged.addAll(_detail!);
    return merged;
  }

  // ===== UI pieces =====
  Widget _heroImage(String? urlOrAsset) {
    final images = _imageList(_data);
    final primary = (urlOrAsset ?? '').isNotEmpty
        ? urlOrAsset!
        : (images.isNotEmpty ? images.first : '');

    final isNetwork = primary.startsWith('http');

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use fallback if empty or any load error happens
          if (primary.isEmpty)
            _imageFallback(context)
          else if (isNetwork)
            Image.network(
              primary,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(context),
            )
          else
            Image.asset(
              primary,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(context),
            ),

          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.image,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '1 / ${images.length}',
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

  Widget _headerInfo(BuildContext context, Map<String, dynamic> d) {
    final name = d['title']?.toString() ?? d['name']?.toString() ?? '';
    final ratingAvg =
        _toDouble(d['ratingAverage']) ?? _toDouble(d['rating']) ?? 0.0;
    final starRating = _toInt(d['starRating']);
    final ratingLabel = ratingAvg > 4.2
        ? 'Tuyệt vời'
        : ratingAvg > 3.5
        ? 'Tốt'
        : ratingAvg > 2.5
        ? 'Ổn'
        : '—';

    final reviewsCount =
        _reviews.length; // can replace by aggregate if backend adds

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (starRating != null) _starsRow(context, starRating.toDouble()),
            if (starRating != null) const SizedBox(width: 8),
            Icon(Icons.star_rounded, color: context.primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              ratingAvg.toStringAsFixed(1),
              style: context.captionStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '($reviewsCount)',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (ratingLabel != '—') ...[
          const SizedBox(height: 4),
          Text(
            ratingLabel,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
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

  Widget _priceAndAction(BuildContext context, Map<String, dynamic> d) {
    final price = d['price'];
    final currency = d['currencyCode']?.toString();
    final priceText = price == null
        ? (d['price']?.toString() ?? '—')
        : _formatPrice(price, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
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

  Widget _amenitiesBlock(
    BuildContext context, {
    required String title,
    required List amenities, // accepts List<String> or List<_Amenity>
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
      return _Amenity(e.toString(), LucideIcons.check);
    }).toList();
  }

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

  Widget _ratingSummary(BuildContext context, Map<String, dynamic> d) {
    final avg = _toDouble(d['ratingAverage']) ?? 0.0;
    final label = avg >= 4.5
        ? 'Tuyệt vời'
        : avg >= 4.0
        ? 'Rất tốt'
        : avg >= 3.5
        ? 'Tốt'
        : 'Khá';

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
                  avg.toStringAsFixed(1),
                  style: context.h5Style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  ),
                ),
                Text(
                  label,
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _starsRow(context, (avg / 1.0).clamp(0, 5)),
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
                              '—',
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

  Widget _reviewsBlock(BuildContext context) {
    if (_reviews.isEmpty) {
      return Text(
        'Chưa có đánh giá',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

    final visible = _showAllReviews ? _reviews : _reviews.take(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visible.map((r) => _reviewItem(context, r)),
        const SizedBox(height: 8),
        if (_reviews.length > 2 && !_showAllReviews)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _showAllReviews = true),
              child: Text(
                'Xem thêm ${_reviews.length - 2} đánh giá',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _reviewItem(BuildContext context, Map<String, dynamic> r) {
    final userName = r['userName']?.toString() ?? 'Người dùng';
    final rating = _toDouble(r['rating']) ?? 5.0;
    final content = r['content']?.toString() ?? '';
    final createdAt = r['createdAt']?.toString() ?? '';
    final date = _formatDate(createdAt);
    final replyCount = _toInt(r['replyCount']) ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _starsRow(context, rating),
          const SizedBox(height: 6),
          Text(content, style: context.bodyTwoStyle.copyWith(height: 1.35)),
          if (replyCount > 0) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () {},
              child: Text(
                'Hiển thị phản hồi ( $replyCount )',
                style: context.captionStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _locationBlock(BuildContext context, Map<String, dynamic> d) {
    final address = d['address']?.toString();
    final location = d['location']?.toString();
    final text = address?.isNotEmpty == true ? address! : (location ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text.isNotEmpty)
          InkWell(
            onTap: () {},
            child: Text(
              text,
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
    );
  }

  // ===== Helpers =====
  int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String _primaryImage(Map<String, dynamic> d) {
    final images = _imageList(d);
    if (images.isNotEmpty) return images.first;
    final th = d['thumbnailUrl']?.toString() ?? d['image']?.toString() ?? '';
    return th;
  }

  List<String> _imageList(Map<String, dynamic> d) {
    final raw = d['imageUrls'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  List<String> _listOfString(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    // Cheap formatter: take yyyy-mm-dd or yyyy-mm-ddTHH
    final parts = iso.split('T').first.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return iso;
  }

  String _formatPrice(dynamic price, String? currency) {
    if (price == null) return '';
    num? n;
    if (price is num) {
      n = price;
    } else {
      n = num.tryParse(price.toString());
    }
    if (n == null) return price.toString();
    final c = (currency ?? '').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') {
      return '${n.toStringAsFixed(0)} đ';
    }
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }

  // NEW: unified image fallback (used for hero image load errors)
  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

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
