import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

import 'package:app/services/restaurant_api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/localization_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int? restaurantId;
  final Map<String, String>? restaurant;
  final Set<String> activeCuisines;
  final Set<String> activeServices;
  final Set<String> activeDietaries;
  final Set<int> activeStars;
  final bool activeOpenNow;
  final bool activeReservation;
  final bool activeTakeAway;

  const RestaurantDetailScreen({
    super.key,
    this.restaurantId,
    this.restaurant,
    this.activeCuisines = const {},
    this.activeServices = const {},
    this.activeDietaries = const {},
    this.activeStars = const {},
    this.activeOpenNow = false,
    this.activeReservation = false,
    this.activeTakeAway = false,
  }) : assert(
         restaurantId != null || restaurant != null,
         'Either restaurantId or restaurant must be provided',
       );

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _introExpanded = false;
  bool _showAllReviews = false;
  final Map<String, bool> _expandedState = {};

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _restaurantData;
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _openingHours = [];

  List<_RestaurantFeature> get _cuisineFeatures => [
    _RestaurantFeature('cuisine_vietnamese'.tr, LucideIcons.wine),
    _RestaurantFeature('cuisine_seafood'.tr, LucideIcons.fish),
    _RestaurantFeature('cuisine_western'.tr, LucideIcons.wine),
    _RestaurantFeature('cuisine_korean'.tr, LucideIcons.wine),
    _RestaurantFeature('cuisine_japanese'.tr, LucideIcons.wine),
    _RestaurantFeature('cuisine_thai'.tr, LucideIcons.eggFried),
    _RestaurantFeature('cuisine_chinese'.tr, LucideIcons.wine),
    _RestaurantFeature('cuisine_vegan'.tr, LucideIcons.leaf),
    _RestaurantFeature('cuisine_grill'.tr, LucideIcons.flame),
    _RestaurantFeature('cuisine_coffee'.tr, LucideIcons.coffee),
  ];

  List<_RestaurantFeature> get _serviceFeatures => [
    _RestaurantFeature('service_dine_in'.tr, LucideIcons.utensils),
    _RestaurantFeature('service_take_away'.tr, LucideIcons.shoppingBag),
    _RestaurantFeature('service_delivery'.tr, LucideIcons.bike),
    _RestaurantFeature('service_bar'.tr, LucideIcons.beer),
    _RestaurantFeature('service_garden'.tr, LucideIcons.treePine),
    _RestaurantFeature('service_private_room'.tr, LucideIcons.doorClosed),
  ];

  List<_RestaurantFeature> get _dietaryFeatures => [
    _RestaurantFeature('dietary_vegan'.tr, LucideIcons.leaf),
    _RestaurantFeature('dietary_halal'.tr, LucideIcons.badgeCheck),
    _RestaurantFeature('dietary_gluten_free'.tr, LucideIcons.wheatOff),
    _RestaurantFeature('dietary_low_calorie'.tr, LucideIcons.scale),
    _RestaurantFeature('dietary_dairy_free'.tr, LucideIcons.milkOff),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
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
        body: Center(
          child: CircularProgressIndicator(color: context.primaryColor),
        ),
      );
    }

    if (_error != null) {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: context.errorColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: context.bodyOneStyle.copyWith(
                    color: context.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchRestaurantData,
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: Text('retry'.tr, style: context.buttonStyle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.buttonTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          _heroImage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _headerInfo(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _quickMeta(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _priceAndAction(context),
          ),
          const SizedBox(height: 20),

          // ===== GIỚI THIỆU =====
          _sectionWrapper(
            context,
            title: 'intro'.tr,
            child: _expandableText(
              context,
              text: _getDescription(),
              expanded: _introExpanded,
              onToggle: () => setState(() => _introExpanded = !_introExpanded),
            ),
          ),

          _featuresBlock(
            context,
            title: 'cuisines'.tr,
            features: _cuisineFeatures,
            activeFeatures: _getActiveCuisines(),
            initiallyVisible: 6,
          ),

          _featuresBlock(
            context,
            title: 'services'.tr,
            features: _serviceFeatures,
            activeFeatures: _getActiveServices(),
            initiallyVisible: 4,
          ),

          _featuresBlock(
            context,
            title: 'dietaries'.tr,
            features: _dietaryFeatures,
            activeFeatures: _getActiveDietaries(),
            initiallyVisible: 3,
          ),

          // ===== GIỜ MỞ CỬA =====
          if (_openingHours.isNotEmpty)
            _sectionWrapper(
              context,
              title: 'opening_hours'.tr,
              child: Column(
                children: _openingHours.map((hour) {
                  final isToday = _isToday(hour['day'] ?? '');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            hour['day'] ?? '',
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
                            hour['hours'] ?? '',
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
                              color: context.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'open_now'.tr,
                              style: context.captionStyle.copyWith(
                                color: context.primaryColor,
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
            title: 'area'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {},
                  child: Text(
                    _getAddress(),
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
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: _mapPlaceholder(context),
                  ),
                ),
              ],
            ),
          ),

          // ===== THÔNG TIN KHÁCH HÀNG =====
          _sectionWrapper(
            context,
            title: 'customer_info'.tr,
            child: _ratingSummary(context),
          ),

          // ===== TẤT CẢ ĐÁNH GIÁ =====
          if (_reviews.isNotEmpty)
            _sectionWrapper(
              context,
              title: 'all_reviews'.tr,
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
                            ? 'read_less'.tr
                            : '${'view_more'.tr} ${_reviews.length - 2} ${'reviews'.tr}',
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

  // ===== DATA FETCHING =====
  Future<void> _fetchRestaurantData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = RestaurantApiService(dio: Dio(), prefs: prefs);

      Map<String, dynamic> restaurantData;

      if (widget.restaurantId != null) {
        restaurantData = await api.getRestaurantById(widget.restaurantId!);
      } else {
        restaurantData = _convertOldFormatToNew(widget.restaurant!);
      }

      List<Map<String, dynamic>> reviews = [];
      if (widget.restaurantId != null) {
        try {
          reviews = await api.getRestaurantReviews(widget.restaurantId!);
        } catch (e) {
          // Reviews fetch failed but restaurant data succeeded
        }
      }

      setState(() {
        _restaurantData = restaurantData;
        _reviews = reviews;
        _openingHours = _parseOpeningHours(restaurantData['openingHours']);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'error_load_restaurant_detail'.tr;
      });
    }
  }

  Map<String, dynamic> _convertOldFormatToNew(Map<String, String> oldFormat) {
    return {
      'title': oldFormat['name'] ?? '',
      'location': oldFormat['location'] ?? '',
      'serviceDescription': 'restaurant_intro_fallback'.tr.replaceFirst(
        '%s',
        oldFormat['name'] ?? '',
      ),
      'ratingAverage': double.tryParse(oldFormat['rating'] ?? '0') ?? 0.0,
      'price': _parsePrice(oldFormat['price'] ?? ''),
      'currencyCode': 'VND',
      'address': oldFormat['location'] ?? '',
      'phone': '',
      'website': '',
      'thumbnailUrl': oldFormat['image'],
      'imageUrls': [oldFormat['image'] ?? ''],
      'cuisines': [oldFormat['cuisine'] ?? 'cuisine_western'.tr],
      'services': ['service_dine_in'.tr],
      'diets': [],
      'badges': [],
      'priceLevel': 'moderate',
    };
  }

  double _parsePrice(String priceStr) {
    final numbers = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(numbers) ?? 0.0;
  }

  List<Map<String, dynamic>> _parseOpeningHours(dynamic openingHours) {
    if (openingHours == null) {
      return [
        {'day': 'Thứ 2', 'hours': '09:00 - 22:00'},
        {'day': 'Thứ 3', 'hours': '09:00 - 22:00'},
        {'day': 'Thứ 4', 'hours': '09:00 - 22:00'},
        {'day': 'Thứ 5', 'hours': '09:00 - 22:00'},
        {'day': 'Thứ 6', 'hours': '09:00 - 23:00'},
        {'day': 'Thứ 7', 'hours': '08:00 - 23:00'},
        {'day': 'Chủ nhật', 'hours': '08:00 - 22:00'},
      ];
    }

    if (openingHours is Map) {
      List<Map<String, dynamic>> result = [];
      final days = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];
      final dayNames = [
        'Thứ 2',
        'Thứ 3',
        'Thứ 4',
        'Thứ 5',
        'Thứ 6',
        'Thứ 7',
        'Chủ nhật',
      ];

      for (int i = 0; i < days.length; i++) {
        final dayData = openingHours[days[i]];
        if (dayData is List && dayData.isNotEmpty) {
          final timeSlot = dayData.first;
          if (timeSlot is Map) {
            final open = timeSlot['open'] ?? '09:00';
            final close = timeSlot['close'] ?? '22:00';
            result.add({'day': dayNames[i], 'hours': '$open - $close'});
          }
        } else {
          result.add({'day': dayNames[i], 'hours': '09:00 - 22:00'});
        }
      }
      return result;
    }

    return [];
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekday = now.weekday;

    switch (weekday) {
      case 1:
        return day == 'Thứ 2';
      case 2:
        return day == 'Thứ 3';
      case 3:
        return day == 'Thứ 4';
      case 4:
        return day == 'Thứ 5';
      case 5:
        return day == 'Thứ 6';
      case 6:
        return day == 'Thứ 7';
      case 7:
        return day == 'Chủ nhật';
      default:
        return false;
    }
  }

  // ===== DATA GETTERS =====
  String _getRestaurantName() {
    return _restaurantData?['title']?.toString() ??
        widget.restaurant?['name'] ??
        'restaurants_title'.tr;
  }

  String _getRatingStr() {
    final rating = _restaurantData?['ratingAverage'];
    if (rating is num) return rating.toStringAsFixed(1);
    final s = widget.restaurant?['rating'] ?? '0.0';
    final n = double.tryParse(s) ?? 0.0;
    return n.toStringAsFixed(1);
  }

  double _getRatingVal() {
    final rating = _restaurantData?['ratingAverage'];
    if (rating is num) return rating.toDouble();
    return double.tryParse(widget.restaurant?['rating'] ?? '0.0') ?? 0.0;
  }

  String _getReviewCount() {
    if (_reviews.isNotEmpty) {
      return '(${_reviews.length})';
    }
    return widget.restaurant?['reviews'] ?? '(0)';
  }

  String _getPrice() {
    final price = _restaurantData?['price'];
    final currency = _restaurantData?['currencyCode'];

    if (price is num && currency != null) {
      if (currency.toUpperCase() == 'VND') {
        return '${price.toStringAsFixed(0)} đ';
      }
      return '$price $currency';
    }

    return widget.restaurant?['price'] ?? '';
  }

  String _getImageUrl() {
    final thumbnailUrl = _restaurantData?['thumbnailUrl']?.toString();
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    }
    final imageUrls = _restaurantData?['imageUrls'];
    if (imageUrls is List && imageUrls.isNotEmpty) {
      return imageUrls.first.toString();
    }
    final fallback = widget.restaurant?['image'] ?? '';
    return fallback.startsWith('http') ? fallback : '';
  }

  String _getDescription() {
    final desc = _restaurantData?['serviceDescription']?.toString();
    if (desc != null && desc.isNotEmpty) return desc;

    final name = _getRestaurantName();
    final cuisines = _getActiveCuisines();
    final cuisineText = cuisines.isNotEmpty
        ? cuisines.first.toLowerCase()
        : 'đa dạng';

    return 'restaurant_intro_fallback'.tr
        .replaceFirst('%s', name)
        .replaceFirst('%s', cuisineText);
  }

  String _getAddress() {
    return _restaurantData?['address']?.toString() ??
        _restaurantData?['location']?.toString() ??
        widget.restaurant?['location'] ??
        '';
  }

  Set<String> _getActiveCuisines() {
    final cuisines = _restaurantData?['cuisines'];
    if (cuisines is List) {
      return cuisines.map((e) => e.toString()).toSet();
    }

    if (widget.activeCuisines.isNotEmpty) {
      return widget.activeCuisines;
    }

    final cuisine = widget.restaurant?['cuisine'];
    if (cuisine != null && cuisine.isNotEmpty) {
      return {cuisine};
    }

    return {'cuisine_western'.tr};
  }

  Set<String> _getActiveServices() {
    final services = _restaurantData?['services'];
    if (services is List) {
      return services.map((e) => e.toString()).toSet();
    }

    if (widget.activeServices.isNotEmpty) {
      return widget.activeServices;
    }

    return {'service_dine_in'.tr};
  }

  Set<String> _getActiveDietaries() {
    final diets = _restaurantData?['diets'];
    if (diets is List) {
      return diets.map((e) => e.toString()).toSet();
    }

    return widget.activeDietaries;
  }

  // ===== HERO IMAGE =====
  Widget _heroImage() {
    final imageUrl = _getImageUrl();

    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageFallback(),
                )
              : _imageFallback(),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.image,
                  size: 14,
                  color: context.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '1 / ${_getImageCount()}',
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
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 220,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, size: 48, color: context.primaryColor),
    );
  }

  Widget _mapPlaceholder(BuildContext context) {
    return Container(
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.map, color: context.primaryColor, size: 22),
          const SizedBox(width: 8),
          Text(
            'map_preview'.tr,
            style: context.captionStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  int _getImageCount() {
    final imageUrls = _restaurantData?['imageUrls'];
    if (imageUrls is List) return imageUrls.length;
    return 1; // Default fallback
  }

  // ===== HEADER INFO =====
  Widget _headerInfo(BuildContext context) {
    final ratingVal = _getRatingVal();
    final ratingStr = _getRatingStr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getRestaurantName(),
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, ratingVal),
            const SizedBox(width: 6),
            Text(
              '($ratingStr)',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_getReviewCount().replaceAll(RegExp(r"[()]"), "")} ${'reviews'.tr}',
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
            if (_hasWebsite()) _inlineAction(context, 'visit_website'.tr),
            if (_hasPhone()) _inlineAction(context, 'call_to_book'.tr),
            _inlineAction(context, 'write_review'.tr),
            _inlineAction(context, 'get_directions'.tr),
          ],
        ),
      ],
    );
  }

  bool _hasWebsite() {
    final website = _restaurantData?['website']?.toString();
    return website != null && website.isNotEmpty;
  }

  bool _hasPhone() {
    final phone = _restaurantData?['phone']?.toString();
    return phone != null && phone.isNotEmpty;
  }

  // ===== QUICK META (DATE / GUEST) =====
  Widget _quickMeta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: 'date'.tr,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.users,
            label: '2 ${'guests_short'.tr}',
          ),
        ),
      ],
    );
  }

  // ===== PRICE AND ACTION =====
  Widget _priceAndAction(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'price_from'.tr,
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getPrice(),
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
            child: Text(
              'book_table'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
            expanded ? 'read_less'.tr : 'read_more'.tr,
            style: context.bodyTwoStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===== FEATURES BLOCK =====
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
                      ? 'read_less'.tr
                      : '${'view_more'.tr} ${features.length - initiallyVisible}',
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
    final rating = _getRatingVal();

    final ratingData = _generateRatingAspects();

    return Column(
      children: [
        Row(
          children: [
            Text(
              rating.toStringAsFixed(1),
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
                  _starsRow(context, rating),
                  const SizedBox(height: 4),
                  Text(
                    '${'based_on'.tr} ${_reviews.length} ${'reviews'.tr}',
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.primaryColor,
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
              'write_review'.tr,
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

  List<Map<String, dynamic>> _generateRatingAspects() {
    if (_reviews.isNotEmpty) {
      double totalQuality = 0,
          totalService = 0,
          totalPrice = 0,
          totalLocation = 0,
          totalAmbience = 0;
      int count = 0;

      for (final review in _reviews) {
        final aspects = review['aspects'];
        if (aspects is Map) {
          totalQuality += (aspects['quality'] ?? 4).toDouble();
          totalService += (aspects['service'] ?? 4).toDouble();
          totalPrice += (aspects['price'] ?? 4).toDouble();
          totalLocation += (aspects['location'] ?? 4).toDouble();
          totalAmbience += (aspects['ambience'] ?? 4).toDouble();
          count++;
        }
      }

      if (count > 0) {
        return [
          {'label': 'aspect_quality'.tr, 'value': (totalQuality / count) / 5},
          {'label': 'aspect_service'.tr, 'value': (totalService / count) / 5},
          {'label': 'aspect_price'.tr, 'value': (totalPrice / count) / 5},
          {'label': 'aspect_location'.tr, 'value': (totalLocation / count) / 5},
          {'label': 'aspect_ambience'.tr, 'value': (totalAmbience / count) / 5},
        ];
      }
    }

    // Fallback to default values
    return [
      {'label': 'aspect_quality'.tr, 'value': 0.85},
      {'label': 'aspect_service'.tr, 'value': 0.92},
      {'label': 'aspect_price'.tr, 'value': 0.78},
      {'label': 'aspect_location'.tr, 'value': 0.88},
      {'label': 'aspect_ambience'.tr, 'value': 0.90},
    ];
  }

  // ===== REVIEW CARD =====
  Widget _reviewCard(BuildContext context, Map<String, dynamic> review) {
    final userName =
        review['user']?['fullName']?.toString() ??
        review['user']?['username']?.toString() ??
        review['userName']?.toString() ??
        'user'.tr;

    final rating = (review['rating'] is num)
        ? (review['rating'] as num).toDouble()
        : 5.0;
    final content = review['content']?.toString() ?? '';
    final createdAt = review['createdAt']?.toString() ?? '';
    final date = _formatDate(createdAt);

    // Check for replies
    final replyCount = review['replyCount'] ?? 0;
    final hasReply = replyCount > 0;

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
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: context.bodyTwoStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _starsRow(context, rating),
                        const SizedBox(width: 8),
                        Text(
                          date,
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
          Text(content, style: context.bodyTwoStyle.copyWith(height: 1.4)),
          if (hasReply)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _managerReply(context, 'manager_reply_thanks'.tr),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // ===== MANAGER REPLY =====
  Widget _managerReply(BuildContext context, String text) {
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
              Icon(
                LucideIcons.award,
                size: 16,
                color: context.textSecondaryColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'restaurant_manager'.tr,
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

  // ===== STARS ROW
  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        final isFull = rating >= starIndex - 0.25;
        final isHalf = !isFull && rating >= starIndex - 0.75;
        return Icon(
          isFull
              ? Icons.star_rounded
              : isHalf
              ? Icons.star_half_rounded
              : Icons.star_border_rounded,
          color: context.primaryColor,
          size: 16,
        );
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
