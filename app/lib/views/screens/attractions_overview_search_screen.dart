import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

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

  // Data (tĩnh)
  final List<Map<String, dynamic>> _attractions = [
    {
      'name': 'Tháp Chăm Po Nagar',
      'location': 'Nha Trang, Việt Nam',
      'rating': 4.6,
      'price': 120000,
      'types': ['Văn hoá', 'Lịch sử'],
      'services': ['Hướng dẫn viên', 'Chụp ảnh'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Gia đình', 'Nhóm'],
      'img': 1,
    },
    {
      'name': 'Viện Hải dương học',
      'location': 'Nha Trang, Việt Nam',
      'rating': 4.5,
      'price': 150000,
      'types': ['Bảo tàng', 'Giáo dục'],
      'services': ['Hướng dẫn viên', 'Khu lưu niệm'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Gia đình', 'Trẻ em'],
      'img': 2,
    },
    {
      'name': 'Hòn Mun',
      'location': 'Nha Trang, Việt Nam',
      'rating': 4.7,
      'price': 450000,
      'types': ['Thiên nhiên', 'Lặn biển'],
      'services': ['Tàu cano', 'Thuê đồ lặn'],
      'times': ['Sáng'],
      'suit': ['Cặp đôi', 'Nhóm'],
      'img': 3,
    },
    {
      'name': 'Chợ Đầm',
      'location': 'Nha Trang, Việt Nam',
      'rating': 4.2,
      'price': 0,
      'types': ['Mua sắm', 'Văn hoá'],
      'services': ['Ăn uống', 'Quầy lưu niệm'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Gia đình', 'Solo'],
      'img': 4,
    },
    {
      'name': 'VinWonders Nha Trang',
      'location': 'Đảo Hòn Tre',
      'rating': 4.8,
      'price': 950000,
      'types': ['Giải trí', 'Công viên'],
      'services': ['Cáp treo', 'Ẩm thực', 'Biểu diễn'],
      'times': ['Sáng', 'Chiều', 'Tối'],
      'suit': ['Gia đình', 'Nhóm'],
      'img': 1,
    },
    {
      'name': 'Nhà thờ Núi',
      'location': 'Nha Trang, Việt Nam',
      'rating': 4.4,
      'price': 0,
      'types': ['Tôn giáo', 'Kiến trúc'],
      'services': ['Chụp ảnh'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Solo', 'Cặp đôi'],
      'img': 2,
    },
  ];

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
      if (a['price'] < _priceRange.start || a['price'] > _priceRange.end) {
        return false;
      }
      if (_selectedRatings.isNotEmpty &&
          !_selectedRatings.any((r) => a['rating'].floor() == r)) {
        return false;
      }
      if (_selectedTypes.isNotEmpty &&
          !_selectedTypes.any((t) => (a['types'] as List).contains(t))) {
        return false;
      }
      if (_selectedServices.isNotEmpty &&
          !_selectedServices.any((s) => (a['services'] as List).contains(s))) {
        return false;
      }
      if (_selectedTimes.isNotEmpty &&
          !_selectedTimes.any((t) => (a['times'] as List).contains(t))) {
        return false;
      }
      if (_selectedSuitability.isNotEmpty &&
          !_selectedSuitability.any((s) => (a['suit'] as List).contains(s))) {
        return false;
      }
      return true;
    }).toList();
  }

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
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Bộ lọc điểm tham quan',
                            style: context.subTitleOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setM(() {
                                tempPrice = _defaultPrice;
                                tempRatings.clear();
                                tempTypes.clear();
                                tempServices.clear();
                                tempTimes.clear();
                                tempSuit.clear();
                              });
                            },
                            child: Text(
                              'Đặt lại',
                              style: context.captionStyle.copyWith(
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ).copyWith(bottom: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Giá vé (VNĐ)'),
                            RangeSlider(
                              values: tempPrice,
                              min: 0,
                              max: 1000000,
                              divisions: 50,
                              labels: RangeLabels(
                                tempPrice.start.toInt().toString(),
                                tempPrice.end.toInt().toString(),
                              ),
                              onChanged: (v) => setM(() => tempPrice = v),
                              activeColor: context.primaryColor,
                              inactiveColor: context.dividerColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            _priceRow(tempPrice),

                            _sectionTitle('Đánh giá'),
                            _wrapOptions(
                              options: [5, 4, 3, 2, 1],
                              isSelected: (o) => tempRatings.contains(o),
                              onTap: (o) => setM(() {
                                if (tempRatings.contains(o)) {
                                  tempRatings.remove(o);
                                } else {
                                  tempRatings.add(o);
                                }
                              }),
                              labelBuilder: (o) => '$o★',
                            ),

                            _sectionTitle('Loại'),
                            _chipsGroup(tempTypes, [
                              'Văn hoá',
                              'Lịch sử',
                              'Thiên nhiên',
                              'Bảo tàng',
                              'Giải trí',
                              'Kiến trúc',
                              'Mua sắm',
                              'Lặn biển',
                              'Công viên',
                            ], setM),

                            _sectionTitle('Dịch vụ / Tiện ích'),
                            _chipsGroup(tempServices, [
                              'Hướng dẫn viên',
                              'Chụp ảnh',
                              'Thuê đồ lặn',
                              'Tàu cano',
                              'Ẩm thực',
                              'Cáp treo',
                              'Khu lưu niệm',
                              'Wifi',
                              'Bãi đỗ xe',
                            ], setM),

                            _sectionTitle('Thời điểm hoạt động'),
                            _chipsGroup(tempTimes, [
                              'Sáng',
                              'Chiều',
                              'Tối',
                              'Đêm',
                            ], setM),

                            _sectionTitle('Phù hợp với'),
                            _chipsGroup(tempSuit, [
                              'Gia đình',
                              'Nhóm',
                              'Cặp đôi',
                              'Solo',
                              'Trẻ em',
                            ], setM),
                          ],
                        ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã áp dụng bộ lọc (${_filteredAttractions.length} kết quả)',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
    String fm(num n) {
      if (n >= 1000000) {
        return '${(n / 1000000).toStringAsFixed(1)}M';
      }
      if (n >= 1000) {
        return '${(n / 1000).toStringAsFixed(0)}K';
      }
      return n.toString();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniTag('Tối thiểu: ${fm(v.start.round())}'),
        _miniTag('Tối đa: ${fm(v.end.round())}'),
      ],
    );
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
                    const SnackBar(
                      content: Text('Đã đặt lại bộ lọc'),
                      behavior: SnackBarBehavior.floating,
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
                    'Kết quả cho: "${widget.searchQuery}"',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final a = filtered[index];
                return _AttractionCard(
                  name: a['name'],
                  location: a['location'],
                  rating: a['rating'],
                  price: a['price'],
                  types: (a['types'] as List).cast<String>(),
                  imageIndex: a['img'],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đi tới chi tiết điểm: ${a['name']}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
}

class _AttractionCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final int price;
  final List<String> types;
  final int imageIndex;
  final VoidCallback onTap;

  const _AttractionCard({
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.types,
    required this.imageIndex,
    required this.onTap,
  });

  String _formatPrice(int v) {
    if (v == 0) return 'Miễn phí';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toString();
  }

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
                  Image.asset(
                    'assets/images/onboarding${(imageIndex % 4) + 1}.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: context.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        LucideIcons.image,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w600,
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
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: types.take(4).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _formatPrice(price),
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onTap,
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}
