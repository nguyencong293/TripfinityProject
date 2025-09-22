import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/search_api_service.dart';
import 'package:app/services/localization_service.dart';

class HotelOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;

  const HotelOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<HotelOverviewSearchScreen> createState() =>
      _HotelOverviewSearchScreenState();
}

class _HotelOverviewSearchScreenState extends State<HotelOverviewSearchScreen> {
  bool _hasDate = true;
  bool _hasGuests = true;

  RangeValues _priceRange = const RangeValues(800000, 3500000);
  static const double _minPrice = 0;
  static const double _maxPrice = 10000000;

  final Set<int> _selectedStars = {}; // 1..5
  final Set<String> _selectedAmenities = <String>{};
  bool _freeCancellation = false;
  bool _payAtHotel = false;
  bool _breakfastIncluded = false;
  bool _inStockOnly = false;

  final List<_Amenity> _amenityCatalog = const [
    _Amenity('amenity_wifi', LucideIcons.wifi),
    _Amenity('amenity_pool', LucideIcons.wifi),
    _Amenity('amenity_spa', LucideIcons.wifi),
    _Amenity('amenity_gym', LucideIcons.dumbbell),
    _Amenity('amenity_airport_transfer', LucideIcons.plane),
    _Amenity('amenity_private_beach', LucideIcons.umbrella),
    _Amenity('amenity_free_parking', LucideIcons.parkingCircle),
    _Amenity('amenity_restaurant', LucideIcons.chefHat),
    _Amenity('amenity_bar', LucideIcons.wine),
    _Amenity('amenity_reception_24_7', LucideIcons.clock),
    _Amenity('amenity_family_room', LucideIcons.users),
    _Amenity('amenity_pet_friendly', LucideIcons.wifi),
    _Amenity('amenity_wheelchair_access', LucideIcons.accessibility),
    _Amenity('amenity_non_smoking', LucideIcons.wifi),
    _Amenity('amenity_air_conditioning', LucideIcons.snowflake),
    _Amenity('amenity_room_service', LucideIcons.conciergeBell),
    _Amenity('amenity_laundry', LucideIcons.wifi),
  ];

  // Dynamic data from API
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _hotels = [];

  @override
  void initState() {
    super.initState();
    _fetchHotels(widget.searchQuery);
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
          widget.searchQuery.isEmpty ? 'hotels_title'.tr : widget.searchQuery,
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.primaryColor,
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            style: context.bodyOneStyle.copyWith(color: context.errorColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_hotels.isEmpty) {
      return Center(
        child: Text(
          'no_results'.tr,
          style: context.captionStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () => _fetchHotels(widget.searchQuery),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _hotels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final h = _hotels[index];
          final name = h['name']?.toString() ?? '';
          final rating = _getRatingString(h['rating']);
          final reviews =
              h['reviews']?.toString() ?? ''; // backend chưa có -> rỗng
          final price = h['price']?.toString() ?? '';
          final imageUrl = h['imageUrl']?.toString();

          return _HotelCard(
            imageUrl: imageUrl,
            name: name,
            rating: rating,
            reviews: reviews,
            price: price,
            onViewPressed: () =>
                _openHotelDetail(h), // pass full map with hotelId
          );
        },
      ),
    );
  }

