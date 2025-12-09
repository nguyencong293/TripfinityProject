import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';

import 'package:app/services/search_api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/localization_service.dart';

class RestaurantOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;
  const RestaurantOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<RestaurantOverviewSearchScreen> createState() =>
      _RestaurantOverviewSearchScreenState();
}

class _RestaurantOverviewSearchScreenState
    extends State<RestaurantOverviewSearchScreen> {
  static const double _minPrice = 0;
  static const double _maxPrice = 10000000;
  // static const RangeValues _defaultPrice = RangeValues(0, 10000000);
  RangeValues _priceRange = const RangeValues(0, 10000000);

  final Set<String> _cuisines = {};
  final Set<String> _services = {};
  final Set<String> _dietaries = {};
  final Set<int> _selectedStars = {};
  bool _openNow = false;
  bool _reservation = false;
  bool _takeAway = false;
  bool _inStockOnly = false;

  List<_TagOption> get _cuisineCatalog => [
    _TagOption('cuisine_vietnamese'.tr, LucideIcons.wine),
    _TagOption('cuisine_seafood'.tr, LucideIcons.fish),
    _TagOption('cuisine_western'.tr, LucideIcons.wine),
    _TagOption('cuisine_korean'.tr, LucideIcons.wine),
    _TagOption('cuisine_japanese'.tr, LucideIcons.wine),
    _TagOption('cuisine_thai'.tr, LucideIcons.eggFried),
    _TagOption('cuisine_chinese'.tr, LucideIcons.wine),
    _TagOption('cuisine_vegan'.tr, LucideIcons.leaf),
    _TagOption('cuisine_grill'.tr, LucideIcons.flame),
    _TagOption('cuisine_coffee'.tr, LucideIcons.coffee),
  ];

  List<_TagOption> get _serviceCatalog => [
    _TagOption('service_dine_in'.tr, LucideIcons.utensils),
    _TagOption('service_take_away'.tr, LucideIcons.shoppingBag),
    _TagOption('service_delivery'.tr, LucideIcons.bike),
    _TagOption('service_bar'.tr, LucideIcons.beer),
    _TagOption('service_garden'.tr, LucideIcons.treePine),
    _TagOption('service_private_room'.tr, LucideIcons.doorClosed),
  ];

  List<_TagOption> get _dietaryCatalog => [
    _TagOption('dietary_vegan'.tr, LucideIcons.leaf),
    _TagOption('dietary_halal'.tr, LucideIcons.badgeCheck),
    _TagOption('dietary_gluten_free'.tr, LucideIcons.wheatOff),
    _TagOption('dietary_low_calorie'.tr, LucideIcons.scale),
    _TagOption('dietary_dairy_free'.tr, LucideIcons.milkOff),
  ];

  List<Map<String, String>> _allRestaurants = [];
  List<Map<String, String>> _restaurants = [];

  bool _loading = false;
  String? _error;
  bool _filterApplied = false; // Track if user has applied filter

  bool get _hasAnyFilterApplied {
    return _filterApplied;
  }

  void _navigateToRestaurantDetail(Map<String, String> restaurant) {
    final idStr =
        restaurant['restaurantId'] ??
        restaurant['id'] ??
        restaurant['restaurant_id'];
    final parsedId = idStr != null ? int.tryParse(idStr) : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurantId: parsedId,
          restaurant: restaurant,
          activeCuisines: _cuisines,
          activeServices: _services,
          activeDietaries: _dietaries,
          activeStars: _selectedStars,
          activeOpenNow: _openNow,
          activeReservation: _reservation,
          activeTakeAway: _takeAway,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchRestaurants(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.searchQuery.isEmpty
              ? 'restaurants_title'.tr
              : widget.searchQuery,
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildTopChips(context),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  )
                : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            color: context.errorColor,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: context.bodyOneStyle.copyWith(
                              color: context.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _fetchRestaurants(widget.searchQuery),
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
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _restaurants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final r = _restaurants[index];
                      return _RestaurantCard(
                        imagePath: r['image']!,
                        name: r['name']!,
                        cuisine: r['cuisine']!,
                        price: r['price']!,
                        rating: r['rating']!,
                        reviews: r['reviews']!,
                        tag: r['tag']!,
                        onCardTap: () => _navigateToRestaurantDetail(r),
                        onViewPressed: () => _navigateToRestaurantDetail(r),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.utensils,
            label: 'restaurants'.tr,
            selected: true,
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.slidersHorizontal,
            label: 'filter'.tr,
            selected: _hasAnyFilterApplied,
            onTap: () => _openFilterSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    RangeValues price = _priceRange;
    final cuisines = Set<String>.from(_cuisines);
    final services = Set<String>.from(_services);
    final dietaries = Set<String>.from(_dietaries);
    final stars = Set<int>.from(_selectedStars);
    bool openNow = _openNow;
    bool reservation = _reservation;
    bool takeAway = _takeAway;
    bool stock = _inStockOnly;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.92,
            minChildSize: 0.5,
            maxChildSize: 0.96,
            expand: false,
            builder: (context, controller) {
              return StatefulBuilder(
                builder: (ctx, setSheet) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      controller: controller,
                      shrinkWrap: true,
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.dividerColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'restaurant_filter_title'.tr,
                                style: context.subTitleOneStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setSheet(() {
                                  price = const RangeValues(0, 10000000);
                                  cuisines.clear();
                                  services.clear();
                                  dietaries.clear();
                                  stars.clear();
                                  openNow = false;
                                  reservation = false;
                                  takeAway = false;
                                  stock = false;
                                });
                                // Reset filter và hiển thị tất cả
                                setState(() {
                                  _priceRange = const RangeValues(0, 10000000);
                                  _cuisines.clear();
                                  _services.clear();
                                  _dietaries.clear();
                                  _selectedStars.clear();
                                  _openNow = false;
                                  _reservation = false;
                                  _takeAway = false;
                                  _inStockOnly = false;
                                  _filterApplied = false;
                                  _restaurants = List.from(_allRestaurants);
                                });
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'reset'.tr,
                                style: context.captionStyle.copyWith(
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Giá
                        _sectionTitle(
                          ctx,
                          LucideIcons.wallet,
                          'price_per_person'.tr,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _priceTag(ctx, _formatCurrency(price.start)),
                            _priceTag(ctx, _formatCurrency(price.end)),
                          ],
                        ),
                        RangeSlider(
                          values: price,
                          onChanged: (v) =>
                              setSheet(() => price = _normalizeRange(v)),
                          min: _minPrice,
                          max: _maxPrice,
                          divisions: 100,
                          activeColor: context.primaryColor,
                          labels: RangeLabels(
                            _formatCurrency(price.start),
                            _formatCurrency(price.end),
                          ),
                        ),

                        const SizedBox(height: 16),
                        _sectionTitle(
                          ctx,
                          LucideIcons.utensilsCrossed,
                          'cuisines'.tr,
                        ),
                        const SizedBox(height: 8),
                        _wrapOptions(
                          ctx,
                          _cuisineCatalog,
                          cuisines,
                          setSheet,
                          maxWidth: 140,
                        ),

                        const SizedBox(height: 16),
                        _sectionTitle(
                          ctx,
                          LucideIcons.briefcase,
                          'services'.tr,
                        ),
                        const SizedBox(height: 8),
                        _wrapOptions(
                          ctx,
                          _serviceCatalog,
                          services,
                          setSheet,
                          maxWidth: 170,
                        ),

                        const SizedBox(height: 16),
                        _sectionTitle(ctx, LucideIcons.leaf, 'dietaries'.tr),
                        const SizedBox(height: 8),
                        _wrapOptions(
                          ctx,
                          _dietaryCatalog,
                          dietaries,
                          setSheet,
                          maxWidth: 170,
                        ),

                        const SizedBox(height: 16),
                        _sectionTitle(ctx, LucideIcons.star, 'star_rating'.tr),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(5, (i) {
                            final star = i + 1;
                            final sel = stars.contains(star);
                            return FilterChip(
                              selected: sel,
                              showCheckmark: false,
                              label: Text(
                                '$star★',
                                style: context.bodyTwoStyle.copyWith(
                                  color: sel
                                      ? context.buttonTextColor
                                      : context.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: context.cardBackgroundColor,
                              selectedColor: context.primaryColor,
                              side: BorderSide(
                                color: sel
                                    ? context.primaryColor
                                    : context.dividerColor,
                              ),
                              onSelected: (_) => setSheet(() {
                                sel ? stars.remove(star) : stars.add(star);
                              }),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),
                        _sectionTitle(
                          ctx,
                          LucideIcons.settings2,
                          'more_options'.tr,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _toggleChip(
                              ctx,
                              'open_now'.tr,
                              openNow,
                              (v) => setSheet(() => openNow = v),
                            ),
                            _toggleChip(
                              ctx,
                              'reservation'.tr,
                              reservation,
                              (v) => setSheet(() => reservation = v),
                            ),
                            _toggleChip(
                              ctx,
                              'take_away'.tr,
                              takeAway,
                              (v) => setSheet(() => takeAway = v),
                            ),
                            _toggleChip(
                              ctx,
                              'in_stock_only'.tr,
                              stock,
                              (v) => setSheet(() => stock = v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.textPrimaryColor,
                                  side: BorderSide(color: context.dividerColor),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text('cancel'.tr),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _priceRange = price;
                                    _cuisines
                                      ..clear()
                                      ..addAll(cuisines);
                                    _services
                                      ..clear()
                                      ..addAll(services);
                                    _dietaries
                                      ..clear()
                                      ..addAll(dietaries);
                                    _selectedStars
                                      ..clear()
                                      ..addAll(stars);
                                    _openNow = openNow;
                                    _reservation = reservation;
                                    _takeAway = takeAway;
                                    _inStockOnly = stock;
                                    _filterApplied =
                                        true; // Mark filter as applied
                                  });
                                  _applyFilters();
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: context.buttonTextColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text('apply'.tr),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Helpers
  Widget _sectionTitle(BuildContext ctx, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.textSecondaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _priceTag(BuildContext ctx, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor),
      ),
      child: Text(
        text,
        style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _wrapOptions(
    BuildContext ctx,
    List<_TagOption> list,
    Set<String> selected,
    void Function(void Function()) setSheet, {
    double maxWidth = 140,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: list.map((o) {
          final sel = selected.contains(o.label);
          return FilterChip(
            selected: sel,
            showCheckmark: false,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  o.icon,
                  size: 16,
                  color: sel
                      ? context.buttonTextColor
                      : context.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Text(
                    o.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyTwoStyle.copyWith(
                      color: sel
                          ? context.buttonTextColor
                          : context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.cardBackgroundColor,
            selectedColor: context.primaryColor,
            side: BorderSide(
              color: sel ? context.primaryColor : context.dividerColor,
            ),
            onSelected: (_) => setSheet(() {
              sel ? selected.remove(o.label) : selected.add(o.label);
            }),
          );
        }).toList(),
      ),
    );
  }

  RangeValues _normalizeRange(RangeValues v) {
    if (v.end - v.start < 10000) {
      final mid = (v.start + v.end) / 2;
      return RangeValues(mid - 5000, mid + 5000);
    }
    return v;
  }

  String _formatCurrency(double value) {
    final intVal = value.round();
    final s = intVal.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      buf.write(s[idx]);
      if ((i + 1) % 3 == 0 && idx != 0) buf.write('.');
    }
    final rev = buf.toString().split('').reversed.join();
    return '$rev đ';
  }

  Widget _toggleChip(
    BuildContext ctx,
    String label,
    bool selected,
    ValueChanged<bool> onTap,
  ) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyTwoStyle.copyWith(
          color: selected
              ? context.buttonTextColor
              : context.textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: context.cardBackgroundColor,
      selectedColor: context.primaryColor,
      side: BorderSide(
        color: selected ? context.primaryColor : context.dividerColor,
      ),
      onSelected: (_) => onTap(!selected),
    );
  }

  Widget _pill(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final bg = selected ? context.primaryColor : context.cardBackgroundColor;
    final fg = selected ? context.buttonTextColor : context.textSecondaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? context.primaryColor : context.dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyTwoStyle.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Dynamic fetch + mapping
  Future<void> _fetchRestaurants(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _restaurants = [];
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);
      final data = await api.search(q: query);

      List<Map<String, String>> items = [];
      if (data['restaurants'] is List) {
        items = List.from(data['restaurants']).map<Map<String, String>>((e) {
          final m = Map<String, dynamic>.from(e);

          final rating = _getRatingString(
            m['rating'] ??
                m['rating_average'] ??
                m['ratingAverage'] ??
                m['ratingAvg'] ??
                m['avg_rating'],
          );
          final reviewsRaw =
              m['reviews'] ??
              m['reviewCount'] ??
              m['reviews_count'] ??
              m['totalReviews'] ??
              m['rating_count'] ??
              m['total_ratings'] ??
              0;

          // Giá
          final priceStr = _formatPrice(m['price'], m['currencyCode']);

          final imageUrl =
              m['imageUrl']?.toString() ??
              m['thumbnailUrl']?.toString() ??
              m['image']?.toString() ??
              '';
          final image = imageUrl.startsWith('http') ? imageUrl : '';

          final cuisine =
              m['cuisine']?.toString() ??
              m['category']?.toString() ??
              'cuisine_western'.tr;
          final tag =
              m['tag']?.toString() ??
              (m['services'] is List && (m['services'] as List).isNotEmpty
                  ? (m['services'] as List).first.toString()
                  : 'service_dine_in'.tr);

          return {
            'restaurantId':
                m['restaurantId']?.toString() ?? m['id']?.toString() ?? '',
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'cuisine': cuisine,
            'price': priceStr,
            'rating': rating,
            'reviews': '(${reviewsRaw.toString()})',
            'image': image,
            'tag': tag,
          };
        }).toList();
      }

      setState(() {
        _allRestaurants = items;
        _restaurants = items; // Hiển thị tất cả ban đầu
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'error_load_restaurants'.tr;
      });
    }
  }

  void _applyFilters() {
    // Nếu chưa apply filter, hiển thị tất cả
    if (!_filterApplied) {
      setState(() {
        _restaurants = List.from(_allRestaurants);
      });
      return;
    }

    List<Map<String, String>> filtered = List.from(_allRestaurants);

    // Lọc theo giá (luôn áp dụng khi _filterApplied = true)
    filtered = filtered.where((r) {
      final priceStr = r['price'] ?? '';
      // Extract số từ string như "50.000 đ"
      final numStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(numStr) ?? 0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Lọc theo cuisines (nếu có chọn)
    if (_cuisines.isNotEmpty) {
      filtered = filtered.where((r) {
        final cuisine = r['cuisine']?.toLowerCase() ?? '';
        return _cuisines.any((c) => cuisine.contains(c.toLowerCase()));
      }).toList();
    }

    // Lọc theo services (nếu có chọn)
    if (_services.isNotEmpty) {
      filtered = filtered.where((r) {
        final tag = r['tag']?.toLowerCase() ?? '';
        return _services.any((s) => tag.contains(s.toLowerCase()));
      }).toList();
    }

    // Lọc theo rating stars (nếu có chọn)
    if (_selectedStars.isNotEmpty) {
      filtered = filtered.where((r) {
        final rating = double.tryParse(r['rating'] ?? '0') ?? 0;
        final roundedRating = rating.round();
        return _selectedStars.contains(roundedRating);
      }).toList();
    }

    setState(() {
      _restaurants = filtered;
    });
  }

  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is String) return rating;
    if (rating is num) return rating.toString();
    return '0.0';
  }

  String _formatPrice(dynamic price, dynamic currencyCode) {
    if (price == null) return '';
    num? n;
    if (price is num) {
      n = price;
    } else {
      n = num.tryParse(price.toString());
    }
    if (n == null) return price.toString();
    final c = (currencyCode?.toString() ?? '').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') {
      return '${n.toStringAsFixed(0)} đ';
    }
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }
}

class _TagOption {
  final String label;
  final IconData icon;
  const _TagOption(this.label, this.icon);
}

class _RestaurantCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String cuisine;
  final String price;
  final String rating;
  final String reviews;
  final String tag;
  final VoidCallback onCardTap;
  final VoidCallback onViewPressed;

  const _RestaurantCard({
    required this.imagePath,
    required this.name,
    required this.cuisine,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.onCardTap,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');
    final rv = double.tryParse(rating) ?? 0.0;

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: isNetwork
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgFallback(context),
                          )
                        : _imgFallback(context),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: context.cardBackgroundColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Icon(
                      LucideIcons.heart,
                      size: 18,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                name,
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Stars + (x.x) + reviews
                  _starsRow(context, rv),
                  const SizedBox(width: 6),
                  Text(
                    '(${rv.toStringAsFixed(1)})',
                    style: context.captionStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [_miniTag(context, cuisine), _miniTag(context, tag)],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    'price_from'.tr,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    price,
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: onViewPressed,
                  child: Text('view_restaurant'.tr, style: context.buttonStyle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          size: 14,
        );
      }),
    );
  }

  Widget _miniTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: context.captionStyle.copyWith(
          color: context.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _imgFallback(BuildContext context) {
    return Container(
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor, size: 34),
    );
  }
}
