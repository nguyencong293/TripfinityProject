import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/attraction_api_service.dart';
import 'package:app/services/localization_service.dart';

class AttractionsOverviewDetailScreen extends StatefulWidget {
  final int? attractionId;
  final Map<String, dynamic>? attraction;

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

  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _errorMessage;
  int? _attractionId;

  final List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
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
    if (_attractionId == null) {
      setState(() {
        _loading = false;
        if (widget.attraction == null) {
          _errorMessage = 'missing_attraction_id'.tr;
        }
      });
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final api = AttractionApiService(dio: Dio(), prefs: prefs);

      final data = await api.getAttractionById(_attractionId!);

      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'error_load_failed'.tr;
        _loading = false;
      });
    }
  }

  Map<String, dynamic> get _data {
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
    if (price == null || price == 0) return 'free'.tr;
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
                child: Text('retry'.tr),
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
            title: 'introduction'.tr,
            child: _expandableText(
              context,
              text: _intro(attraction).isNotEmpty
                  ? _intro(attraction)
                  : 'no_description'.tr,
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),
          if (_highlights(attraction).isNotEmpty)
            _sectionWrapper(
              context,
              title: 'highlights'.tr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _highlights(
                  attraction,
                ).map((h) => _highlightItemText(context, h)).toList(),
              ),
            ),
          _typeAndServiceBlock(
            context,
            title: 'visit_types'.tr,
            options: _visitTypes(attraction),
            activeSet: widget.activeTypes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'available_services'.tr,
            options: _features(attraction),
            activeSet: widget.activeServices ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'operating_times'.tr,
            options: _availableTimes(attraction),
            activeSet: widget.activeTimes ?? {},
          ),
          _typeAndServiceBlock(
            context,
            title: 'suitable_for'.tr,
            options: _suitableFor(attraction),
            activeSet: widget.activeSuitability ?? {},
          ),
          _sectionWrapper(
            context,
            title: 'tickets'.tr,
            child: _ticketSection(context),
          ),
          _sectionWrapper(
            context,
            title: 'practical_info'.tr,
            child: _practicalInfoSectionDynamic(context, attraction),
          ),
          _sectionWrapper(
            context,
            title: 'gallery'.tr,
            child: _gallerySection(context, attraction),
          ),
          _sectionWrapper(
            context,
            title: 'location'.tr,
            child: _mapSection(context, attraction),
          ),
          _sectionWrapper(
            context,
            title: 'reviews_title'.tr,
            child: _ratingSummary(context, attraction),
          ),
          if (_reviews.isNotEmpty)
            _sectionWrapper(
              context,
              title: 'all_reviews'.tr,
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
                color: context.overlayModalBackdropColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.image,
                    size: 14,
                    color: context.buttonTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    total > 0 ? '1 / $total' : '0 / 0',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.buttonTextColor,
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
      color: context.skeletonPlaceholderColor,
      child: Icon(Icons.image, size: 48, color: context.textSecondaryColor),
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
              'reviews_title'.tr,
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
            _inlineAction(context, 'view_map'.tr),
            _inlineAction(context, 'contact_title'.tr),
            _inlineAction(context, 'write_review'.tr),
            _inlineAction(context, 'share'.tr),
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
              '${'from'.tr} ',
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
              '/${'per_person'.tr}',
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
            child: Text(
              'book_now'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                  ? context.primaryColor.withValues(alpha: 0.12)
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
        title: 'ticket_adult'.tr,
        price: 120000,
        description: 'ticket_adult_desc'.tr,
        features: [
          'ticket_feature_free_visit'.tr,
          'ticket_feature_basic_guide'.tr,
        ],
      ),
      _TicketInfo(
        title: 'ticket_child'.tr,
        price: 60000,
        description: 'ticket_child_desc'.tr,
        features: [
          'ticket_feature_free_visit'.tr,
          'ticket_feature_basic_guide'.tr,
        ],
      ),
      _TicketInfo(
        title: 'ticket_combo_guide'.tr,
        price: 200000,
        description: 'ticket_combo_guide_desc'.tr,
        features: [
          'ticket_feature_pro_guide'.tr,
          'ticket_feature_history'.tr,
          'ticket_feature_photos'.tr,
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
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
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
      infos.add({'title': 'opening_hours'.tr, 'content': opening});
    }

    final addr = _locationText(d);
    if (addr.isNotEmpty) {
      infos.add({
        'title': 'location'.tr,
        'content': ['${'address'.tr}: $addr'],
      });
    }

    final tips = _tips(d);
    if (tips.isNotEmpty) {
      infos.add({'title': 'visiting_tips'.tr, 'content': tips});
    }

    if (infos.isEmpty) {
      return Text(
        'no_description'.tr,
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
        'no_photos'.tr,
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
                        color: context.primaryColor.withValues(alpha: 0.1),
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
                        color: context.primaryColor.withValues(alpha: 0.1),
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
              '${'see_all'.tr} ${allImages.length} ${'photos'.tr}',
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
            'open_map'.tr,
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
      {'label': 'rating_excellent'.tr, 'value': 0.7},
      {'label': 'rating_very_good'.tr, 'value': 0.8},
      {'label': 'rating_good'.tr, 'value': 0.1},
      {'label': 'rating_fair'.tr, 'value': 0.0},
      {'label': 'rating_poor'.tr, 'value': 0.0},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
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
                    'reviews_title'.tr,
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
        'no_reviews'.tr,
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
              'see_all_reviews'.tr,
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
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/onboarding1.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (review['user'] ?? 'guest'.tr).toString(),
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
                '${review['helpful'] ?? 0} ${'helpful'.tr}',
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
            expanded ? 'show_less'.tr : 'read_more'.tr,
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
          color: context.textPrimaryColor,
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
