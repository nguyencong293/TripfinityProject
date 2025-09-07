import 'package:app/views/screens/tour_service_overview_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

// Screens
import 'search_overview_screen.dart';
import 'package:app/views/screens/hotel_overview_search_screen.dart';

// Quick filter categories
enum _QuickFilter { all, restaurant, hotel, tour, attraction }

class GeneralSearchScreen extends StatefulWidget {
  const GeneralSearchScreen({super.key});

  @override
  State<GeneralSearchScreen> createState() => _GeneralSearchScreenState();
}

class _GeneralSearchScreenState extends State<GeneralSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  _QuickFilter _selected = _QuickFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Nha Trang';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: context.backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickFilters(context),
                const SizedBox(height: 20),
                _buildSearchResults(context),
                const SizedBox(height: 32),
                _buildSuggestedPlaces(context),
                const SizedBox(height: 32),
                _buildNearbySection(context),
                const SizedBox(height: 32),
                _buildRecentSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Search bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 20),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_hint'.tr,
          hintStyle: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: context.textSecondaryColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: context.textSecondaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: context.textDisabledColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: context.bodyOneStyle,
        onChanged: (value) => setState(() {}),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _performSearch(value);
        },
      ),
    );
  }

  // Quick filters
  Widget _buildQuickFilters(BuildContext context) {
    final items = [
      ('Tất cả', LucideIcons.layoutPanelTop, _QuickFilter.all),
      ('Nhà hàng', LucideIcons.utensils, _QuickFilter.restaurant),
      ('Khách sạn', LucideIcons.hotel, _QuickFilter.hotel),
      ('Tour du lịch', LucideIcons.bus, _QuickFilter.tour),
      ('Điểm tham quan', LucideIcons.ticket, _QuickFilter.attraction),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bộ lọc',
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            final sel = _selected == e.$3;
            return FilterChip(
              selected: sel,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    e.$2,
                    size: 16,
                    color: sel
                        ? context.buttonTextColor
                        : context.textSecondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.$1,
                    style: context.bodyTwoStyle.copyWith(
                      color: sel
                          ? context.buttonTextColor
                          : context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.cardBackgroundColor,
              selectedColor: context.primaryColor,
              side: BorderSide(
                color: sel ? context.primaryColor : context.dividerColor,
              ),
              onSelected: (_) => setState(() => _selected = e.$3),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Results section (always same layout; "Xem thêm" decides where to go)
  Widget _buildSearchResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            final items = [
              {
                'name': 'Nha Trang',
                'location': 'Việt Nam, Châu Á',
                'rating': '4.1',
                'type': 'destination',
              },
              {
                'name': 'Nha Trang Xưa',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.2',
                'type': 'restaurant',
              },
              {
                'name': 'White Rose Restaurant',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.3',
                'type': 'restaurant',
              },
              {
                'name': 'Vinpearl - Resort Nha Trang',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.2',
                'type': 'hotel',
              },
            ];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final item = items[index];
                  if (item['type'] == 'destination') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchOverviewScreen(searchQuery: item['name']!),
                      ),
                    );
                  } else if (item['type'] == 'hotel') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đi tới chi tiết khách sạn: ${item['name']}',
                        ),
                      ),
                    );
                  } else {
                    _navigateToSpecificPage(item['name']!, item['type']!);
                  }
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding${(index % 4) + 1}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: context.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            LucideIcons.image,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index]['name']!,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[index]['location']!,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: context.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                items[index]['rating']!,
                                style: context.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: context.textSecondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final query = _searchController.text.trim();

              // Quick filter direct routes
              if (_selected == _QuickFilter.hotel) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HotelOverviewSearchScreen(
                      searchQuery: query.isEmpty ? 'Khách sạn' : query,
                    ),
                  ),
                );
                return;
              }
              if (_selected == _QuickFilter.tour) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TourServiceOverviewScreen(
                      searchQuery: query.isEmpty ? 'Tour' : query,
                    ),
                  ),
                );
                return;
              }

              // General / specific query routing
              if (query.isEmpty || _isGeneralSearch(query)) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchOverviewScreen(searchQuery: query),
                  ),
                );
              } else {
                final category = _getSearchCategory(query);
                if (category == 'hotel') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          HotelOverviewSearchScreen(searchQuery: query),
                    ),
                  );
                } else if (category == 'tour') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TourServiceOverviewScreen(searchQuery: query),
                    ),
                  );
                } else {
                  _navigateToSpecificPage(query, category);
                }
              }
            },
            child: Text(
              'Xem thêm',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Suggested places
  Widget _buildSuggestedPlaces(BuildContext context) {
    final suggestions = [
      {
        'name': 'Bãi biển Đồ Sơn',
        'location': 'Hải Phòng, Việt Nam',
        'rating': '4.5',
      },
      {
        'name': 'Thủy cung Times City',
        'location': 'Hà Nội, Việt Nam',
        'rating': '4.7',
      },
      {
        'name': 'Vịnh Hạ Long',
        'location': 'Quảng Ninh, Việt Nam',
        'rating': '4.9',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Có thể bạn quan tâm',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem thêm',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final s = suggestions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchOverviewScreen(searchQuery: s['name']!),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding${(index % 3) + 2}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: context.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            LucideIcons.image,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['name']!,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['location']!,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: context.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                s['rating']!,
                                style: context.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: context.textSecondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Nearby section
  Widget _buildNearbySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.navigation, color: context.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: () {},
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, color: context.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm kiếm xung quanh',
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Khám phá địa điểm gần vị trí của bạn',
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Recent section
  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã xem gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem thêm',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRecentItemTile(context, index),
        ),
      ],
    );
  }

  Widget _buildRecentItemTile(BuildContext context, int index) {
    final items = [
      {
        'name': 'White Rose Restaurant',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.1',
        'type': 'restaurant',
      },
      {
        'name': 'Vinpearl - Resort Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.2',
        'type': 'hotel',
      },
      {
        'name': 'Thấp Chăm Po Nagar',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.3',
        'type': 'activity',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          final item = items[index];
          if (item['type'] == 'hotel') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đi tới chi tiết khách sạn: ${item['name']}'),
              ),
            );
          } else {
            _navigateToSpecificPage(item['name']!, item['type']!);
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/onboarding${(index % 4) + 1}.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: context.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    LucideIcons.image,
                    color: context.primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index]['name']!,
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['location']!,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: context.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        items[index]['rating']!,
                        style: context.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: context.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Helpers: search routing
  bool _isGeneralSearch(String query) {
    final generalKeywords = [
      'nha trang',
      'đà nẵng',
      'hồ chí minh',
      'hà nội',
      'hạ long',
      'phú quốc',
      'sapa',
      'hội an',
      'huế',
      'vũng tàu',
    ];

    return generalKeywords.any(
          (keyword) => query.toLowerCase().contains(keyword.toLowerCase()),
        ) &&
        !_isSpecificSearch(query);
  }

  bool _isSpecificSearch(String query) {
    final specificKeywords = [
      'resort',
      'hotel',
      'khách sạn',
      'nhà hàng',
      'restaurant',
      'tour',
      'spa',
      'vinpearl',
      'diamond',
      'intercontinental',
      'white rose',
      'thấp chăm',
      'po nagar',
    ];

    return specificKeywords.any(
      (keyword) => query.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  String _getSearchCategory(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('resort') ||
        lowerQuery.contains('khách sạn') ||
        lowerQuery.contains('hotel') ||
        lowerQuery.contains('vinpearl')) {
      return 'hotel';
    } else if (lowerQuery.contains('nhà hàng') ||
        lowerQuery.contains('restaurant') ||
        lowerQuery.contains('white rose')) {
      return 'restaurant';
    } else if (lowerQuery.contains('tour')) {
      return 'tour';
    } else if (lowerQuery.contains('spa') ||
        lowerQuery.contains('massage') ||
        lowerQuery.contains('thấp chăm') ||
        lowerQuery.contains('po nagar')) {
      return 'activity';
    }
    return 'general';
  }

  void _navigateToSpecificPage(String query, String category) {
    switch (category) {
      case 'hotel':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đi tới chi tiết khách sạn: $query')),
        );
        break;
      case 'restaurant':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang nhà hàng: $query')),
        );
        break;
      case 'tour':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourServiceOverviewScreen(searchQuery: query),
          ),
        );
        break;
      case 'activity':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang hoạt động: $query')),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchOverviewScreen(searchQuery: query),
          ),
        );
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    if (_isGeneralSearch(query)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchOverviewScreen(searchQuery: query.trim()),
        ),
      );
    } else {
      final category = _getSearchCategory(query);
      if (category == 'hotel') {
        setState(() => _selected = _QuickFilter.hotel);
      } else if (category == 'tour') {
        setState(() => _selected = _QuickFilter.tour);
      } else {
        _navigateToSpecificPage(query.trim(), category);
      }
    }
  }
}
