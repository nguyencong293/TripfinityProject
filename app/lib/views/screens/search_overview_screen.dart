import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/views/screens/attractions_overview_search_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/hotel_overview_search_screen.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_search_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/search_map_screen.dart';
import 'package:app/views/screens/tour_service_overview_search_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// API centralized
import 'package:app/services/search_api_service.dart';

class SearchOverviewScreen extends StatefulWidget {
  final String searchQuery;

  const SearchOverviewScreen({super.key, required this.searchQuery});

  @override
  State<SearchOverviewScreen> createState() => _SearchOverviewScreenState();
}

class _SearchOverviewScreenState extends State<SearchOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // State
  bool _loading = false;
  String? _error;
  String _currentQuery = '';

  // Area info (if present)
  String? _areaName;
  String? _areaCountryOrSlug;
  String? _areaRating; // backend không trả rating cho area -> fallback '0.0'

  // Lists
  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _attractions = [];

  bool get _hasAnyResults =>
      _hotels.isNotEmpty ||
      _restaurants.isNotEmpty ||
      _tours.isNotEmpty ||
      _attractions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _currentQuery = widget.searchQuery;
    _searchController.text = widget.searchQuery;
    _fetchAll(_currentQuery);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context),
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
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(context),
                    _buildTourServicesTab(context),
                    _buildHotelsTab(context),
                    _buildActivitiesTab(context),
                    _buildRestaurantsTab(context),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Header với search bar và nút back
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: context.textDisabledColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: context.textPrimaryColor,
                ),
              ),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.dividerColor, width: 1),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      hintStyle: context.bodyOneStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        color: context.textSecondaryColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: context.bodyOneStyle,
                    onSubmitted: (value) {
                      final q = value.trim();
                      if (q.isEmpty) return;
                      setState(() {
                        _currentQuery = q;
                      });
                      _fetchAll(q);
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.share2, color: context.textPrimaryColor),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(LucideIcons.heart, color: context.textPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Tab Bar với các danh mục - ẨN NÚT BẢN ĐỒ KHI KHÔNG CÓ KẾT QUẢ
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: context.cardBackgroundColor,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: context.primaryColor,
            unselectedLabelColor: context.textSecondaryColor,
            labelStyle: context.bodyOneStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: context.bodyOneStyle,
            indicatorColor: context.primaryColor,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Tour dịch vụ'),
              Tab(text: 'Khách sạn'),
              Tab(text: 'Hoạt động giải trí'),
              Tab(text: 'Nhà hàng'),
            ],
          ),
          if (_hasAnyResults)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showMapView(context);
                },
                icon: const Icon(
                  LucideIcons.map,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Bản đồ',
                  style: context.bodyOneStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tab Tổng quan - ẨN HOÀN TOÀN KHI KHÔNG CÓ KẾT QUẢ
  Widget _buildOverviewTab(BuildContext context) {
    if (!_hasAnyResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Không có kết quả phù hợp',
            style: context.bodyOneStyle.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationCard(context),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Tour dịch vụ',
            icon: LucideIcons.bus,
            items: _tours,
            showMoreAction: () => _openTourOverview(context),
            itemType: 'tour',
          ),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Khách sạn',
            icon: LucideIcons.building,
            items: _hotels,
            showMoreAction: () => _openHotelOverview(context),
            itemType: 'hotel',
          ),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Hoạt động giải trí',
            icon: LucideIcons.ticket,
            items: _attractions,
            showMoreAction: () => _openAttractionOverview(context),
            itemType: 'attraction',
          ),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Nhà hàng',
            icon: LucideIcons.utensils,
            items: _restaurants,
            showMoreAction: () => _openRestaurantOverview(context),
            itemType: 'restaurant',
          ),
        ],
      ),
    );
  }

  void _openTourOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceOverviewScreen(searchQuery: _currentQuery),
      ),
    );
  }

  void _openHotelOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelOverviewSearchScreen(searchQuery: _currentQuery),
      ),
    );
  }

  void _openAttractionOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AttractionOverviewSearchScreen(searchQuery: _currentQuery),
      ),
    );
  }

  void _openRestaurantOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RestaurantOverviewSearchScreen(searchQuery: _currentQuery),
      ),
    );
  }

  // ===== NAVIGATION TO DETAIL SCREENS =====
  void _openHotelDetail(Map<String, dynamic> hotel) {
    final id = _parseId(hotel, ['hotelId', 'id', 'hotel_id']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id, // dynamic fetch if available
          hotel: {
            'name': hotel['name']?.toString() ?? '',
            'image':
                hotel['image']?.toString() ??
                hotel['imageUrl']?.toString() ??
                'assets/images/onboarding1.png',
            'price': hotel['price']?.toString() ?? '—',
          },
          activeAmenities: const {'Wifi miễn phí', 'Bể bơi'},
        ),
      ),
    );
  }

  void _openRestaurantDetail(Map<String, dynamic> restaurant) {
    final id = _parseId(restaurant, ['restaurantId', 'id', 'restaurant_id']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurantId: id,
          restaurant: {
            'name': restaurant['name']?.toString() ?? '',
            'location': restaurant['location']?.toString() ?? '',
            'rating': _getRatingString(restaurant['rating']),
            'type': 'restaurant',
            'cuisine': restaurant['cuisine']?.toString() ?? '—',
            'price': restaurant['price']?.toString() ?? '',
            'reviews': '(320)', // fallback
            'tag': restaurant['tag']?.toString() ?? '',
            'image':
                restaurant['image']?.toString() ??
                restaurant['imageUrl']?.toString() ??
                'assets/images/onboarding4.png',
          },
          activeCuisines: const {'Âu'},
          activeServices: const {'Bar'},
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
    final id = _parseId(tour, ['tourId', 'id', 'tour_id']);
    final tourData = {
      'name': tour['name']?.toString() ?? '',
      'location': tour['location']?.toString() ?? '',
      'rating': _getRatingString(tour['rating']),
      'price': tour['price']?.toString() ?? '',
      'image':
          tour['image']?.toString() ??
          tour['imageUrl']?.toString() ??
          'assets/images/onboarding1.png',
      'duration': tour['duration']?.toString() ?? '',
      'description': tour['description']?.toString() ?? '',
      'tourId': id, // carry id in fallback too
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(tourId: id, tour: tourData),
      ),
    );
  }

  void _openAttractionDetail(Map<String, dynamic> attraction) {
    final id = _parseId(attraction, ['attractionId', 'id', 'attraction_id']);
    final priceInt = _extractPrice(attraction['price']?.toString() ?? '');
    final attractionData = {
      'name': attraction['name']?.toString() ?? '',
      'location': attraction['location']?.toString() ?? '',
      'rating': double.tryParse(_getRatingString(attraction['rating'])) ?? 0.0,
      'price': priceInt,
      'description':
          attraction['description']?.toString() ??
          'Điểm tham quan tại ${attraction['location']?.toString() ?? ''}',
      'image':
          attraction['image']?.toString() ??
          attraction['imageUrl']?.toString() ??
          'assets/images/onboarding3.png',
      'types': attraction['types'] is List
          ? List.from(attraction['types'])
          : ['Tham quan'],
      'services': attraction['services'] is List
          ? List.from(attraction['services'])
          : ['Chụp ảnh'],
      'times': attraction['times'] is List
          ? List.from(attraction['times'])
          : ['Sáng', 'Chiều'],
      'suit': attraction['suit'] is List
          ? List.from(attraction['suit'])
          : ['Solo', 'Cặp đôi'],
      'attractionId': id,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
          attractionId: id, // dynamic fetch if available
          attraction: attractionData,
          activeTypes: const {},
          activeServices: const {},
          activeTimes: const {},
          activeSuitability: const {},
        ),
      ),
    );
  }

  // Helper method to extract price from string
  int _extractPrice(String priceString) {
    final numbers = priceString.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(numbers) ?? 0;
  }

  // Card địa điểm chính
  Widget _buildLocationCard(BuildContext context) {
    final title = _areaName ?? _currentQuery;
    final sub = _areaCountryOrSlug ?? 'Việt Nam, Châu Á';
    final rating = _areaRating ?? '0.0';

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/onboarding1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tổng quan',
                style: context.captionStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.h4Style.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Khám phá các địa điểm nổi bật và dịch vụ tại đây.',
              style: context.bodyTwoStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInfoChip(context, LucideIcons.star, rating),
                _buildInfoChip(context, LucideIcons.mapPin, sub),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FIX: Update _buildInfoChip to have proper constraints
  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: context.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Section với kết quả và nút "Xem thêm" (ẩn nút khi items trống)
  Widget _buildSectionWithResults(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required VoidCallback showMoreAction,
    required String itemType,
  }) {
    final hasItems = items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: context.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: context.h5Style.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            const Spacer(),
            if (hasItems)
              TextButton(
                onPressed: showMoreAction,
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
        if (!hasItems)
          Text(
            'Không có kết quả',
            style: context.captionStyle.copyWith(
              color: context.textSecondaryColor,
            ),
          )
        else
          ...items
              .take(2)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildResultCard(context, item, itemType),
                ),
              ),
      ],
    );
  }

  // Card kết quả tìm kiếm - ưu tiên imageUrl nếu có
  Widget _buildResultCard(
    BuildContext context,
    Map<String, dynamic> item,
    String itemType,
  ) {
    final imageUrl = (item['imageUrl'] ?? '').toString();
    final hasNetwork = imageUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          switch (itemType) {
            case 'hotel':
              _openHotelDetail(item);
              break;
            case 'restaurant':
              _openRestaurantDetail(item);
              break;
            case 'tour':
              _openTourDetail(item);
              break;
            case 'attraction':
              _openAttractionDetail(item);
              break;
            default:
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: hasNetwork
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(context),
                      )
                    : Image.asset(
                        item['image']?.toString() ??
                            'assets/images/onboarding1.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(context),
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
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['location']?.toString() ?? '',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          size: 14,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRatingString(item['rating']),
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        if ((item['price']?.toString() ?? '').isNotEmpty) ...[
                          const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: context.primaryColor.withValues(alpha: 0.1),
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  // Tab Tour dịch vụ
  Widget _buildTourServicesTab(BuildContext context) {
    return _buildListTab(context, _tours, 'tour');
  }

  // Tab Khách sạn
  Widget _buildHotelsTab(BuildContext context) {
    return _buildListTab(context, _hotels, 'hotel');
  }

  // Tab Hoạt động giải trí
  Widget _buildActivitiesTab(BuildContext context) {
    return _buildListTab(context, _attractions, 'attraction');
  }

  // Tab Nhà hàng
  Widget _buildRestaurantsTab(BuildContext context) {
    return _buildListTab(context, _restaurants, 'restaurant');
  }

  // Template cho tab hiển thị danh sách
  Widget _buildListTab(
    BuildContext context,
    List<Map<String, dynamic>> items,
    String itemType,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Không có kết quả',
          style: context.captionStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildResultCard(context, items[index], itemType);
      },
    );
  }

  // Hàm hiển thị bản đồ
  void _showMapView(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchMapScreen(searchQuery: _currentQuery),
      ),
    );
  }

  // ===== API =====
  Future<void> _fetchAll(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query);

      // Area
      String? areaName;
      String? areaCountryOrSlug;
      String areaRating = '0.0';
      if (data['area'] is Map) {
        final area = Map<String, dynamic>.from(data['area'] as Map);
        areaName = area['name']?.toString();
        // backend trả slug/country trong area summary; ưu tiên country nếu có
        areaCountryOrSlug =
            area['country']?.toString() ?? area['slug']?.toString();
      }

      // Lists
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
            'hotelId': m['hotelId'] ?? m['id'] ?? m['hotel_id'],
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
            'restaurantId': m['restaurantId'] ?? m['id'] ?? m['restaurant_id'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'restaurant',
            'cuisine': m['cuisineType']?.toString(),
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
            'tourId': m['tourId'] ?? m['id'] ?? m['tour_id'],
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
            'attractionId': m['attractionId'] ?? m['id'] ?? m['attraction_id'],
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
        _areaName = areaName;
        _areaCountryOrSlug = areaCountryOrSlug;
        _areaRating = areaRating;

        _hotels = hotels;
        _restaurants = restaurants;
        _tours = tours;
        _attractions = attractions;

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải dữ liệu. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
  }

  // ===== Utils =====

  // Helper to parse id from common keys
  int? _parseId(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final p = int.tryParse(v);
        if (p != null) return p;
      }
    }
    return null;
  }

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
