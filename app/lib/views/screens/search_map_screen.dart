import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// API centralized (reused from General/Search Overview)
import 'package:app/services/search_api_service.dart';

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

  // Trạng thái tải
  bool _loading = false;
  String? _error;

  // Danh sách item động hiển thị dưới sheet và trên “bản đồ”
  // Mỗi item: { id, name, category, typeLabel, rating, price, imageUrl, assetImage, position(Offset) }
  final List<Map<String, dynamic>> _items = [];

  // Chiều cao ước tính của một item và header
  final double _estimatedItemHeight = 100;
  final double _headerHeight = 96;

  @override
  void initState() {
    super.initState();
    _fetchMapData(widget.searchQuery);
  }

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
          // Bản đồ chính (ảnh placeholder)
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
                  // Có thể mở ô nhập để tìm lại trên bản đồ nếu muốn
                },
                icon: Icon(LucideIcons.search, color: context.textPrimaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bản đồ với các pin địa điểm (từ dữ liệu dynamic)
  Widget _buildMapView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/onboarding1.png'), // ảnh nền giả lập
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
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
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
    final bool isSelected = selectedPinIndex == index;
    final Offset position =
        location['position'] as Offset? ?? const Offset(0.5, 0.5);

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
                  location['name']?.toString() ?? '',
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
                _getIconForType(location['type']?.toString() ?? ''),
                color: isSelected ? Colors.white : context.primaryColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lấy icon theo loại địa điểm (hiển thị typeLabel tiếng Việt)
  IconData _getIconForType(String typeLabel) {
    switch (typeLabel) {
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
              // Drag handle
              GestureDetector(
                onVerticalDragUpdate: (_) {},
                child: Container(
                  color: Colors.transparent,
                  height: 40,
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

              // Tiêu đề + số lượng
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
                    if (_loading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.primaryColor,
                        ),
                      )
                    else
                      Text(
                        '${_items.length} địa điểm',
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Nội dung: lỗi / rỗng / danh sách
              Expanded(child: _buildBottomSheetContent(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetContent(ScrollController scrollController) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _error!,
            style: context.bodyOneStyle.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_loading) {
      // Để đồng bộ với tiêu đề đã có spinner, vẫn hiển thị loading nếu muốn
      return const SizedBox.shrink();
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Không có kết quả',
          style: context.captionStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      );
    }

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (_) => true,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const ClampingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildLocationCard(context, _items[index], index);
        },
      ),
    );
  }

  // Card địa điểm trong bottom sheet
  Widget _buildLocationCard(
    BuildContext context,
    Map<String, dynamic> location,
    int index,
  ) {
    final bool isSelected = selectedPinIndex == index;
    final imageUrl = (location['imageUrl'] ?? '').toString();
    final hasNetwork = imageUrl.startsWith('http');

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
          // Optional: scroll tới pin tương ứng (đã expand trong _showPinDetails khi tap pin)
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
                        (location['assetImage'] ??
                                'assets/images/onboarding1.png')
                            .toString(),
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
                      location['name']?.toString() ?? '',
                      style: context.bodyOneStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location['type']?.toString() ?? '',
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
                          _getRatingString(location['rating']),
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        if ((location['price']?.toString() ?? '')
                            .isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Text(
                            location['price'].toString(),
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
                _getIconForType(location['type']?.toString() ?? ''),
                color: context.primaryColor,
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

  // Hiển thị chi tiết pin khi được tap
  void _showPinDetails(Map<String, dynamic> location) {
    // Mở rộng bottom sheet khi tap vào pin
    _scrollController.animateTo(
      0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ===== API + Mapping =====
  Future<void> _fetchMapData(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);
      final data = await api.search(q: query);

      final List<Map<String, dynamic>> items = [];

      // Helper: vị trí phân bố pin (giả lập) theo index
      final positions = _predefinedPositions();

      int idx = 0;

      // Hotels
      if (data['hotels'] is List) {
        for (final e in List.from(data['hotels'])) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          items.add({
            'id': 'hotel_$idx',
            'name': m['title']?.toString() ?? '',
            'category': 'hotel',
            'type': 'Khách sạn',
            'rating': m['ratingAverage'],
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding2.png',
            'position': positions[idx % positions.length],
          });
          idx++;
        }
      }

      // Restaurants
      if (data['restaurants'] is List) {
        for (final e in List.from(data['restaurants'])) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          items.add({
            'id': 'restaurant_$idx',
            'name': m['title']?.toString() ?? '',
            'category': 'restaurant',
            'type': 'Nhà hàng',
            'rating': m['ratingAverage'],
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding1.png',
            'position': positions[idx % positions.length],
          });
          idx++;
        }
      }

      // Tours
      if (data['tours'] is List) {
        for (final e in List.from(data['tours'])) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          items.add({
            'id': 'tour_$idx',
            'name': m['title']?.toString() ?? '',
            'category': 'tour',
            'type': 'Tour dịch vụ',
            'rating': m['ratingAverage'],
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding4.png',
            'position': positions[idx % positions.length],
          });
          idx++;
        }
      }

      // Attractions
      if (data['attractions'] is List) {
        for (final e in List.from(data['attractions'])) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          items.add({
            'id': 'attraction_$idx',
            'name': m['title']?.toString() ?? '',
            'category': 'attraction',
            'type': 'Hoạt động giải trí',
            'rating': m['ratingAverage'],
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding3.png',
            'position': positions[idx % positions.length],
          });
          idx++;
        }
      }

      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error =
            'Không thể tải dữ liệu bản đồ. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
  }

  // Vị trí pin “giả lập” trải đều màn hình
  List<Offset> _predefinedPositions() {
    return const [
      Offset(0.25, 0.30),
      Offset(0.60, 0.28),
      Offset(0.45, 0.55),
      Offset(0.70, 0.70),
      Offset(0.40, 0.20),
      Offset(0.15, 0.45),
      Offset(0.80, 0.40),
      Offset(0.30, 0.75),
      Offset(0.55, 0.60),
      Offset(0.20, 0.65),
      Offset(0.85, 0.25),
      Offset(0.65, 0.50),
    ];
  }

  // ===== Utils =====
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
