import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

class SearchMapScreen extends StatefulWidget {
  final String searchQuery;

  const SearchMapScreen({super.key, required this.searchQuery});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
  int? selectedPinIndex;

  // Dữ liệu mẫu cho các địa điểm trên bản đồ
  final List<Map<String, dynamic>> _mapLocations = [
    {
      'id': 1,
      'name': 'Vinpearl Land Nha Trang',
      'type': 'Hoạt động giải trí',
      'rating': 4.4,
      'price': '800.000đ',
      'image': 'assets/images/onboarding3.png',
      'position': const Offset(0.3, 0.4),
    },
    {
      'id': 2,
      'name': 'Mia Resort Nha Trang',
      'type': 'Khách sạn',
      'rating': 4.2,
      'price': '2.500.000đ/đêm',
      'image': 'assets/images/onboarding2.png',
      'position': const Offset(0.6, 0.3),
    },
    {
      'id': 3,
      'name': 'Sailing Club Restaurant',
      'type': 'Nhà hàng',
      'rating': 4.5,
      'price': '500.000đ',
      'image': 'assets/images/onboarding1.png',
      'position': const Offset(0.5, 0.6),
    },
    {
      'id': 4,
      'name': 'Tour 4 đảo Nha Trang',
      'type': 'Tour dịch vụ',
      'rating': 4.3,
      'price': '650.000đ',
      'image': 'assets/images/onboarding4.png',
      'position': const Offset(0.7, 0.7),
    },
    {
      'id': 5,
      'name': 'Tháp Bà Ponagar',
      'type': 'Hoạt động giải trí',
      'rating': 4.1,
      'price': '50.000đ',
      'image': 'assets/images/onboarding3.png',
      'position': const Offset(0.4, 0.2),
    },
  ];

  // Chiều cao ước tính của một item và header
  final double _estimatedItemHeight = 100;
  final double _headerHeight = 96;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Tính minChildSize dựa trên chiều cao của header và 1 item
    final double minChildSize =
        (_headerHeight + _estimatedItemHeight) / screenHeight;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // Bản đồ chính
          _buildMapView(context),

          // Header với nút back và search
          _buildHeader(context),

          // Bottom sheet có thể kéo
          _buildDraggableBottomSheet(context, minChildSize),
        ],
      ),
    );
  }

  // Header với nút back và search bar
  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: context.textPrimaryColor,
                ),
              ),
              Expanded(
                child: Text(
                  'Bản đồ: ${widget.searchQuery}',
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Xử lý search trên bản đồ
                },
                icon: Icon(LucideIcons.search, color: context.textPrimaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bản đồ với các pin địa điểm
  Widget _buildMapView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/onboarding1.png',
          ), // Ảnh nền giả lập bản đồ
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              context.primaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Stack(
          children: _mapLocations.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> location = entry.value;
            return _buildMapPin(context, location, index);
          }).toList(),
        ),
      ),
    );
  }

  // Pin địa điểm trên bản đồ
  Widget _buildMapPin(
    BuildContext context,
    Map<String, dynamic> location,
    int index,
  ) {
    bool isSelected = selectedPinIndex == index;
    Offset position = location['position'];

    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx - 25,
      top: MediaQuery.of(context).size.height * position.dy - 50,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPinIndex = index;
          });
          _showPinDetails(location);
        },
        child: Column(
          children: [
            // Popup thông tin khi được chọn
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  location['name'],
                  style: context.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),

            if (isSelected) const SizedBox(height: 4),

            // Pin icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor
                    : context.cardBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: context.primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _getIconForType(location['type']),
                color: isSelected ? Colors.white : context.primaryColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lấy icon theo loại địa điểm
  IconData _getIconForType(String type) {
    switch (type) {
      case 'Tour dịch vụ':
        return LucideIcons.bus;
      case 'Khách sạn':
        return LucideIcons.building;
      case 'Hoạt động giải trí':
        return LucideIcons.ticket;
      case 'Nhà hàng':
        return LucideIcons.utensils;
      default:
        return LucideIcons.mapPin;
    }
  }

  // Bottom sheet có thể kéo
  Widget _buildDraggableBottomSheet(BuildContext context, double minChildSize) {
    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: 0.3,
      minChildSize: minChildSize,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              // Expanded drag handle area
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // This allows dragging from the entire header area
                },
                child: Container(
                  color: Colors.transparent,
                  height: 40, // Increased height for easier dragging
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // Tiêu đề
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Text(
                      'Kết quả tìm kiếm',
                      style: context.h5Style.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_mapLocations.length} địa điểm',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách kết quả với physics để xử lý cả drag và scroll
              Expanded(
                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    // Cho phép bottom sheet kéo khi scroll đến đầu hoặc cuối
                    return true;
                  },
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const ClampingScrollPhysics(),
                    itemCount: _mapLocations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildLocationCard(
                        context,
                        _mapLocations[index],
                        index,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Card địa điểm trong bottom sheet
  Widget _buildLocationCard(
    BuildContext context,
    Map<String, dynamic> location,
    int index,
  ) {
    bool isSelected = selectedPinIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? context.primaryColor.withValues(alpha: 0.1)
            : context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.primaryColor
              : context.dividerColor.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPinIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  location['image'] ?? 'assets/images/onboarding1.png',
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
                      location['name'] ?? '',
                      style: context.bodyOneStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['type'] ?? '',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
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
                          location['rating']?.toString() ?? '4.0',
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          location['price'] ?? '',
                          style: context.captionStyle.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                _getIconForType(location['type']),
                color: context.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hiển thị chi tiết pin khi được tap
  void _showPinDetails(Map<String, dynamic> location) {
    // Mở rộng bottom sheet khi tap vào pin
    _scrollController.animateTo(
      0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
