import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

// Networking
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/search_api_service.dart';
import 'package:app/services/localization_service.dart';

class AttractionOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;
  const AttractionOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<AttractionOverviewSearchScreen> createState() =>
      _AttractionOverviewSearchScreenState();
}

class _AttractionOverviewSearchScreenState
    extends State<AttractionOverviewSearchScreen> {
  bool _hasDate = true;
  bool _hasGuests = true;

  RangeValues _priceRange = const RangeValues(0, 800000); // VNĐ (vé)
  final RangeValues _defaultPrice = const RangeValues(0, 800000);

  final Set<int> _selectedRatings = {};
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedServices = {};
  final Set<String> _selectedTimes = {};
  final Set<String> _selectedSuitability = {};

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _attractions = [];

  @override
  void initState() {
    super.initState();
    _fetchAttractions(widget.searchQuery);
  }

  bool get _hasAnyFilterApplied {
    return _priceRange != _defaultPrice ||
        _selectedRatings.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _selectedServices.isNotEmpty ||
        _selectedTimes.isNotEmpty ||
        _selectedSuitability.isNotEmpty;
  }

  List<Map<String, dynamic>> get _filteredAttractions {
    return _attractions.where((a) {
      final priceInt = a['priceInt'] is num
          ? (a['priceInt'] as num).toInt()
          : 0;
      final ratingVal = a['rating'];
      final ratingNum = ratingVal is num
          ? ratingVal
          : (ratingVal is String ? double.tryParse(ratingVal) ?? 0.0 : 0.0);
      final types = (a['types'] is List)
          ? (a['types'] as List).map((e) => e.toString()).toList()
          : const <String>[];
      final services = (a['services'] is List)
          ? (a['services'] as List).map((e) => e.toString()).toList()
          : const <String>[];
      final times = (a['times'] is List)
          ? (a['times'] as List).map((e) => e.toString()).toList()
          : const <String>[];
      final suit = (a['suit'] is List)
          ? (a['suit'] as List).map((e) => e.toString()).toList()
          : const <String>[];

      if (priceInt < _priceRange.start || priceInt > _priceRange.end) {
        return false;
      }
      if (_selectedRatings.isNotEmpty &&
          !_selectedRatings.any((r) => ratingNum.floor() == r)) {
        return false;
      }
      if (_selectedTypes.isNotEmpty &&
          !_selectedTypes.any((t) => types.contains(t))) {
        return false;
      }
      if (_selectedServices.isNotEmpty &&
          !_selectedServices.any((s) => services.contains(s))) {
        return false;
      }
      if (_selectedTimes.isNotEmpty &&
          !_selectedTimes.any((t) => times.contains(t))) {
        return false;
      }
      if (_selectedSuitability.isNotEmpty &&
          !_selectedSuitability.any((s) => suit.contains(s))) {
        return false;
      }
      return true;
    }).toList();
  }

  void _openAttractionDetail(Map<String, dynamic> attraction) {
    final attractionId = attraction['attractionId'] ?? attraction['id'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttractionsOverviewDetailScreen(
          attractionId: attractionId != null
              ? int.tryParse(attractionId.toString())
              : null,
          attraction: attractionId == null ? attraction : null, // fallback
          activeTypes: _selectedTypes,
          activeServices: _selectedServices,
          activeTimes: _selectedTimes,
          activeSuitability: _selectedSuitability,
        ),
      ),
    );
  }

  // ====== Filter bottom sheet ======
  void _openFilterSheet() {
    RangeValues tempPrice = _priceRange;
    final tempRatings = {..._selectedRatings};
    final tempTypes = {..._selectedTypes};
    final tempServices = {..._selectedServices};
    final tempTimes = {..._selectedTimes};
    final tempSuit = {..._selectedSuitability};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, setM) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
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
                          Text(
                            'attraction_filter_title'.tr,
                            style: context.subTitleOneStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        children: [
                          _sectionTitle('ticket_price_vnd'.tr),
                          _priceRow(tempPrice),
                          RangeSlider(
                            values: tempPrice,
                            onChanged: (v) => setM(() => tempPrice = v),
                            min: 0,
                            max: 2000000,
                            divisions: 40,
                            activeColor: context.primaryColor,
                            labels: RangeLabels(
                              _formatCurrency(tempPrice.start),
                              _formatCurrency(tempPrice.end),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => setM(() {
                                  tempPrice = _defaultPrice;
                                }),
                                icon: Icon(
                                  LucideIcons.rotateCcw,
                                  size: 16,
                                  color: context.textSecondaryColor,
                                ),
                                label: Text(
                                  'default'.tr,
                                  style: TextStyle(
                                    color: context.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          _sectionTitle('reviews_title'.tr),
                          _wrapOptions<int>(
                            options: const [5, 4, 3, 2],
                            isSelected: (o) => tempRatings.contains(o),
                            onTap: (o) => setM(
                              () => tempRatings.contains(o)
                                  ? tempRatings.remove(o)
                                  : tempRatings.add(o),
                            ),
                            labelBuilder: (o) => '$o ${'stars'.tr}',
                          ),

                          _sectionTitle('visit_types'.tr),
                          _chipsGroup(tempTypes, [
                            'type_culture'.tr,
                            'type_history'.tr,
                            'type_nature'.tr,
                            'type_entertainment'.tr,
                            'type_museum'.tr,
                            'type_park'.tr,
                          ], setM),

                          _sectionTitle('available_services'.tr),
                          _chipsGroup(tempServices, [
                            'svc_guide'.tr,
                            'svc_photo'.tr,
                            'svc_food'.tr,
                            'svc_show'.tr,
                            'svc_cable_car'.tr,
                            'svc_rentals'.tr,
                          ], setM),

                          _sectionTitle('operating_times'.tr),
                          _chipsGroup(tempTimes, [
                            'time_morning'.tr,
                            'time_afternoon'.tr,
                            'time_evening'.tr,
                          ], setM),

                          _sectionTitle('suitable_for'.tr),
                          _chipsGroup(tempSuit, [
                            'suit_family'.tr,
                            'suit_group'.tr,
                            'suit_kids'.tr,
                            'suit_couple'.tr,
                            'suit_solo'.tr,
                          ], setM),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    _bottomActions(
                      onApply: () {
                        setState(() {
                          _priceRange = tempPrice;
                          _selectedRatings
                            ..clear()
                            ..addAll(tempRatings);
                          _selectedTypes
                            ..clear()
                            ..addAll(tempTypes);
                          _selectedServices
                            ..clear()
                            ..addAll(tempServices);
                          _selectedTimes
                            ..clear()
                            ..addAll(tempTimes);
                          _selectedSuitability
                            ..clear()
                            ..addAll(tempSuit);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _priceRow(RangeValues v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniTag('${'min'.tr}: ${_formatCurrency(v.start)}'),
        _miniTag('${'max'.tr}: ${_formatCurrency(v.end)}'),
      ],
    );
  }

  String _formatCurrency(double n) {
    final v = n.round();
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }

  Widget _miniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: context.textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _chipsGroup(
    Set<String> current,
    List<String> options,
    void Function(void Function()) setM,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final sel = current.contains(o);
        return FilterChip(
          label: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              o,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: sel
                    ? context.buttonTextColor
                    : context.textSecondaryColor,
              ),
            ),
          ),
          selected: sel,
          showCheckmark: false,
          backgroundColor: context.cardBackgroundColor,
          selectedColor: context.primaryColor,
          side: BorderSide(
            color: sel ? context.primaryColor : context.dividerColor,
          ),
          onSelected: (_) => setM(() {
            if (sel) {
              current.remove(o);
            } else {
              current.add(o);
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _wrapOptions<T>({
    required List<T> options,
    required bool Function(T) isSelected,
    required void Function(T) onTap,
    required String Function(T) labelBuilder,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final sel = isSelected(o);
        return ChoiceChip(
          label: Text(
            labelBuilder(o),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: sel ? context.buttonTextColor : context.textSecondaryColor,
            ),
          ),
          selected: sel,
          showCheckmark: false,
          backgroundColor: context.cardBackgroundColor,
          selectedColor: context.primaryColor,
          side: BorderSide(
            color: sel ? context.primaryColor : context.dividerColor,
          ),
          onSelected: (_) => onTap(o),
        );
      }).toList(),
    );
  }

  Widget _bottomActions({required VoidCallback onApply}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: context.overlayModalBackdropColor,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _priceRange = _defaultPrice;
                    _selectedRatings.clear();
                    _selectedTypes.clear();
                    _selectedServices.clear();
                    _selectedTimes.clear();
                    _selectedSuitability.clear();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('filters_reset'.tr),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: context.cardBackgroundColor,
                    ),
                  );
                },
                child: Text(
                  'clear_filters'.tr,
                  style: TextStyle(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: onApply,
                child: Text(
                  'apply'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== UI ======
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
              ? 'attractions_title'.tr
              : widget.searchQuery,
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

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.landmark,
            label: 'cat_attraction'.tr,
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
            icon: LucideIcons.users,
            label: _hasGuests ? '2 ${'guests'.tr}' : 'guests'.tr,
            onTap: () => setState(() => _hasGuests = !_hasGuests),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.slidersHorizontal,
            label: 'filter'.tr,
            selected: _hasAnyFilterApplied,
            onTap: _openFilterSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final filtered = _filteredAttractions;

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
    if (_attractions.isEmpty) {
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
      onRefresh: () => _fetchAttractions(widget.searchQuery),
      color: context.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final a = filtered[index];
          final name = a['name']?.toString() ?? '';
          final rating = _getRatingString(a['rating']);
          final reviews = a['reviews']?.toString() ?? '';
          final priceText = a['price']?.toString() ?? '';
          final imageUrl = a['imageUrl']?.toString();
          final fallbackAsset =
              'assets/images/onboarding${(index % 4) + 1}.png';

          return _AttractionCard(
            imageUrl: imageUrl,
            fallbackAsset: fallbackAsset,
            name: name,
            rating: rating,
            reviews: reviews,
            price: priceText,
            onTap: () => _openAttractionDetail(a),
          );
        },
      ),
    );
  }

  // ===== API =====
  Future<void> _fetchAttractions(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query, type: 'attraction');

      List<Map<String, dynamic>> attractions = [];
      if (data['attractions'] is List) {
        attractions = List.from(data['attractions']).map<Map<String, dynamic>>((
          e,
        ) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = (m['currencyCode'] ?? '').toString().toUpperCase();

          final displayPrice = _formatApiPrice(price, currency);
          final priceInt = _toInt(price);

          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'attraction',
            'price': displayPrice,
            'priceInt': priceInt,
            'description': m['serviceDescription']?.toString() ?? '',
            'imageUrl': m['thumbnailUrl'],
            'types': m['types'] is List ? List.from(m['types']) : <String>[],
            'services': m['services'] is List
                ? List.from(m['services'])
                : <String>[],
            'times': m['times'] is List ? List.from(m['times']) : <String>[],
            'suit': m['suit'] is List ? List.from(m['suit']) : <String>[],
          };
        }).toList();
      }

      setState(() {
        _attractions = attractions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'error_load_attractions'.tr;
      });
    }
  }

  int _toInt(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.round();
    final s = price.toString().replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(s) ?? 0;
  }

  String _formatApiPrice(dynamic price, String currency) {
    if (price == null) return '';
    num? n;
    if (price is num) {
      n = price;
    } else {
      n = num.tryParse(price.toString());
    }
    if (n == null) return price.toString();
    if (currency == 'VND' || currency == 'VNĐ') {
      return '${n.toStringAsFixed(0)} đ';
    }
    if (currency.isEmpty) return n.toString();
    return '$n $currency';
  }

  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is String) return rating;
    if (rating is num) return rating.toString();
    return '0.0';
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
}

Widget _imageFallback(BuildContext context) {
  return Container(
    height: 180,
    color: context.primaryColor.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: Icon(LucideIcons.image, color: context.primaryColor),
  );
}

class _AttractionCard extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final String name;
  final String rating;
  final String reviews;
  final String price;
  final VoidCallback onTap;

  const _AttractionCard({
    required this.imageUrl,
    required this.fallbackAsset,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetwork = (imageUrl ?? '').startsWith('http');
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
                    // FIX: use withOpacity()
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
          // Tên
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
                  price.isEmpty ? '—' : price,
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
                onPressed: onTap,
                child: Text('view_attraction'.tr, style: context.buttonStyle),
              ),
            ),
          ),
        ],
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
