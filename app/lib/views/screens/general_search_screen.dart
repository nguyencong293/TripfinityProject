import 'package:app/views/screens/attractions_overview_search_screen.dart';
import 'package:app/views/screens/tour_service_overview_search_screen.dart';
import 'package:app/views/screens/restaurant_overview_search_screen.dart';
import 'package:app/views/screens/hotel_overview_search_screen.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

// Screens
import 'search_overview_screen.dart';

// Networking
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use centralized API service and config
import 'package:app/services/search_api_service.dart';

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

  // ====== Dynamic data ======
  bool _loading = false;
  String? _error;
  bool _hasSearched = false; // Chỉ hiển thị kết quả sau khi user tìm

  // Top results
  List<Map<String, dynamic>> _hotelItems = [];
  List<Map<String, dynamic>> _restaurantItems = [];
  List<Map<String, dynamic>> _tourItems = [];
  List<Map<String, dynamic>> _attractionItems = [];
  List<Map<String, dynamic>> _destinationItems = []; // từ "area" trong response

  @override
  void initState() {
    super.initState();
    // Không đặt mặc định "Nha Trang", không tự fetch ban đầu
    _searchController.text = '';
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
                    setState(() {
                      // Xoá kết quả và ẩn khu vực kết quả
                      _hotelItems = [];
                      _restaurantItems = [];
                      _tourItems = [];
                      _attractionItems = [];
                      _destinationItems = [];
                      _error = null;
                      _loading = false;
                      _hasSearched = false;
                    });
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
        onSubmitted: (value) => _performSearch(value),
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

  // Results section (dynamic theo filter)
  Widget _buildSearchResults(BuildContext context) {
    // Trước khi user tìm kiếm: ẩn hoàn toàn khu vực kết quả (không spinner, không lỗi)
    if (!_hasSearched) return const SizedBox.shrink();

    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.primaryColor,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      // Sau khi tìm nếu lỗi mới hiển thị lỗi
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          _error!,
          style: context.captionStyle.copyWith(color: Colors.red),
        ),
      );
    }

    List<Map<String, dynamic>> items;
    switch (_selected) {
      case _QuickFilter.hotel:
        items = _hotelItems.take(5).toList();
        break;
      case _QuickFilter.restaurant:
        items = _restaurantItems.take(5).toList();
        break;
      case _QuickFilter.tour:
        items = _tourItems.take(5).toList();
        break;
      case _QuickFilter.attraction:
        items = _attractionItems.take(5).toList();
        break;
      case _QuickFilter.all:
        items = _composeAllItemsMax5();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Không có kết quả',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),
        if (items.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = (item['imageUrl'] ?? '').toString();
              final hasNetwork = imageUrl.startsWith('http');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    if (item['type'] == 'hotel') {
                      _openHotelDetail(_convertToStringMap(item));
                    } else if (item['type'] == 'restaurant') {
                      _openRestaurantDetail(_convertToStringMap(item));
                    } else if (item['type'] == 'tour') {
                      _openTourDetail(item);
                    } else if (item['type'] == 'attraction') {
                      _openAttractionDetail(item);
                    } else if (item['type'] == 'destination') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchOverviewScreen(
                            searchQuery: item['name'].toString(),
                          ),
                        ),
                      );
                    } else {
                      _navigateToSpecificPage(
                        item['name'].toString(),
                        item['type'].toString(),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasNetwork
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    LucideIcons.image,
                                    color: context.primaryColor,
                                    size: 20,
                                  ),
                                ),
                              )
                            : Image.asset(
                                item['image']?.toString() ??
                                    'assets/images/onboarding1.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: context.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    LucideIcons.image,
                                    color: context.primaryColor,
                                    size: 20,
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
                              item['name']?.toString() ?? '',
                              style: context.bodyOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['location']?.toString() ?? '',
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
                                  _getRatingString(item['rating']),
                                  style: context.captionStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item['type'] == 'hotel' &&
                                    (item['price']?.toString() ?? '')
                                        .isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    item['price'].toString(),
                                    style: context.captionStyle.copyWith(
                                      color: context.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
              // Luôn điều hướng sang trang tổng quan tìm kiếm
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchOverviewScreen(searchQuery: query),
                ),
              );
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
                      builder: (_) =>
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        'cuisine': 'Âu',
        'price': '120000 đ',
        'reviews': '(320)',
        'tag': 'Bar',
      },
      {
        'name': 'Vinpearl - Resort Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.2',
        'type': 'hotel',
        'price': '3.200.000đ/đêm',
      },
      {
        'name': 'Tháp Chăm Po Nagar',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.3, // Keep as numeric for recent attraction items
        'type': 'attraction',
        'price': 25000, // Keep as numeric
        'description': 'Tháp cổ Chăm Po Nagar được xây dựng từ thế kỷ 8-12',
        'types': ['Tôn giáo', 'Kiến trúc'],
        'services': ['Chụp ảnh'],
        'times': ['Sáng', 'Chiều'],
        'suit': ['Solo', 'Cặp đôi'],
      },
    ];

    final item = items[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          if (item['type'] == 'hotel') {
            _openHotelDetail(_convertToStringMap(item));
          } else if (item['type'] == 'restaurant') {
            _openRestaurantDetail(_convertToStringMap(item));
          } else if (item['type'] == 'attraction') {
            _openAttractionDetail(item);
          } else {
            _navigateToSpecificPage(
              item['name'].toString(),
              item['type'].toString(),
            );
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
                    item['name'].toString(),
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['location'].toString(),
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
                        _getRatingString(item['rating']),
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

  // ===== NAVIGATION HELPERS =====
  void _openHotelDetail(Map<String, String> hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotel: {
            'name': hotel['name'] ?? '',
            'image':
                hotel['image'] ??
                hotel['imageUrl'] ??
                'assets/images/onboarding1.png',
            'price': hotel['price'] ?? '—',
          },
          activeAmenities: {'Wifi miễn phí', 'Bể bơi'},
        ),
      ),
    );
  }

  void _openRestaurantDetail(Map<String, String> restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurant: restaurant,
          activeCuisines: {restaurant['cuisine'] ?? ''},
          activeServices: {restaurant['tag'] ?? ''},
          activeDietaries: const {},
          activeStars: const {},
          activeOpenNow: false,
          activeReservation: false,
          activeTakeAway: false,
        ),
      ),
    );
  }

  void _openTourDetail(Map<String, dynamic> tour) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(
          tour: tour,
          activeTourTypes: {
            tour['type']?.toString() ?? '',
          }.where((s) => s.isNotEmpty).toSet(),
          activeServices: const {},
          activeDifficulty: null,
        ),
      ),
    );
  }

  void _openAttractionDetail(Map<String, dynamic> attraction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
          attraction: attraction,
          activeTypes: const {},
          activeServices: const {},
          activeTimes: const {},
          activeSuitability: const {},
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====
  // Gom danh sách "Tất cả" tối đa 5, ưu tiên area trước, sau đó round-robin các loại
  List<Map<String, dynamic>> _composeAllItemsMax5() {
    final List<Map<String, dynamic>> result = [];
    if (_destinationItems.isNotEmpty) {
      result.add(_destinationItems.first); // area lên đầu nếu có
    }
    final lists = [
      _hotelItems.iterator,
      _restaurantItems.iterator,
      _tourItems.iterator,
      _attractionItems.iterator,
    ];

    // Round-robin cho đến khi đủ 5 hoặc hết dữ liệu
    while (result.length < 5) {
      bool progressed = false;
      for (final it in lists) {
        if (result.length >= 5) break;
        if (it.moveNext()) {
          result.add(it.current);
          progressed = true;
          if (result.length >= 5) break;
        }
      }
      if (!progressed) break; // không còn phần tử nào
    }
    return result;
    // Lưu ý: nếu muốn ưu tiên thứ tự khác, có thể đổi thứ tự lists
  }

  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is String) return rating;
    if (rating is num) {
      return rating.toString();
    }
    return '0.0';
  }

  Map<String, String> _convertToStringMap(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  String _getSearchCategory(String query) {
    final q = query.toLowerCase();
    if (q.contains('resort') ||
        q.contains('khách sạn') ||
        q.contains('hotel') ||
        q.contains('vinpearl')) {
      return 'hotel';
    }
    if (q.contains('nhà hàng') ||
        q.contains('restaurant') ||
        q.contains('white rose')) {
      return 'restaurant';
    }
    if (q.contains('tour')) {
      return 'tour';
    }
    if (q.contains('spa') ||
        q.contains('massage') ||
        q.contains('tháp chăm') ||
        q.contains('po nagar')) {
      return 'activity';
    }
    return 'general';
  }

  void _navigateToSpecificPage(String query, String category) {
    switch (category) {
      case 'hotel':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HotelOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case 'restaurant':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantOverviewSearchScreen(searchQuery: query),
          ),
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AttractionOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchOverviewScreen(searchQuery: query),
          ),
        );
    }
  }

  // Submit search: ở màn hình này chỉ tải và hiển thị top 5, KHÔNG điều hướng
  void _performSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _hasSearched = true;
    });

    // Điều chỉnh filter nếu query mang ý nghĩa cụ thể
    final category = _getSearchCategory(trimmed);
    if (category == 'hotel') {
      _selected = _QuickFilter.hotel;
    } else if (category == 'tour') {
      _selected = _QuickFilter.tour;
    } else if (category == 'restaurant') {
      _selected = _QuickFilter.restaurant;
    } else if (category == 'activity') {
      _selected = _QuickFilter.attraction;
    } else {
      _selected = _QuickFilter.all; // chung chung => all, ưu tiên area lên đầu
    }

    _fetchSearch(trimmed);
  }

  // ===== API =====
  Future<void> _fetchSearch(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query);

      // Map "area" -> destination item (hiện đầu tiên nếu có)
      final List<Map<String, dynamic>> dst = [];
      if (data['area'] is Map) {
        final area = Map<String, dynamic>.from(data['area'] as Map);
        dst.add({
          'name': area['name']?.toString() ?? 'Khu vực',
          'location': area['slug']?.toString() ?? '',
          'rating': '0.0', // backend không trả rating cho area -> set mặc định
          'type': 'destination',
          'image': 'assets/images/onboarding1.png',
          'imageUrl': null, // không có thumbnailUrl cho area
        });
      }

      List<Map<String, dynamic>> hotels = [];
      List<Map<String, dynamic>> restaurants = [];
      List<Map<String, dynamic>> tours = [];
      List<Map<String, dynamic>> attractions = [];

      if (data['hotels'] is List) {
        hotels = List.from(data['hotels']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'hotel',
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding2.png',
          };
        }).toList();
      }

      if (data['restaurants'] is List) {
        restaurants = List.from(data['restaurants']).map<Map<String, dynamic>>((
          e,
        ) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'restaurant',
            'cuisine': m['cuisineType']?.toString(), // nếu có
            'price': _formatPrice(price, currency),
            'tag': (m['badges'] is List && (m['badges'] as List).isNotEmpty)
                ? (m['badges'] as List).first.toString()
                : null,
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding3.png',
          };
        }).toList();
      }

      if (data['tours'] is List) {
        tours = List.from(data['tours']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'tour',
            'duration': (m['durationDays']?.toString() ?? ''),
            'price': _formatPrice(price, currency),
            'description': m['itineraryOverview']?.toString() ?? '',
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding1.png',
          };
        }).toList();
      }

      if (data['attractions'] is List) {
        attractions = List.from(data['attractions']).map<Map<String, dynamic>>((
          e,
        ) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'attraction',
            'price': _formatPrice(price, currency),
            'description': m['serviceDescription']?.toString() ?? '',
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding4.png',
            'types': m['types'] is List ? List.from(m['types']) : [],
            'services': m['services'] is List ? List.from(m['services']) : [],
            'times': m['times'] is List ? List.from(m['times']) : [],
            'suit': m['suit'] is List ? List.from(m['suit']) : [],
          };
        }).toList();
      }

      setState(() {
        _destinationItems = dst;
        _hotelItems = hotels;
        _restaurantItems = restaurants;
        _tourItems = tours;
        _attractionItems = attractions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        // backend yêu cầu Authorization bắt buộc -> 401 nếu thiếu token
        _error = 'Không thể tải dữ liệu. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
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
