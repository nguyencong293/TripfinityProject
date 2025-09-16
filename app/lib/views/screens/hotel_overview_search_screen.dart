import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

// New: API
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/search_api_service.dart';

class HotelOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;

  const HotelOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<HotelOverviewSearchScreen> createState() =>
      _HotelOverviewSearchScreenState();
}

class _HotelOverviewSearchScreenState extends State<HotelOverviewSearchScreen> {
  // Top chips (date/guests are simple UI toggles for now)
  bool _hasDate = true;
  bool _hasGuests = true;

  // Filter state (demo-only, not filtering the list yet)
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
    _Amenity('Wifi miễn phí', LucideIcons.wifi),
    _Amenity('Bể bơi', LucideIcons.wifi),
    _Amenity('Spa', LucideIcons.wifi),
    _Amenity('Gym', LucideIcons.dumbbell),
    _Amenity('Đưa đón sân bay', LucideIcons.plane),
    _Amenity('Bãi biển riêng', LucideIcons.umbrella),
    _Amenity('Đỗ xe miễn phí', LucideIcons.parkingCircle),
    _Amenity('Nhà hàng', LucideIcons.chefHat),
    _Amenity('Bar', LucideIcons.wine),
    _Amenity('Lễ tân 24/7', LucideIcons.clock),
    _Amenity('Phòng gia đình', LucideIcons.users),
    _Amenity('Thân thiện thú cưng', LucideIcons.wifi),
    _Amenity('Tiếp cận xe lăn', LucideIcons.accessibility),
    _Amenity('Không hút thuốc', LucideIcons.wifi),
    _Amenity('Điều hòa', LucideIcons.snowflake),
    _Amenity('Room service', LucideIcons.conciergeBell),
    _Amenity('Máy giặt/giặt ủi', LucideIcons.wifi),
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
          widget.searchQuery.isEmpty ? 'Khách sạn' : widget.searchQuery,
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
            style: context.bodyOneStyle.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_hotels.isEmpty) {
      return Center(
        child: Text(
          'Không có khách sạn phù hợp',
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
          final imageAsset = 'assets/images/onboarding${(index % 4) + 1}.png';

          return _HotelCard(
            imageUrl: imageUrl,
            fallbackAsset: imageAsset,
            name: name,
            rating: rating,
            reviews: reviews,
            price: price,
            onViewPressed: () => _openHotelDetail({
              'name': name,
              'rating': rating,
              'reviews': reviews,
              'price': price,
              'image': imageUrl?.isNotEmpty == true ? imageUrl! : imageAsset,
            }),
          );
        },
      ),
    );
  }

  Future<void> _fetchHotels(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      // Chỉ lấy khách sạn để tối ưu
      final data = await api.search(q: query, type: 'hotel');

      List<Map<String, dynamic>> hotels = [];
      if (data['hotels'] is List) {
        hotels = List.from(data['hotels']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            // 'reviews': m['reviewsCount']?.toString(), // nếu backend bổ sung
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
        _error = 'Không thể tải khách sạn. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
  }

  void _openHotelDetail(Map<String, String> hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(hotel: hotel),
      ),
    );
  }

  // Top chips row: Khách sạn | Ngày | Khách | Bộ lọc (price moved inside the sheet)
  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.hotel,
            label: 'Khách sạn',
            selected: true,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: _hasDate ? LucideIcons.calendarDays : LucideIcons.calendar,
            label: _hasDate ? '11 thg 6 → 12' : 'Ngày',
            onTap: () => setState(() => _hasDate = !_hasDate),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.bedDouble,
            label: _hasGuests ? '1  ·  2' : 'Khách',
            onTap: () => setState(() => _hasGuests = !_hasGuests),
          ),
          const SizedBox(width: 8),
          // Filter as a pill, selected when any filter is applied
          _pill(
            context,
            icon: LucideIcons.slidersHorizontal,
            label: 'Bộ lọc',
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

  // Bottom sheet with all hotel filters (price + amenities + policies)
  Future<void> _openFilterSheet(BuildContext context) async {
    // Work on a local copy; apply only when pressing "Áp dụng"
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
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              final view = MediaQuery.of(ctx);
              final maxH = view.size.height * 0.9; // cap to 90% height
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: view.viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bộ lọc',
                              style: context.subTitleOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Reset local copy
                              setSheetState(() {
                                price = const RangeValues(_minPrice, _maxPrice);
                                selectedStars.clear();
                                selectedAmenities.clear();
                                freeCancel = false;
                                payAtHotel = false;
                                breakfast = false;
                                inStock = false;
                              });
                            },
                            child: Text(
                              'Đặt lại',
                              style: context.captionStyle.copyWith(
                                color: context.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price section
                      _sectionTitle(
                        ctx,
                        LucideIcons.badgeDollarSign,
                        'Giá mỗi đêm',
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
                        onChanged: (v) =>
                            setSheetState(() => price = _normalizeRange(v)),
                      ),

                      const SizedBox(height: 12),

                      // Star rating
                      _sectionTitle(ctx, Icons.star_rounded, 'Hạng sao'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          final selected = selectedStars.contains(star);
                          return FilterChip(
                            selected: selected,
                            showCheckmark: false,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  star,
                                  (idx) => Padding(
                                    padding: const EdgeInsets.only(right: 1),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$star sao',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.bodyTwoStyle,
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
                      _sectionTitle(ctx, LucideIcons.sofa, 'Tiện ích'),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _amenityCatalog.map((a) {
                            final selected = selectedAmenities.contains(a.name);
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
                                      a.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.bodyTwoStyle.copyWith(
                                        color: selected
                                            ? context.buttonTextColor
                                            : context.textSecondaryColor,
                                      ),
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
                      _sectionTitle(ctx, LucideIcons.checkCircle2, 'Tùy chọn'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _toggleChip(
                            ctx,
                            'Miễn phí huỷ',
                            _freeCancellation,
                            (v) => setSheetState(() => _freeCancellation = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Thanh toán tại nơi',
                            _payAtHotel,
                            (v) => setSheetState(() => _payAtHotel = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Bao gồm bữa sáng',
                            _breakfastIncluded,
                            (v) => setSheetState(() => _breakfastIncluded = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Chỉ hiển thị còn phòng',
                            _inStockOnly,
                            (v) => setSheetState(() => _inStockOnly = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Apply / Cancel
                      Row(
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
                              child: const Text('Hủy'),
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
                                // Commit local copy to screen state (demo-only)
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
                                    content: const Text('Đã áp dụng bộ lọc'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Áp dụng'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // UI helpers
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
      // keep a minimal gap so labels don't overlap
      final mid = (v.start + v.end) / 2;
      return RangeValues(mid - 50000, mid + 50000);
    }
    return v;
  }

  String _formatCurrency(double value) {
    // Very light Vietnamese currency formatter for demo: 1.234.567 đ
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
  final String name;
  final IconData icon;
  const _Amenity(this.name, this.icon);
}

class _HotelCard extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final String name;
  final String rating;
  final String reviews;
  final String price;
  final VoidCallback onViewPressed;

  const _HotelCard({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetwork = (imageUrl ?? '').startsWith('http');

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
                child: hasNetwork
                    ? Image.network(
                        imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(context),
                      )
                    : Image.asset(
                        fallbackAsset,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(context),
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
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: context.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: context.captionStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < 3 ? Icons.star_rounded : Icons.star_border_rounded,
                      color: context.primaryColor,
                      size: 14,
                    ),
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
                  'Giá từ:',
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
                child: Text('Xem khách sạn', style: context.buttonStyle),
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
}
