import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

import 'package:app/services/search_api_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/localization_service.dart'; // ADD: lang

class TourServiceOverviewScreen extends StatefulWidget {
  final String searchQuery;
  const TourServiceOverviewScreen({super.key, required this.searchQuery});

  @override
  State<TourServiceOverviewScreen> createState() =>
      _TourServiceOverviewScreenState();
}

class _TourServiceOverviewScreenState extends State<TourServiceOverviewScreen> {
  bool _hasDate = true;
  bool _hasGuests = true;

  static const double _minPrice = 0;
  static const double _maxPrice = 10_000_000;
  RangeValues _priceRange = const RangeValues(500000, 3_500_000);

  static const double _minDays = 1;
  static const double _maxDays = 10;
  RangeValues _durationRange = const RangeValues(1, 5);

  final Set<String> _selectedTourTypes = {};
  final Set<String> _selectedServices = {};
  String? _difficulty;
  bool _freeCancellation = false;
  bool _instantConfirmation = false;
  bool _hotelPickup = false;
  bool _inStockOnly = false;

  // Backend categories from TourDTO categoriesJson
  final List<_TagOption> _tourTypes = const [
    _TagOption('culture', LucideIcons.landmark),
    _TagOption('nature', LucideIcons.treePine),
    _TagOption('adventure', LucideIcons.mountain),
    _TagOption('food', LucideIcons.utensils),
    _TagOption('beach', LucideIcons.umbrella),
    _TagOption('mountain', LucideIcons.mountainSnow),
    _TagOption('city', LucideIcons.building2),
    _TagOption('historical', LucideIcons.bookOpen),
  ];

  // Backend services from TourDTO servicesJson
  final List<_TagOption> _services = const [
    _TagOption('pickup', LucideIcons.mapPin),
    _TagOption('airport_transfer', LucideIcons.planeTakeoff),
    _TagOption('photography', LucideIcons.camera),
    _TagOption('bike_rental', LucideIcons.bike),
    _TagOption('special_meals', LucideIcons.pizza),
  ];

  // Dynamic data fetched from API (replaces static mock list)
  List<Map<String, dynamic>> _tours = [];

  bool _loading = false;
  String? _error;

  bool get _hasAnyFilterApplied {
    return _priceRange.start > _minPrice ||
        _priceRange.end < _maxPrice ||
        _durationRange.start > _minDays ||
        _durationRange.end < _maxDays ||
        _selectedTourTypes.isNotEmpty ||
        _selectedServices.isNotEmpty ||
        _difficulty != null ||
        _freeCancellation ||
        _instantConfirmation ||
        _hotelPickup ||
        _inStockOnly;
  }

