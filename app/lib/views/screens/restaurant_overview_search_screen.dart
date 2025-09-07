import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class RestaurantOverviewSearchScreen extends StatefulWidget {
  final String searchQuery;
  const RestaurantOverviewSearchScreen({super.key, required this.searchQuery});

  @override
  State<RestaurantOverviewSearchScreen> createState() =>
      _RestaurantOverviewSearchScreenState();
}

class _RestaurantOverviewSearchScreenState
    extends State<RestaurantOverviewSearchScreen> {
  bool _hasDate = true;
  bool _hasGuests = true;

  // Price per person
  RangeValues _priceRange = const RangeValues(50000, 450000);
  static const double _minPrice = 0;
  static const double _maxPrice = 1000000;

  final Set<String> _cuisines = {};
  final Set<String> _services = {};
  final Set<String> _dietaries = {};
  final Set<int> _selectedStars = {};
  bool _openNow = false;
  bool _reservation = false;
  bool _takeAway = false;
  bool _inStockOnly = false;

  final List<_TagOption> _cuisineCatalog = const [
    _TagOption('Việt', LucideIcons.wine),
    _TagOption('Hải sản', LucideIcons.fish),
    _TagOption('Âu', LucideIcons.wine),
    _TagOption('Hàn', LucideIcons.wine), // fallback icon alias
    _TagOption('Nhật', LucideIcons.wine),
    _TagOption('Thái', LucideIcons.eggFried),
    _TagOption('Trung', LucideIcons.wine),
    _TagOption('Chay', LucideIcons.leaf),
    _TagOption('Nướng', LucideIcons.flame),
    _TagOption('Cà phê', LucideIcons.coffee),
  ];

  final List<_TagOption> _serviceCatalog = const [
    _TagOption('Ăn tại chỗ', LucideIcons.utensils),
    _TagOption('Mang đi', LucideIcons.shoppingBag),
    _TagOption('Giao hàng', LucideIcons.bike),
    _TagOption('Bar', LucideIcons.beer),
    _TagOption('Sân vườn', LucideIcons.treePine),
    _TagOption('Phòng riêng', LucideIcons.doorClosed),
  ];

  final List<_TagOption> _dietaryCatalog = const [
    _TagOption('Vegan', LucideIcons.leaf),
    _TagOption('Halal', LucideIcons.badgeCheck),
    _TagOption('Gluten-free', LucideIcons.wheatOff),
    _TagOption('Ít calo', LucideIcons.scale),
    _TagOption('Không sữa', LucideIcons.milkOff),
  ];

  final List<Map<String, String>> _restaurants = List.generate(8, (i) {
    final names = [
      'White Rose Restaurant',
      'Sea Breeze Grill',
      'Hải Sản Tươi Sống 68',
      'Urban Coffee & Bistro',
      'Green Vegan Garden',
      'Golden Dragon Dim Sum',
      'Nori Sushi & Sake',
      'Spicy Thai Corner',
    ];
    return {
      'name': names[i],
      'cuisine': [
        'Âu',
        'Hải sản',
        'Việt',
        'Cà phê',
        'Chay',
        'Trung',
        'Nhật',
        'Thái',
      ][i],
      'price': '${(120000 + i * 30000)} đ',
      'rating': (4.0 + (i * 0.1)).toStringAsFixed(1),
      'reviews': '(${(320 + i * 47)})',
      'image': 'assets/images/onboarding${(i % 4) + 1}.png',
      'tag': [
        'Bar',
        'Sân vườn',
        'Phòng riêng',
        'Giao hàng',
        'Vegan',
        'Ăn tại chỗ',
        'Mang đi',
        'Halal',
      ][i],
    };
  });

  bool get _hasAnyFilterApplied {
    return _priceRange.start > _minPrice ||
        _priceRange.end < _maxPrice ||
        _cuisines.isNotEmpty ||
        _services.isNotEmpty ||
        _dietaries.isNotEmpty ||
        _selectedStars.isNotEmpty ||
        _openNow ||
        _reservation ||
        _takeAway ||
        _inStockOnly;
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
          widget.searchQuery.isEmpty ? 'Nha Trang' : widget.searchQuery,
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildTopChips(context),
          Expanded(
            child: ListView.separated(
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
                  onViewPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đi tới chi tiết: ${r['name']}')),
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

  Widget _buildTopChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _pill(
            context,
            icon: LucideIcons.utensils,
            label: 'Nhà hàng',
            selected: true,
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: _hasDate ? LucideIcons.calendarDays : LucideIcons.calendar,
            label: _hasDate ? '11 thg 6' : 'Ngày',
            onTap: () => setState(() => _hasDate = !_hasDate),
          ),
          const SizedBox(width: 8),
          _pill(
            context,
            icon: LucideIcons.users,
            label: _hasGuests ? '2 người' : 'Khách',
            onTap: () => setState(() => _hasGuests = !_hasGuests),
          ),
          const SizedBox(width: 8),
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
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              final media = MediaQuery.of(ctx);
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: media.viewInsets.bottom + 16,
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
                              'Bộ lọc nhà hàng',
                              style: context.subTitleOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheet(() {
                                price = const RangeValues(_minPrice, _maxPrice);
                                cuisines.clear();
                                services.clear();
                                dietaries.clear();
                                stars.clear();
                                openNow = false;
                                reservation = false;
                                takeAway = false;
                                stock = false;
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

                      _sectionTitle(
                        ctx,
                        LucideIcons.badgeDollarSign,
                        'Giá mỗi người',
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
                            setSheet(() => price = _normalizeRange(v)),
                      ),

                      const SizedBox(height: 16),
                      _sectionTitle(ctx, LucideIcons.star, 'Đánh giá'),
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
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  star,
                                  (j) => Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: sel
                                          ? context.buttonTextColor
                                          : context.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$star sao',
                                  style: context.bodyTwoStyle.copyWith(
                                    color: sel
                                        ? context.buttonTextColor
                                        : context.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: context.cardBackgroundColor,
                            selectedColor: context.primaryColor,
                            side: BorderSide(
                              color: sel
                                  ? context.primaryColor
                                  : context.dividerColor,
                            ),
                            onSelected: (_) {
                              setSheet(() {
                                sel ? stars.remove(star) : stars.add(star);
                              });
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 16),
                      _sectionTitle(ctx, LucideIcons.briefcase, 'Ẩm thực'),
                      const SizedBox(height: 8),
                      _wrapOptions(ctx, _cuisineCatalog, cuisines, setSheet),

                      const SizedBox(height: 16),
                      _sectionTitle(ctx, LucideIcons.briefcase, 'Dịch vụ'),
                      const SizedBox(height: 8),
                      _wrapOptions(ctx, _serviceCatalog, services, setSheet),

                      const SizedBox(height: 16),
                      _sectionTitle(ctx, LucideIcons.heartPulse, 'Chế độ ăn'),
                      const SizedBox(height: 8),
                      _wrapOptions(
                        ctx,
                        _dietaryCatalog,
                        dietaries,
                        setSheet,
                        maxWidth: 160,
                      ),

                      const SizedBox(height: 16),
                      _sectionTitle(ctx, LucideIcons.checkCircle2, 'Tùy chọn'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _toggleChip(
                            ctx,
                            'Đang mở cửa',
                            openNow,
                            (v) => setSheet(() => openNow = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Đặt bàn',
                            reservation,
                            (v) => setSheet(() => reservation = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Mang đi',
                            takeAway,
                            (v) => setSheet(() => takeAway = v),
                          ),
                          _toggleChip(
                            ctx,
                            'Chỉ còn bàn',
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
                                });
                                Navigator.of(ctx).pop();
                                final count =
                                    (_priceRange.start > _minPrice ||
                                            _priceRange.end < _maxPrice
                                        ? 1
                                        : 0) +
                                    _cuisines.length +
                                    _services.length +
                                    _dietaries.length +
                                    _selectedStars.length +
                                    (_openNow ? 1 : 0) +
                                    (_reservation ? 1 : 0) +
                                    (_takeAway ? 1 : 0) +
                                    (_inStockOnly ? 1 : 0);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã áp dụng $count tiêu chí lọc (demo)',
                                    ),
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
  final VoidCallback onViewPressed;

  const _RestaurantCard({
    required this.imagePath,
    required this.name,
    required this.cuisine,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset(
                  imagePath,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 170,
                    color: context.primaryColor.withValues(alpha: 0.08),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.image, color: context.primaryColor),
                  ),
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
              maxLines: 2,
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
                      i < 4 ? Icons.star_rounded : Icons.star_border_rounded,
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
                child: Text('Xem nhà hàng', style: context.buttonStyle),
              ),
            ),
          ),
        ],
      ),
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
}