  void _openHotelDetail(Map<String, dynamic> h) {
    final int? id = _tryParseInt(h['hotelId']);
    final fallback = <String, String>{
      'name': (h['name'] ?? '').toString(),
      'rating': _getRatingString(h['rating']),
      'reviews': '',
      'price': (h['price'] ?? '').toString(),
      'image': (h['imageUrl'] ?? '').toString(),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id,
          hotel: fallback,
          activeAmenities: _selectedAmenities,
        ),
      ),
    );
  }

  int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<void> _fetchHotels(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query, type: 'hotel');

      List<Map<String, dynamic>> hotels = [];
      if (data['hotels'] is List) {
        hotels = List.from(data['hotels']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);

          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          final ratingAvg = m['ratingAverage'];

          return {
            'hotelId': m['hotelId'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': ratingAvg,
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
          };
        }).toList();
      }

      setState(() {
        _hotels = hotels;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'error_load_hotels'.tr;
      });
    }
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.hotel,
            label: 'cat_hotels'.tr,
            selected: true,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: _hasDate ? LucideIcons.calendarDays : LucideIcons.calendar,
            label: _hasDate ? '11 thg 6 → 12' : 'date'.tr,
            onTap: () => setState(() => _hasDate = !_hasDate),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.bedDouble,
            label: _hasGuests ? '1  ·  2' : 'guests'.tr,
            onTap: () => setState(() => _hasGuests = !_hasGuests),
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

  bool get _hasAnyFilterApplied {
    return _selectedStars.isNotEmpty ||
        _selectedAmenities.isNotEmpty ||
        _freeCancellation ||
        _payAtHotel ||
        _breakfastIncluded ||
        _inStockOnly ||
        _priceRange.start > _minPrice ||
        _priceRange.end < _maxPrice;
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    RangeValues price = _priceRange;
    final selectedStars = Set<int>.from(_selectedStars);
    final selectedAmenities = Set<String>.from(_selectedAmenities);
    bool freeCancel = _freeCancellation;
    bool payAtHotel = _payAtHotel;
    bool breakfast = _breakfastIncluded;
    bool inStock = _inStockOnly;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return SafeArea(
              child: StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                          border: Border(
                            bottom: BorderSide(color: context.dividerColor),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: context.textDisabledColor.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'filter'.tr,
                                    style: context.subTitleOneStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      price = const RangeValues(
                                        _minPrice,
                                        _maxPrice,
                                      );
                                      selectedStars.clear();
                                      selectedAmenities.clear();
                                      freeCancel = false;
                                      payAtHotel = false;
                                      breakfast = false;
                                      inStock = false;
                                    });
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
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          children: [
                            _sectionTitle(
                              ctx,
                              LucideIcons.badgeDollarSign,
                              'price_per_night'.tr,
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
                              min: _minPrice,
                              max: _maxPrice,
                              divisions: 20,
                              activeColor: context.primaryColor,
                              labels: RangeLabels(
                                _formatCurrency(price.start),
                                _formatCurrency(price.end),
                              ),
                              onChanged: (v) => setSheetState(
                                () => price = _normalizeRange(v),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Star rating
                            _sectionTitle(
                              ctx,
                              Icons.star_rounded,
                              'star_class'.tr,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(5, (i) {
                                final star = i + 1;
                                final selected = selectedStars.contains(star);
                                final iconColor = selected
                                    ? context.buttonTextColor
                                    : context.primaryColor;
                                final textColor = selected
                                    ? context.buttonTextColor
                                    : context.textSecondaryColor;

                                return FilterChip(
                                  selected: selected,
                                  showCheckmark: false,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...List.generate(
                                        star,
                                        (idx) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 1,
                                          ),
                                          child: Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color:
                                                iconColor, // selected -> white, else primary
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$star ${'stars'.tr}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.bodyTwoStyle.copyWith(
                                          color:
                                              textColor, // selected -> white, else secondary
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: context.cardBackgroundColor,
                                  selectedColor: context.primaryColor,
                                  side: BorderSide(
                                    color: selected
                                        ? context.primaryColor
                                        : context.dividerColor,
                                  ),
                                  onSelected: (_) {
                                    setSheetState(() {
                                      if (selected) {
                                        selectedStars.remove(star);
                                      } else {
                                        selectedStars.add(star);
                                      }
                                    });
                                  },
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // Amenities
                            _sectionTitle(
                              ctx,
                              LucideIcons.sofa,
                              'amenities'.tr,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _amenityCatalog.map((a) {
                                  final selected = selectedAmenities.contains(
                                    a.name,
                                  );
                                  return FilterChip(
                                    selected: selected,
                                    showCheckmark: false,
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          a.icon,
                                          size: 16,
                                          color: selected
                                              ? context.buttonTextColor
                                              : context.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 160,
                                          ),
                                          child: Text(
                                            a.name.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.bodyTwoStyle
                                                .copyWith(
                                                  color: selected
                                                      ? context.buttonTextColor
                                                      : context
                                                            .textSecondaryColor,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor:
                                        context.cardBackgroundColor,
                                    selectedColor: context.primaryColor,
                                    side: BorderSide(
                                      color: selected
                                          ? context.primaryColor
                                          : context.dividerColor,
                                    ),
                                    onSelected: (_) {
                                      setSheetState(() {
                                        if (selected) {
                                          selectedAmenities.remove(a.name);
                                        } else {
                                          selectedAmenities.add(a.name);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Policies and other toggles
                            _sectionTitle(
                              ctx,
                              LucideIcons.checkCircle2,
                              'options'.tr,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _toggleChip(
                                  ctx,
                                  'free_cancellation'.tr,
                                  _freeCancellation,
                                  (v) => setSheetState(
                                    () => _freeCancellation = v,
                                  ),
                                ),
                                _toggleChip(
                                  ctx,
                                  'pay_at_hotel'.tr,
                                  _payAtHotel,
                                  (v) => setSheetState(() => _payAtHotel = v),
                                ),
                                _toggleChip(
                                  ctx,
                                  'breakfast_included'.tr,
                                  _breakfastIncluded,
                                  (v) => setSheetState(
                                    () => _breakfastIncluded = v,
                                  ),
                                ),
                                _toggleChip(
                                  ctx,
                                  'in_stock_only'.tr,
                                  _inStockOnly,
                                  (v) => setSheetState(() => _inStockOnly = v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.textPrimaryColor,
                                  side: BorderSide(color: context.dividerColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('cancel'.tr),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: context.buttonTextColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _priceRange = price;
                                    _selectedStars
                                      ..clear()
                                      ..addAll(selectedStars);
                                    _selectedAmenities
                                      ..clear()
                                      ..addAll(selectedAmenities);
                                    _freeCancellation = freeCancel;
                                    _payAtHotel = payAtHotel;
                                    _breakfastIncluded = breakfast;
                                    _inStockOnly = inStock;
                                  });
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('filters_applied'.tr),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text('apply'.tr),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

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

  RangeValues _normalizeRange(RangeValues v) {
    if (v.end - v.start < 100000) {
      final mid = (v.start + v.end) / 2;
      return RangeValues(mid - 50000, mid + 50000);
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

  // ===== Utils for API mapping =====
  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is String) return rating;
    if (rating is num) return rating.toString();
    return '0.0';
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
}

class _Amenity {
  final String name; // lang key
  final IconData icon;
  const _Amenity(this.name, this.icon);
}

class _HotelCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String rating;
  final String reviews;
  final String price;
  final VoidCallback onViewPressed;

  const _HotelCard({
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double ratingVal = double.tryParse(rating) ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: (imageUrl != null && imageUrl!.startsWith('http'))
                    ? Image.network(
                        imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(context),
                      )
                    : _imageFallback(context),
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
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _ratingStars(context, ratingVal),
                const SizedBox(width: 6),
                Text(
                  ' (${ratingVal.toStringAsFixed(1)})',
                  style: context.captionStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    reviews,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
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
                child: Text('view_hotel'.tr, style: context.buttonStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  Widget _ratingStars(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        IconData icon;
        if (rating >= idx - 0.25) {
          icon = Icons.star_rounded;
        } else if (rating >= idx - 0.75) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, color: context.primaryColor, size: 14);
      }),
    );
  }
}
