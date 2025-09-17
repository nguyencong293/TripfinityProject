import 'package:app/services/tour_api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class TourServiceDetailScreen extends StatefulWidget {
  final int? tourId; // optional id for fetching fresh data
  final Map<String, dynamic>? tour; // optional fallback from overview
  final Set<String>? activeTourTypes;
  final Set<String>? activeServices;
  final String? activeDifficulty;

  const TourServiceDetailScreen({
    super.key,
    this.tourId,
    this.tour,
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

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _detail; // fetched TourDTO
  List<Map<String, dynamic>> _reviews = [];

  int? get _idFromFallback {
    final t = widget.tour;
    if (t == null) return null;
    final v = t['tourId'] ?? t['id'] ?? t['tour_id'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  int? get _resolvedId => widget.tourId ?? _idFromFallback;

  Map<String, dynamic> get _data {
    final base = Map<String, dynamic>.from(widget.tour ?? {});
    // Normalize overview field names so UI is simpler
    if (base['title'] == null && base['name'] != null) {
      base['title'] = base['name'];
    }
    if (base['thumbnailUrl'] == null && base['image'] != null) {
      base['thumbnailUrl'] = base['image'];
    }
    // Merge fetched detail (detail values take precedence)
    if (_detail != null) base.addAll(_detail!);
    return base;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _resolvedId;
    if (id == null) {
      // No id, we still can render from fallback
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = TourApiService(dio: Dio(), prefs: prefs);

      final detail = await api.getTourById(id);
      final reviews = await api.getTourReviews(id);

      setState(() {
        _detail = detail;
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải dữ liệu tour. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final title = (d['title'] ?? '').toString();
    final rating = _ratingDouble(d['ratingAverage']);
    final reviewCount = _reviews.isNotEmpty
        ? _reviews.length
        : _numberFromAny(d['reviewCount'] ?? d['reviews']);
    final location =
        d['location']?.toString() ?? d['departureLocation']?.toString() ?? '';

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
              child: CircularProgressIndicator(color: context.primaryColor),
            )
          : _error != null
          ? _errorState(context, _error!)
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _heroImage(_primaryImageUrl(d)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(
                    context,
                    title,
                    rating,
                    reviewCount,
                    location,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _quickMeta(context, d),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _priceAndAction(context, d),
                ),
                const SizedBox(height: 20),
                _sectionWrapper(
                  context,
                  title: 'Giới thiệu tour',
                  child: _expandableText(
                    context,
                    text:
                        (d['serviceDescription'] ??
                                d['itineraryOverview'] ??
                                '—')
                            .toString(),
                    expanded: _introExpanded,
                    onToggle: () =>
                        setState(() => _introExpanded = !_introExpanded),
                  ),
                ),
                _tourTypeBlock(
                  context,
                  title: 'Loại tour',
                  selected: widget.activeTourTypes ?? {},
                ),
                _serviceChipsBlock(
                  context,
                  title: 'Dịch vụ bao gồm',
                  selected: widget.activeServices ?? {},
                ),
                _sectionWrapper(
                  context,
                  title: 'Lịch trình chi tiết',
                  child: _itineraryOverview(context, d['itineraryOverview']),
                ),
                _includedExcludedSection(context, d),
                _policiesSection(context, d['cancellationPolicy']),
                _difficultySection(
                  context,
                  widget.activeDifficulty ??
                      _difficultyLabelFromCode(d['difficultyLevel']),
                ),
                _departureInfoSection(context, d),
                _sectionWrapper(
                  context,
                  title: 'Thông tin đánh giá',
                  child: _ratingSummary(context, rating, reviewCount),
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
  Widget _heroImage(String? url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null || url.isEmpty)
            _imageFallback(context)
          else if (url.startsWith('http'))
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(context),
            )
          else
            Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(context),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.cardBackgroundColor.withValues(alpha: .85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.image,
                    size: 16,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Xem thêm ảnh',
                    style: context.captionStyle.copyWith(
                      color: context.textPrimaryColor,
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
  Widget _headerInfo(
    BuildContext context,
    String title,
    double rating,
    int? reviewCount,
    String location,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, rating),
            const SizedBox(width: 6),
            Text(
              '(${(reviewCount ?? 0)})',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 10),
              Icon(
                LucideIcons.mapPin,
                size: 14,
                color: context.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: [
            _inlineAction(context, 'Liên hệ'),
            _inlineAction(context, 'Viết đánh giá'),
            _inlineAction(context, 'Chia sẻ'),
          ],
        ),
      ],
    );
  }

  // ===== QUICK META =====
  Widget _quickMeta(BuildContext context, Map<String, dynamic> d) {
    final start = d['startDate']?.toString();
    final end = d['endDate']?.toString();
    final durationDays = _numberFromAny(d['durationDays']);
    final dateText = start != null && end != null
        ? '$start → $end'
        : (durationDays != null ? '$durationDays ngày' : '—');
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: dateText,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.users,
            label: '${d['capacity'] ?? d['minParticipants'] ?? '2'} khách',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, dynamic> d) {
    final price = d['price'];
    final currency = d['currencyCode']?.toString();
    final priceText = _formatPrice(price, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText.isEmpty ? '—' : priceText,
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
    final safe = (text.isEmpty) ? '—' : text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          safe,
          maxLines: expanded ? null : 4,
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

  // ===== TOUR TYPE & SERVICES (chips from filters) =====
  Widget _tourTypeBlock(
    BuildContext context, {
    required String title,
    required Set<String> selected,
  }) {
    if (selected.isEmpty) return const SizedBox.shrink();
    return _sectionWrapper(
      context,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selected.map((label) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.primaryColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.tag, size: 14, color: context.primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.captionStyle.copyWith(
                    color: context.textPrimaryColor,
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

  Widget _serviceChipsBlock(
    BuildContext context, {
    required String title,
    required Set<String> selected,
  }) {
    if (selected.isEmpty) return const SizedBox.shrink();
    return _sectionWrapper(
      context,
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selected.map((label) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.primaryColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.check, size: 14, color: context.primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.captionStyle.copyWith(
                    color: context.textPrimaryColor,
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

  // ===== ITINERARY OVERVIEW =====
  Widget _itineraryOverview(BuildContext context, dynamic overviewRaw) {
    final overview = overviewRaw?.toString() ?? '';
    if (overview.isEmpty) {
      return _emptyBox(context, 'Chưa có thông tin lịch trình');
    }
    final items = overview
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 2),
                  Icon(LucideIcons.dot, size: 18, color: context.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      line,
                      style: context.captionStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ===== INCLUDED / EXCLUDED =====
  Widget _includedExcludedSection(
    BuildContext context,
    Map<String, dynamic> d,
  ) {
    final included =
        _stringList(d['included']) ?? _stringList(d['inclusiveItems']) ?? [];
    final excluded =
        _stringList(d['excluded']) ?? _stringList(d['exclusiveItems']) ?? [];

    if (included.isEmpty && excluded.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (included.isNotEmpty)
          _sectionWrapper(
            context,
            title: 'Dịch vụ bao gồm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: included
                  .map((e) => _bulletRow(context, e, true))
                  .toList(),
            ),
          ),
        if (excluded.isNotEmpty)
          _sectionWrapper(
            context,
            title: 'Dịch vụ không bao gồm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: excluded
                  .map((e) => _bulletRow(context, e, false))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _bulletRow(BuildContext context, String text, bool good) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            good ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
            size: 16,
            color: good ? context.primaryColor : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.captionStyle.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== POLICIES =====
  Widget _policiesSection(BuildContext context, dynamic policyRaw) {
    final policy = policyRaw?.toString() ?? '';
    if (policy.isEmpty) return const SizedBox.shrink();
    final lines = policy
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return _sectionWrapper(
      context,
      title: 'Chính sách tour',
      child: _bulletList(context, lines),
    );
  }

  // ===== DIFFICULTY =====
  Widget _difficultySection(BuildContext context, String difficultyLabel) {
    return _sectionWrapper(
      context,
      title: 'Độ khó: $difficultyLabel',
      child: _difficultyInfo(context, difficultyLabel),
    );
  }

  Widget _difficultyInfo(BuildContext context, String difficulty) {
    // Map labels to icon + color + description
    final map = <String, Map<String, Object>>{
      'Dễ': {
        'icon': LucideIcons.smile,
        'color': Colors.green,
        'desc': 'Phù hợp với mọi lứa tuổi, không yêu cầu thể lực đặc biệt',
      },
      'Vừa': {
        'icon': LucideIcons.meh,
        'color': Colors.orange,
        'desc': 'Cần thể lực trung bình, có thể đi bộ trong thời gian dài',
      },
      'Khó': {
        'icon': LucideIcons.frown,
        'color': Colors.red,
        'desc': 'Yêu cầu thể lực tốt, có hoạt động mạo hiểm',
      },
    };

    final cfg = map[difficulty] ?? map['Dễ']!;
    final icon = cfg['icon'] as IconData;
    final color = cfg['color'] as Color;
    final desc = cfg['desc'] as String;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            desc,
            style: context.bodyTwoStyle.copyWith(
              color: context.textPrimaryColor,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  // ===== DEPARTURE / MEETING / LANGS =====
  Widget _departureInfoSection(BuildContext context, Map<String, dynamic> d) {
    final meetingPoint = d['meetingPoint']?.toString();
    final departure = d['departureLocation']?.toString();
    final langs = _stringList(d['guideLanguage']) ?? [];

    if ((meetingPoint == null || meetingPoint.isEmpty) &&
        (departure == null || departure.isEmpty) &&
        langs.isEmpty) {
      return const SizedBox.shrink();
    }

    return _sectionWrapper(
      context,
      title: 'Điểm khởi hành',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meetingPoint != null && meetingPoint.isNotEmpty)
            _itineraryDetail(context, LucideIcons.mapPin, meetingPoint),
          if (departure != null && departure.isNotEmpty)
            _itineraryDetail(context, LucideIcons.navigation, departure),
          if (langs.isNotEmpty)
            _itineraryDetail(
              context,
              LucideIcons.languages,
              'Ngôn ngữ: ${langs.join(', ')}',
            ),
        ],
      ),
    );
  }

  // ===== RATING SUMMARY =====
  Widget _ratingSummary(BuildContext context, double rating, int? count) {
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
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  rating.toStringAsFixed(1),
                  style: context.subTitleOneStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _starsRow(context, rating),
                    const SizedBox(height: 4),
                    Text(
                      '${count ?? 0} đánh giá',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                LucideIcons.messageSquare,
                size: 16,
                color: context.primaryColor,
              ),
              label: Text(
                'Viết đánh giá',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryColor),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ===== REVIEWS LIST =====
  Widget _reviewsSection(BuildContext context) {
    if (_reviews.isEmpty) {
      return _emptyBox(context, 'Chưa có đánh giá');
    }
    final visible = _showAllReviews ? _reviews : _reviews.take(3).toList();
    return Column(
      children: [
        ...visible.map((r) => _reviewItem(context, r)),
        if (!_showAllReviews && _reviews.length > 3)
          TextButton(
            onPressed: () => setState(() => _showAllReviews = true),
            child: Text(
              'Xem tất cả đánh giá',
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

  Widget _reviewItem(BuildContext context, Map<String, dynamic> r) {
    final rating = _numberFromAny(r['rating'])?.toDouble() ?? 0;
    final title = r['title']?.toString();
    final content = r['content']?.toString() ?? '';
    final userId = r['userId'] ?? r['user_id'];
    final date = r['createdAt']?.toString();

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
                backgroundColor: context.primaryColor.withValues(alpha: .1),
                child: Icon(
                  LucideIcons.user,
                  size: 16,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Người dùng #${userId ?? '—'}',
                      style: context.captionStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (date != null)
                      Text(
                        date,
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              _starsRow(context, rating),
            ],
          ),
          const SizedBox(height: 10),
          if (title != null && title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                title,
                style: context.bodyTwoStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Text(
            content,
            style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ===== HELPERS =====
  Widget _imageFallback(BuildContext context) {
    return Container(
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor, size: 40),
    );
  }

  Widget _emptyBox(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Center(
        child: Text(
          message,
          style: context.captionStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _itineraryDetail(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.captionStyle.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
                style: context.captionStyle.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Parsers/formatters =====
  String? _primaryImageUrl(Map<String, dynamic> d) {
    final images = d['imageUrls'];
    if (images is List && images.isNotEmpty) {
      final first = images.first?.toString();
      if (first != null && first.isNotEmpty) return first;
    }
    final tn = d['thumbnailUrl']?.toString();
    if (tn != null && tn.isNotEmpty) return tn;
    final fallback = d['image']?.toString();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  double _ratingDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int? _numberFromAny(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  List<String>? _stringList(dynamic v) {
    if (v == null) return null;
    if (v is List) return v.map((e) => e.toString()).toList();
    return null;
  }

  String _formatPrice(dynamic price, String? currency) {
    if (price == null) return '';
    num? n = price is num ? price : num.tryParse(price.toString());
    if (n == null) return price.toString();
    final c = (currency ?? '').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') {
      final intVal = n.round();
      final s = intVal.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      return '$s đ';
    }
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }

  String _difficultyLabelFromCode(dynamic code) {
    final c = code?.toString().toLowerCase();
    switch (c) {
      case 'easy':
        return 'Dễ';
      case 'moderate':
        return 'Vừa';
      case 'hard':
        return 'Khó';
      default:
        return 'Dễ';
    }
  }

  Widget _errorState(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 54,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Lỗi tải dữ liệu',
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryColor),
              ),
              child: Text(
                'Thử lại',
                style: context.bodyTwoStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