  List<Map<String, dynamic>> get _filteredTours {
    return _tours.where((t) {
      final price = (t['basePrice'] as num?)?.toDouble() ?? 0;
      if (price < _priceRange.start || price > _priceRange.end) return false;
      final d = (t['durationDays'] as num?)?.toDouble() ?? 1;
      if (d < _durationRange.start || d > _durationRange.end) return false;
      if (_selectedTourTypes.isNotEmpty &&
          !_selectedTourTypes.contains(t['type'])) {
        return false;
      }
      if (_difficulty != null && t['difficulty'] != _difficulty) return false;
      if (_inStockOnly && t['inStock'] == false) return false;
      if (_freeCancellation && t['freeCancellation'] == false) return false;
      if (_instantConfirmation && t['instantConfirmation'] == false) {
        return false;
      }
      if (_hotelPickup && t['hotelPickup'] == false) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchTours(widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final tours = _filteredTours;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.searchQuery.isEmpty ? 'tours_title'.tr : widget.searchQuery,
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _topChips(context),

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
                            onPressed: () => _fetchTours(widget.searchQuery),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: Text('retry'.tr, style: context.buttonStyle),
                          ),
                        ],
                      ),
                    ),
                  )
                : (tours.isEmpty
                      ? _emptyState(context)
                      : RefreshIndicator(
                          color: context.primaryColor,
                          onRefresh: () => _fetchTours(widget.searchQuery),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: tours.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, i) {
                              final t = tours[i];
                              return InkWell(
                                onTap: () => _openTourDetail(t),
                                borderRadius: BorderRadius.circular(16),
                                child: _TourCard(
                                  imagePath: (t['image'] as String?) ?? '',
                                  name: t['name'] ?? '',
                                  type: t['type'] ?? 'tour_type_city'.tr,
                                  rating: t['rating'] ?? '0.0',
                                  reviews: t['reviews'] ?? '(0)',
                                  price: t['price'] ?? '',
                                  duration: t['duration'] ?? '1 ${'day'.tr}',
                                  onViewPressed: () => _openTourDetail(t),
                                ),
                              );
                            },
                          ),
                        )),
          ),
        ],
      ),
    );
  }

  // Navigation to tour detail
  void _openTourDetail(Map<String, dynamic> tour) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(
          tourId: tour['tourId'] is num
              ? (tour['tourId'] as num).toInt()
              : null,
          tour: tour,
        ),
      ),
    );
  }

  // UI parts
  Widget _topChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.mapPin,
            label: 'cat_tours'.tr,
            selected: true,
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: _hasDate ? LucideIcons.calendarDays : LucideIcons.calendar,
            label: _hasDate ? '11 thg 6 → 15' : 'date'.tr,
            onTap: () => setState(() => _hasDate = !_hasDate),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.users,
            label: _hasGuests ? '2 ${'guests_short'.tr}' : 'guests'.tr,
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 54,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'no_results'.tr,
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'try_relax_filters'.tr,
              textAlign: TextAlign.center,
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _priceRange = const RangeValues(_minPrice, _maxPrice);
                  _durationRange = const RangeValues(_minDays, _maxDays);
                  _selectedTourTypes.clear();
                  _selectedServices.clear();
                  _difficulty = null;
                  _freeCancellation = false;
                  _instantConfirmation = false;
                  _hotelPickup = false;
                  _inStockOnly = false;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryColor),
              ),
              child: Text(
                'reset_filters'.tr,
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

  Future<void> _openFilterSheet(BuildContext context) async {
    RangeValues price = _priceRange;
    RangeValues duration = _durationRange;
    final tourTypes = {..._selectedTourTypes};
    final services = {..._selectedServices};
    String? difficulty = _difficulty;
    bool freeCancel = _freeCancellation;
    bool instantConfirm = _instantConfirmation;
    bool pickup = _hotelPickup;
    bool inStock = _inStockOnly;

    await showModalBottomSheet(
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
                      // Header + drag handle
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
                                    'tour_filter_title'.tr,
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
                                      duration = const RangeValues(
                                        _minDays,
                                        _maxDays,
                                      );
                                      tourTypes.clear();
                                      services.clear();
                                      difficulty = null;
                                      freeCancel = false;
                                      instantConfirm = false;
                                      pickup = false;
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

                      // Content
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          children: [
                            _sectionTitle(
                              ctx,
                              LucideIcons.badgeDollarSign,
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
                              min: _minPrice,
                              max: _maxPrice,
                              divisions: 20,
                              activeColor: context.primaryColor,
                              labels: RangeLabels(
                                _formatCurrency(price.start),
                                _formatCurrency(price.end),
                              ),
                              onChanged: (v) => setSheetState(
                                () => price = _normalizePriceRange(v),
                              ),
                            ),

                            const SizedBox(height: 16),
                            _sectionTitle(
                              ctx,
                              LucideIcons.timer,
                              'duration_days'.tr,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _priceTag(
                                  ctx,
                                  '${duration.start.round()} ${'day'.tr}',
                                ),
                                _priceTag(
                                  ctx,
                                  '${duration.end.round()} ${'day'.tr}',
                                ),
                              ],
                            ),
                            RangeSlider(
                              values: duration,
                              min: _minDays,
                              max: _maxDays,
                              divisions: (_maxDays - _minDays).toInt(),
                              activeColor: context.primaryColor,
                              labels: RangeLabels(
                                '${duration.start.round()}',
                                '${duration.end.round()}',
                              ),
                              onChanged: (v) => setSheetState(
                                () => duration = _normalizeDayRange(v),
                              ),
                            ),

                            const SizedBox(height: 16),
                            _sectionTitle(
                              ctx,
                              LucideIcons.map,
                              'tour_types'.tr,
                            ),
                            const SizedBox(height: 8),
                            _wrapChips(
                              ctx,
                              options: _tourTypes,
                              selected: tourTypes,
                              onToggle: (n) {
                                setSheetState(() {
                                  tourTypes.contains(n)
                                      ? tourTypes.remove(n)
                                      : tourTypes.add(n);
                                });
                              },
                            ),

                            const SizedBox(height: 16),
                            _sectionTitle(
                              ctx,
                              LucideIcons.briefcase,
                              'services'.tr,
                            ),
                            const SizedBox(height: 8),
                            _wrapChips(
                              ctx,
                              options: _services,
                              selected: services,
                              maxLabelWidth: 170,
                              onToggle: (n) {
                                setSheetState(() {
                                  services.contains(n)
                                      ? services.remove(n)
                                      : services.add(n);
                                });
                              },
                            ),

                            const SizedBox(height: 16),
                            _sectionTitle(
                              ctx,
                              LucideIcons.gauge,
                              'difficulty'.tr,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['easy', 'moderate', 'hard'].map((key) {
                                final sel = difficulty == key;
                                return FilterChip(
                                  selected: sel,
                                  showCheckmark: false,
                                  label: Text(
                                    key.tr,
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
                                  onSelected: (_) => setSheetState(() {
                                    difficulty = sel ? null : key;
                                  }),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),
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
                                  freeCancel,
                                  (v) => setSheetState(() => freeCancel = v),
                                ),
                                _toggleChip(
                                  ctx,
                                  'instant_confirmation'.tr,
                                  instantConfirm,
                                  (v) =>
                                      setSheetState(() => instantConfirm = v),
                                ),
                                _toggleChip(
                                  ctx,
                                  'hotel_pickup'.tr,
                                  pickup,
                                  (v) => setSheetState(() => pickup = v),
                                ),
                                _toggleChip(
                                  ctx,
                                  'in_stock_only'.tr,
                                  inStock,
                                  (v) => setSheetState(() => inStock = v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // Footer actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Row(
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                    _durationRange = duration;
                                    _selectedTourTypes
                                      ..clear()
                                      ..addAll(tourTypes);
                                    _selectedServices
                                      ..clear()
                                      ..addAll(services);
                                    _difficulty = difficulty;
                                    _freeCancellation = freeCancel;
                                    _instantConfirmation = instantConfirm;
                                    _hotelPickup = pickup;
                                    _inStockOnly = inStock;
                                  });
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('filters_applied'.tr),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: context.buttonTextColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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

  Widget _wrapChips(
    BuildContext ctx, {
    required List<_TagOption> options,
    required Set<String> selected,
    required void Function(String) onToggle,
    double maxLabelWidth = 140,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((o) {
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
                  constraints: BoxConstraints(maxWidth: maxLabelWidth),
                  child: Text(
                    o.label.tr,
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
            onSelected: (_) => onToggle(o.label),
          );
        }).toList(),
      ),
    );
  }

  RangeValues _normalizePriceRange(RangeValues v) {
    if (v.end - v.start < 100000) {
      final mid = (v.start + v.end) / 2;
      return RangeValues(mid - 50000, mid + 50000);
    }
    return v;
  }

  RangeValues _normalizeDayRange(RangeValues v) {
    final s = v.start.round().toDouble();
    final e = v.end.round().toDouble();
    if (e - s < .5) {
      final mid = (s + e) / 2;
      return RangeValues(
        (mid - .5).clamp(_minDays, _maxDays),
        (mid + .5).clamp(_minDays, _maxDays),
      );
    }
    return RangeValues(s, e);
  }

  String _formatCurrency(double v) {
    final intVal = v.round();
    final s = intVal.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - 1 - i;
      buf.write(s[idx]);
      if ((i + 1) % 3 == 0 && idx != 0) buf.write('.');
    }
    return '${buf.toString().split('').reversed.join()} đ';
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

  // ===== API and mapping =====
  Future<void> _fetchTours(String query) async {
    setState(() {
      _loading = true;
      _error = null;
      _tours = [];
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query);

      List<Map<String, dynamic>> tours = [];
      if (data['tours'] is List) {
        tours = List.from(data['tours']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);

          final dynamic priceRaw = m['price'];
          final String? currency = m['currencyCode']?.toString();

          final name = m['title']?.toString() ?? '';
          final rating = _getRatingString(m['ratingAverage']);
          final reviewsRaw =
              m['reviews'] ?? m['reviewCount'] ?? m['totalReviews'] ?? 0;
          final reviews = '(${reviewsRaw.toString()})';

          final location =
              m['location']?.toString() ??
              m['city']?.toString() ??
              m['area']?.toString() ??
              '';

          // Only cloud image; no asset fallback
          final networkImage =
              m['imageUrl']?.toString() ??
              m['thumbnailUrl']?.toString() ??
              m['image']?.toString() ??
              '';
          final image = networkImage; // may be empty; UI handles fallback

          final description =
              m['description']?.toString() ?? '${'tour_at'.tr} $location';

          // Duration mapping
          final durationText =
              m['duration']?.toString() ??
              m['durationText']?.toString() ??
              _guessDurationText(m);
          final durationDays = _durationToDays(m['durationDays'], durationText);

          // Price mapping
          final price = _formatPrice(priceRaw, currency);
          final basePrice = _toBasePrice(priceRaw, price);

          final type =
              m['type']?.toString() ??
              m['category']?.toString() ??
              'tour_type_city'.tr;

          // Optional flags
          final freeCancel =
              m['freeCancellation'] == true || m['free_cancel'] == true;
          final instantConfirm =
              m['instantConfirmation'] == true || m['instant'] == true;
          final pickup = m['hotelPickup'] == true || m['pickup'] == true;
          final inStock = m['inStock'] != false; // default true

          return {
            'tourId': m['tourId'] ?? m['id'] ?? m['tour_id'],
            'name': name,
            'type': type,
            'difficulty': m['difficultyLevel'] ?? m['difficulty']?.toString(),
            'rating': rating,
            'reviews': reviews,
            'price': price,
            'basePrice': basePrice,
            'durationDays': durationDays,
            'duration': durationText,
            'image': image, // url only
            'location': location,
            'description': description,
            'freeCancellation': freeCancel,
            'instantConfirmation': instantConfirm,
            'hotelPickup': pickup,
            'inStock': inStock,
          };
        }).toList();
      }

      setState(() {
        _tours = tours;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'error_load_tours'.tr;
      });
    }
  }

  // Utils used for mapping
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

  int _toBasePrice(dynamic priceDynamic, String formatted) {
    if (priceDynamic is num) return priceDynamic.round();
    final digits = formatted.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _guessDurationText(Map<String, dynamic> m) {
    final d = m['days'] ?? m['durationDays'];
    if (d is num) return '${d.round()} ${'day'.tr}';
    final h = m['hours'] ?? m['durationHours'];
    if (h is num) return '${h.round()} ${'hour'.tr}';
    return '1 ${'day'.tr}';
  }

  double _durationToDays(dynamic raw, String text) {
    if (raw is num) return raw.toDouble();
    final matchDays = RegExp(
      r'(\d+)\s*ng[aà]y',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchDays != null) return double.tryParse(matchDays.group(1)!) ?? 1;
    final matchHours = RegExp(
      r'(\d+)\s*gi[ơo]?',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchHours != null) {
      final h = double.tryParse(matchHours.group(1)!) ?? 24;
      return (h / 24).clamp(0.5, 10.0);
    }
    return 1;
  }
}

class _TagOption {
  final String label;
  final IconData icon;
  const _TagOption(this.label, this.icon);
}

class _TourCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String type;
  final String rating;
  final String reviews;
  final String price;
  final String duration;
  final VoidCallback onViewPressed;
  const _TourCard({
    required this.imagePath,
    required this.name,
    required this.type,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.duration,
    required this.onViewPressed,
  });

  double _ratingValue(String r) => double.tryParse(r) ?? 0;

  @override
  Widget build(BuildContext context) {
    final rVal = _ratingValue(rating);
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.25)),
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
                child: _buildImage(context),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Rating row: stars + (4.6) + reviews
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _ratingStars(context, rVal),
                const SizedBox(width: 6),
                Text(
                  ' (${rVal.toStringAsFixed(1)})',
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
              children: [_miniTag(context, type), _miniTag(context, duration)],
            ),
          ),
          const SizedBox(height: 10),
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
                child: Text('view_tour'.tr, style: context.buttonStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imagePath.isNotEmpty && imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(context),
      );
    }
    return _imageFallback(context);
  }

  // Themed fallback
  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08), // FIX
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  Widget _miniTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08), // FIX
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
