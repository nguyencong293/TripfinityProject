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
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.text = widget.searchQuery;
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
                      // Xử lý tìm kiếm mới
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

  // Tab Bar với các danh mục - THÊM NÚT BẢN ĐỒ
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
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Tour dịch vụ'),
              Tab(text: 'Khách sạn'),
              Tab(text: 'Hoạt động giải trí'),
              Tab(text: 'Nhà hàng'),
            ],
          ),
          // THÊM NÚT BẢN ĐỒ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ElevatedButton.icon(
              onPressed: () {
                // Điều hướng đến trang bản đồ
                _showMapView(context);
              },
              icon: Icon(LucideIcons.map, size: 18, color: Colors.white),
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

  // Tab Tổng quan - hiển thị tất cả loại kết quả
  Widget _buildOverviewTab(BuildContext context) {
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
            items: _getTourServices(),
            showMoreAction: () => _openTourOverview(context),
            itemType: 'tour',
          ),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Khách sạn',
            icon: LucideIcons.building,
            items: _getHotels(),
            showMoreAction: () => _openHotelOverview(context),
            itemType: 'hotel',
          ),
          const SizedBox(height: 24),
          // Dùng AttractionOverview cho "Hoạt động giải trí"
          _buildSectionWithResults(
            context,
            title: 'Hoạt động giải trí',
            icon: LucideIcons.ticket,
            items: _getActivities(),
            showMoreAction: () => _openAttractionOverview(context),
            itemType: 'attraction',
          ),
          const SizedBox(height: 24),
          _buildSectionWithResults(
            context,
            title: 'Nhà hàng',
            icon: LucideIcons.utensils,
            items: _getRestaurants(),
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
        builder: (_) =>
            TourServiceOverviewScreen(searchQuery: widget.searchQuery),
      ),
    );
  }

  void _openHotelOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            HotelOverviewSearchScreen(searchQuery: widget.searchQuery),
      ),
    );
  }

  void _openAttractionOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AttractionOverviewSearchScreen(searchQuery: widget.searchQuery),
      ),
    );
  }

  void _openRestaurantOverview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RestaurantOverviewSearchScreen(searchQuery: widget.searchQuery),
      ),
    );
  }

  // ===== NAVIGATION TO DETAIL SCREENS =====
  void _openHotelDetail(Map<String, dynamic> hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotel: {
            'name': hotel['name']?.toString() ?? '',
            'image':
                hotel['image']?.toString() ?? 'assets/images/onboarding1.png',
            'price': hotel['price']?.toString() ?? '—',
          },
          activeAmenities: {'Wifi miễn phí', 'Bể bơi'},
        ),
      ),
    );
  }

  void _openRestaurantDetail(Map<String, dynamic> restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurant: {
            'name': restaurant['name']?.toString() ?? '',
            'location': restaurant['location']?.toString() ?? '',
            'rating': restaurant['rating']?.toString() ?? '4.0',
            'type': 'restaurant',
            'cuisine': 'Âu', // Default cuisine
            'price': restaurant['price']?.toString() ?? '100000 đ',
            'reviews': '(320)', // Default reviews
            'tag': 'Bar', // Default tag
            'image':
                restaurant['image']?.toString() ??
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
    // Convert and ensure proper data types for TourServiceDetailScreen
    final tourData = {
      'name': tour['name']?.toString() ?? '',
      'location': tour['location']?.toString() ?? '',
      'rating': tour['rating']?.toString() ?? '4.0',
      'price': tour['price']?.toString() ?? '0đ',
      'image': tour['image']?.toString() ?? 'assets/images/onboarding1.png',
      'duration': tour['duration']?.toString() ?? '1 ngày',
      'description': tour['description']?.toString() ?? '',
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(
          tour: tourData,
          activeTourTypes: const {'City tour'},
          activeServices: const {},
          activeDifficulty: null,
        ),
      ),
    );
  }

  void _openAttractionDetail(Map<String, dynamic> attraction) {
    // Convert to proper format for AttractionsOverviewDetailScreen
    final attractionData = {
      'name': attraction['name']?.toString() ?? '',
      'location': attraction['location']?.toString() ?? '',
      'rating': attraction['rating'] is num
          ? attraction['rating']
          : double.tryParse(attraction['rating']?.toString() ?? '4.0') ?? 4.0,
      'price': attraction['price'] != null
          ? _extractPrice(attraction['price'].toString())
          : 0,
      'description':
          'Điểm tham quan tuyệt vời tại ${attraction['location']?.toString() ?? 'Nha Trang'}',
      'image':
          attraction['image']?.toString() ?? 'assets/images/onboarding3.png',
      'types': ['Tham quan', 'Giải trí'],
      'services': ['Chụp ảnh'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Solo', 'Cặp đôi'],
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
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
    // Remove all non-digit characters and convert to int
    final numbers = priceString.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(numbers) ?? 0;
  }

  // Card địa điểm chính
  Widget _buildLocationCard(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.end, // Align content to bottom
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
            const SizedBox(height: 8), // Reduced from 12
            Text(
              widget.searchQuery,
              style: context.h4Style.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16, // Reduced font size
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              'Nha Trang nổi tiếng nhất với những bãi biển cát trắng mịn, làn nước trong xanh, công viên giải trí, cở sở vui chơi và những tòm bùn, chơi golf và khu nghỉ dưỡng.',
              style: context.bodyTwoStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3, // Reduced line height
                fontSize: 11, // Reduced font size
              ),
              maxLines: 2, // Reduced from 3
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12), // Reduced from 16
            Wrap(
              spacing: 8, // Reduced spacing
              runSpacing: 4, // Added run spacing
              children: [
                _buildInfoChip(context, LucideIcons.star, '4.1'),
                _buildInfoChip(context, LucideIcons.mapPin, 'Việt Nam, Châu Á'),
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

  // Section với kết quả và nút "Xem thêm"
  Widget _buildSectionWithResults(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required VoidCallback showMoreAction,
    required String itemType, // Add itemType parameter
  }) {
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
        ...items
            .take(2)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildResultCard(
                  context,
                  item,
                  itemType,
                ), // Pass itemType
              ),
            ),
      ],
    );
  }

  // Card kết quả tìm kiếm - UPDATED WITH NAVIGATION
  Widget _buildResultCard(
    BuildContext context,
    Map<String, dynamic> item,
    String itemType,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to appropriate detail screen based on itemType
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
                child: Image.asset(
                  item['image'] ?? 'assets/images/onboarding1.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: context.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        LucideIcons.image,
                        color: context.primaryColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '',
                      style: context.bodyOneStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['location'] ?? '',
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
                          item['rating']?.toString() ?? '4.0',
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        if (item['price'] != null) ...[
                          const SizedBox(width: 12),
                          Text(
                            item['price'],
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

  // Tab Tour dịch vụ
  Widget _buildTourServicesTab(BuildContext context) {
    return _buildListTab(context, _getTourServices(), 'tour');
  }

  // Tab Khách sạn
  Widget _buildHotelsTab(BuildContext context) {
    return _buildListTab(context, _getHotels(), 'hotel');
  }

  // Tab Hoạt động giải trí
  Widget _buildActivitiesTab(BuildContext context) {
    return _buildListTab(context, _getActivities(), 'attraction');
  }

  // Tab Nhà hàng
  Widget _buildRestaurantsTab(BuildContext context) {
    return _buildListTab(context, _getRestaurants(), 'restaurant');
  }

  // Template cho tab hiển thị danh sách - UPDATED WITH NAVIGATION
  Widget _buildListTab(
    BuildContext context,
    List<Map<String, dynamic>> items,
    String itemType,
  ) {
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
        builder: (context) => SearchMapScreen(searchQuery: widget.searchQuery),
      ),
    );
  }

  // Dữ liệu mẫu cho Tour dịch vụ
  List<Map<String, dynamic>> _getTourServices() {
    return [
      {
        'name': 'Tour Nha Trang 1 ngày',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.5,
        'price': '850.000đ',
        'image': 'assets/images/onboarding1.png',
        'duration': '1 ngày',
        'description': 'Tour tham quan Nha Trang trong 1 ngày',
      },
      {
        'name': 'Du thuyền Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.7,
        'price': '1.200.000đ',
        'image': 'assets/images/onboarding2.png',
        'duration': '4 giờ',
        'description': 'Trải nghiệm du thuyền sang trọng',
      },
      {
        'name': 'Tour tham quan 4 đảo',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.3,
        'price': '650.000đ',
        'image': 'assets/images/onboarding3.png',
        'duration': '1 ngày',
        'description': 'Khám phá 4 đảo đẹp nhất Nha Trang',
      },
      {
        'name': 'Tour Vinpearl Land',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.4,
        'price': '1.500.000đ',
        'image': 'assets/images/onboarding4.png',
        'duration': '1 ngày',
        'description': 'Vui chơi tại công viên giải trí hàng đầu',
      },
    ];
  }

  // Dữ liệu mẫu cho Khách sạn
  List<Map<String, dynamic>> _getHotels() {
    return [
      {
        'name': 'Mia Resort Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.2,
        'price': '2.500.000đ/đêm',
        'image': 'assets/images/onboarding2.png',
      },
      {
        'name': 'Vinpearl Resort Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.0,
        'price': '3.200.000đ/đêm',
        'image': 'assets/images/onboarding4.png',
      },
      {
        'name': 'InterContinental Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.6,
        'price': '4.800.000đ/đêm',
        'image': 'assets/images/onboarding1.png',
      },
      {
        'name': 'Sheraton Nha Trang Hotel',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.3,
        'price': '3.800.000đ/đêm',
        'image': 'assets/images/onboarding3.png',
      },
    ];
  }

  // Dữ liệu mẫu cho Hoạt động giải trí
  List<Map<String, dynamic>> _getActivities() {
    return [
      {
        'name': 'Tháp Bà Ponagar',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.0,
        'price': '30.000đ',
        'image': 'assets/images/onboarding3.png',
      },
      {
        'name': 'Vinpearl Land Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.5,
        'price': '800.000đ',
        'image': 'assets/images/onboarding4.png',
      },
      {
        'name': 'Bãi biển Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.3,
        'price': 'Miễn phí',
        'image': 'assets/images/onboarding1.png',
      },
      {
        'name': 'Long Sơn Pagoda',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.1,
        'price': 'Miễn phí',
        'image': 'assets/images/onboarding2.png',
      },
    ];
  }

  // Dữ liệu mẫu cho Nhà hàng
  List<Map<String, dynamic>> _getRestaurants() {
    return [
      {
        'name': 'Banh Can 51 To Hien Thanh',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.0,
        'price': '50.000đ',
        'image': 'assets/images/onboarding3.png',
      },
      {
        'name': 'White Rose Restaurant',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.3,
        'price': '200.000đ',
        'image': 'assets/images/onboarding2.png',
      },
      {
        'name': 'Livin- Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.0,
        'price': '150.000đ',
        'image': 'assets/images/onboarding4.png',
      },
      {
        'name': 'Nha Trang Xưa',
        'location': 'Nha Trang, Việt Nam',
        'rating': 4.2,
        'price': '180.000đ',
        'image': 'assets/images/onboarding1.png',
      },
    ];
  }
}
