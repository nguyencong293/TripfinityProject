import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

// Networking
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/search_api_service.dart';

class AttractionOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;
  const AttractionOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<AttractionOverviewSearchScreen> createState() =>
      _AttractionOverviewSearchScreenState();
}

class _AttractionOverviewSearchScreenState
    extends State<AttractionOverviewSearchScreen> {
  // Filters state
  RangeValues _priceRange = const RangeValues(0, 800000); // VNĐ (vé)
  final RangeValues _defaultPrice = const RangeValues(0, 800000);

  final Set<int> _selectedRatings = {};
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedServices = {};
  final Set<String> _selectedTimes = {};
  final Set<String> _selectedSuitability = {};

  // Dynamic data
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

  // Navigation to attraction detail
  void _openAttractionDetail(Map<String, dynamic> attraction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
          attraction: attraction,
          activeTypes: _selectedTypes,
          activeServices: _selectedServices,
          activeTimes: _selectedTimes,
          activeSuitability: _selectedSuitability,
        ),
      ),
    );
  }

  // ====== Filter bottom sheet (giữ UI, dùng state hiện có) ======
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                            'Bộ lọc điểm tham quan',
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
                          _sectionTitle('Giá vé (VND)'),
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
                                  'Mặc định',
                                  style: TextStyle(
                                    color: context.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          _sectionTitle('Đánh giá'),
                          _wrapOptions<int>(
                            options: const [5, 4, 3, 2],
                            isSelected: (o) => tempRatings.contains(o),
                            onTap: (o) => setM(
                              () => tempRatings.contains(o)
                                  ? tempRatings.remove(o)
                                  : tempRatings.add(o),
                            ),
                            labelBuilder: (o) => '$o sao',
                          ),

                          _sectionTitle('Loại hình'),
                          _chipsGroup(tempTypes, const [
                            'Văn hoá',
                            'Lịch sử',
                            'Thiên nhiên',
                            'Giải trí',
                            'Bảo tàng',
                            'Công viên',
                          ], setM),

                          _sectionTitle('Dịch vụ'),
                          _chipsGroup(tempServices, const [
                            'Hướng dẫn viên',
                            'Chụp ảnh',
                            'Ăn uống',
                            'Biểu diễn',
                            'Cáp treo',
                            'Thuê đồ',
                          ], setM),

                          _sectionTitle('Thời gian'),
                          _chipsGroup(tempTimes, const [
                            'Sáng',
                            'Chiều',
                            'Tối',
                          ], setM),

                          _sectionTitle('Phù hợp với'),
                          _chipsGroup(tempSuit, const [
                            'Gia đình',
                            'Nhóm',
                            'Trẻ em',
                            'Cặp đôi',
                            'Solo',
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
        _miniTag('Tối thiểu: ${_formatCurrency(v.start)}'),
        _miniTag('Tối đa: ${_formatCurrency(v.end)}'),
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
            color: Colors.black.withValues(alpha: 0.08),
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
                      content: const Text('Đã làm mới bộ lọc'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: context.cardBackgroundColor,
                    ),
                  );
                },
                child: Text(
                  'Làm mới',
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
                child: const Text(
                  'Áp dụng',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
    final filtered = _filteredAttractions;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: context.textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điểm tham quan',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: context.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.searchQuery,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterPill(),
              ],
            ),
          ),
          if (_loading)
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: context.primaryColor,
                  ),
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: context.bodyOneStyle.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else if (_attractions.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Không có kết quả',
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchAttractions(widget.searchQuery),
                color: context.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    final priceText = a['price']?.toString() ?? '';
                    final imageUrl = a['imageUrl']?.toString();
                    final types = (a['types'] is List)
                        ? (a['types'] as List).map((e) => e.toString()).toList()
                        : const <String>[];

                    return _AttractionCard(
                      name: a['name']?.toString() ?? '',
                      location: a['location']?.toString() ?? '',
                      rating: _asDouble(a['rating']),
                      priceText: priceText,
                      types: types,
                      imageUrl: imageUrl,
                      onTap: () => _openAttractionDetail(a),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Widget _buildFilterPill() {
    final active = _hasAnyFilterApplied;
    return InkWell(
      onTap: _openFilterSheet,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? context.primaryColor : context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? context.primaryColor : context.dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.slidersHorizontal,
              size: 16,
              color: active
                  ? context.buttonTextColor
                  : context.textSecondaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              active ? 'Bộ lọc *' : 'Bộ lọc',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active
                    ? context.buttonTextColor
                    : context.textSecondaryColor,
              ),
            ),
          ],
        ),
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

          // Chuyển giá về string hiển thị + số nguyên để lọc
          final displayPrice = _formatPrice(price, currency);
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
        _error =
            'Không thể tải điểm tham quan. Vui lòng thử lại hoặc đăng nhập.';
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

  String _formatPrice(dynamic price, String currency) {
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
}

class _AttractionCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String priceText;
  final List<String> types;
  final String? imageUrl;
  final VoidCallback onTap;

  const _AttractionCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.priceText,
    required this.types,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  if (imageUrl != null && imageUrl!.startsWith('http'))
                    Image.network(
                      imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackImage(context),
                    )
                  else
                    _fallbackImage(context),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.star,
                            size: 14,
                            color: context.warningAlertColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: context.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            color: context.textSecondaryColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: types.take(4).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.ticket,
                        size: 16,
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        priceText.isEmpty ? '—' : priceText,
                        style: TextStyle(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: context.textSecondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }
}
