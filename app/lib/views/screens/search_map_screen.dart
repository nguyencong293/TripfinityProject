import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'dart:ui' as ui;

// API centralized (reused from General/Search Overview)
import 'package:app/services/search_api_service.dart';
import 'package:app/services/user_interaction_service.dart';

// Navigation imports
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';

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

  // Google Map controller và tọa độ
  GoogleMapController? _mapController;
  LatLng? _centerLocation;
  final Set<Marker> _markers = {};
  Map<String, BitmapDescriptor> _customIcons = {};
  bool _initialCameraSet = false;

  // Danh sách item động hiển thị dưới sheet và trên map
  // Mỗi item: { id, name, category, type, rating, price, imageUrl, assetImage, lat, lng, address }
  final List<Map<String, dynamic>> _items = [];

  // Chiều cao ước tính của một item và header
  final double _estimatedItemHeight = 100;
  final double _headerHeight = 96;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _loadCustomIcons();
    await _fetchMapData(widget.searchQuery);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Kiểm tra tọa độ có hợp lệ không (phạm vi Việt Nam + buffer)
  bool _isValidCoordinate(LatLng coords, LatLng? centerLocation) {
    // Chỉ check phạm vi VN rộng, KHÔNG check khoảng cách từ center
    // Để backend coords luôn được chấp nhận
    return coords.latitude >= 8.0 &&
        coords.latitude <= 24.0 &&
        coords.longitude >= 102.0 &&
        coords.longitude <= 110.0;
  }

  // Thêm offset nhỏ để tránh markers trùng tọa độ
  LatLng _addOffset(LatLng original, int index, Set<Marker> existingMarkers) {
    // Kiểm tra xem có marker nào cùng tọa độ không
    final hasDuplicate = existingMarkers.any((marker) {
      final latDiff = (marker.position.latitude - original.latitude).abs();
      final lngDiff = (marker.position.longitude - original.longitude).abs();
      return latDiff < 0.0001 && lngDiff < 0.0001;
    });

    if (!hasDuplicate) return original;

    // Thêm offset RẤT NHỎ theo hình tròn để tránh trùng UI
    final offsetDistance = 0.0005; // ~50m - đủ nhỏ để không sai lệch
    final angle = (index * 60) * 3.14159 / 180; // 60 độ mỗi marker
    final latOffset = offsetDistance * cos(angle);
    final lngOffset = offsetDistance * sin(angle);

    return LatLng(
      original.latitude + latOffset,
      original.longitude + lngOffset,
    );
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

  // Bản đồ với GoogleMap và markers động
  Widget _buildMapView(BuildContext context) {
    // Chỉ hiển thị map khi đã load xong markers
    if (_centerLocation == null || _loading) {
      // Hiển thị loading khi chưa có tọa độ hoặc đang load
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: context.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: context.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Đang tải bản đồ...',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) async {
        _mapController = controller;
        // Fit bounds ngay khi map được tạo nếu đã có markers
        if (_markers.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _fitMapBounds();
        }
      },
      initialCameraPosition: CameraPosition(target: _centerLocation!, zoom: 13),
      markers: _markers,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
      liteModeEnabled: false, // Full mode để có thể fit bounds và tương tác
      minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
      onTap: (position) {
        setState(() {
          selectedPinIndex = null;
        });
      },
    );
  }

  // Load custom marker icons
  Future<void> _loadCustomIcons() async {
    const markerColor = Color(0xFFE63946); // Đỏ cho tất cả markers
    _customIcons = {
      'hotel': await _createCustomMarker(LucideIcons.building, markerColor),
      'restaurant': await _createCustomMarker(
        LucideIcons.utensils,
        markerColor,
      ),
      'tour': await _createCustomMarker(LucideIcons.bus, markerColor),
      'attraction': await _createCustomMarker(LucideIcons.ticket, markerColor),
    };
  }

  // Tạo custom marker icon từ icon và màu
  Future<BitmapDescriptor> _createCustomMarker(
    IconData icon,
    Color color,
  ) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = 20.0; // Giảm size xuống 5 lần (từ 100 -> 20)

      // Vẽ vòng tròn nền
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

      // Vẽ viền trắng
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2; // Giảm từ 6 -> 1.2
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        size / 2 - 0.6,
        borderPaint,
      );

      // Vẽ icon
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 10, // Giảm từ 50 -> 10
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      if (bytes != null) {
        return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('❌ Error creating custom marker: $e');
    }

    // Fallback to default marker
    return BitmapDescriptor.defaultMarkerWithHue(
      color == Colors.blue
          ? BitmapDescriptor.hueBlue
          : color == Colors.orange
          ? BitmapDescriptor.hueOrange
          : color == Colors.green
          ? BitmapDescriptor.hueGreen
          : BitmapDescriptor.hueViolet,
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
          _navigateToDetail(location);
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

  // Navigate đến detail screen tương ứng
  void _navigateToDetail(Map<String, dynamic> item) {
    final category = item['category']?.toString();

    switch (category) {
      case 'hotel':
        _navigateToHotelDetail(item);
        break;
      case 'restaurant':
        _navigateToRestaurantDetail(item);
        break;
      case 'tour':
        _navigateToTourDetail(item);
        break;
      case 'attraction':
        _navigateToAttractionDetail(item);
        break;
    }
  }

  void _navigateToHotelDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['hotelId', 'id', 'hotel_id']);

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'hotel');
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id, // dynamic fetch if available
          hotel: {
            'name': item['name']?.toString() ?? '',
            'image':
                item['imageUrl']?.toString() ??
                item['assetImage']?.toString() ??
                'assets/images/onboarding2.png',
            'price': item['price']?.toString() ?? '—',
          },
          activeAmenities: const {'Wifi miễn phí', 'Bể bơi'},
        ),
      ),
    );
  }

  void _navigateToRestaurantDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['restaurantId', 'id', 'restaurant_id']);

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'restaurant');
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurantId: id,
          restaurant: {
            'name': item['name']?.toString() ?? '',
            'location': item['address']?.toString() ?? '',
            'rating': _getRatingString(item['rating']),
            'type': 'restaurant',
            'cuisine': '',
            'price': item['price']?.toString() ?? '',
            'reviews': '(320)', // fallback
            'tag': '',
            'image':
                item['imageUrl']?.toString() ??
                item['assetImage']?.toString() ??
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

  void _navigateToTourDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['tourId', 'id', 'tour_id']);

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'tour');
    }

    if (!mounted) return;
    final tourData = {
      'name': item['name']?.toString() ?? '',
      'location': item['address']?.toString() ?? '',
      'rating': _getRatingString(item['rating']),
      'price': item['price']?.toString() ?? '',
      'image':
          item['imageUrl']?.toString() ??
          item['assetImage']?.toString() ??
          'assets/images/onboarding1.png',
      'duration': '',
      'description': '',
      'tourId': id, // carry id in fallback too
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(tourId: id, tour: tourData),
      ),
    );
  }

  void _navigateToAttractionDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['attractionId', 'id', 'attraction_id']);

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'attraction');
    }

    if (!mounted) return;
    final attractionData = {
      'name': item['name']?.toString() ?? '',
      'location': item['address']?.toString() ?? '',
      'rating': double.tryParse(_getRatingString(item['rating'])) ?? 0.0,
      'price': 0,
      'description': 'Diểm tham quan tại ${item['address']?.toString() ?? ''}',
      'image':
          item['imageUrl']?.toString() ??
          item['assetImage']?.toString() ??
          'assets/images/onboarding3.png',
      'types': ['Tham quan'],
      'services': ['Chụp ảnh'],
      'times': ['Sáng', 'Chiều'],
      'suit': ['Solo', 'Cặp đôi'],
      'attractionId': id,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
          attractionId: id, // dynamic fetch if available
          attraction: attractionData,
        ),
      ),
    );
  }

  // ===== API + Mapping =====
  Future<void> _fetchMapData(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Set center mặc định (Hà Nội) - sẽ được override bởi fitBounds sau
      setState(() {
        _centerLocation = const LatLng(21.0285, 105.8542);
      });

      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);
      final data = await api.search(q: query);

      final List<Map<String, dynamic>> items = [];
      final Set<Marker> markers = {};
      int idx = 0;

      // Hotels
      debugPrint(
        '🏨 Processing ${(data['hotels'] as List?)?.length ?? 0} hotels',
      );
      if (data['hotels'] is List) {
        for (final e in List.from(data['hotels'])) {
          final m = Map<String, dynamic>.from(e);

          // Lấy tọa độ từ backend (giống detail hotel - xử lý num type)
          final latitude = m['latitude'];
          final longitude = m['longitude'];

          double? lat;
          double? lng;

          if (latitude != null && longitude != null) {
            if (latitude is num) lat = latitude.toDouble();
            if (longitude is num) lng = longitude.toDouble();
          }

          final address =
              m['address']?.toString() ?? m['location']?.toString() ?? '';

          LatLng? coords;
          if (lat != null && lng != null) {
            coords = LatLng(lat, lng);
            debugPrint(
              '  📍 Hotel "${m['title']}": Backend coords ($lat, $lng)',
            );
          } else {
            // KHÔNG geocode - skip nếu backend không có coords
            debugPrint(
              '  ⚠️ Hotel "${m['title']}": No coords from backend, skipping',
            );
            continue;
          }

          // Kiểm tra tọa độ hợp lệ (chỉ check phạm vi VN)
          if (!_isValidCoordinate(coords, _centerLocation)) {
            debugPrint('    ❌ Invalid coordinates (outside Vietnam), skipping');
            continue;
          }

          // Thêm offset nếu trùng tọa độ
          coords = _addOffset(coords, idx, markers);
          debugPrint('    ✅ Success: ${coords.latitude}, ${coords.longitude}');
          final item = {
            'id': 'hotel_$idx',
            'hotelId': m['hotelId'] ?? m['id'] ?? m['hotel_id'],
            'name': m['title']?.toString() ?? '',
            'category': 'hotel',
            'type': 'Khách sạn',
            'rating': m['ratingAverage'],
            'price': _formatPrice(m['price'], m['currencyCode']?.toString()),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding2.png',
            'lat': coords.latitude,
            'lng': coords.longitude,
            'address': address,
          };
          items.add(item);

          markers.add(
            Marker(
              markerId: MarkerId('hotel_$idx'),
              position: coords,
              icon: _customIcons['hotel'] ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: item['name']?.toString() ?? '',
                snippet: '${item['type']} - ${item['price']}',
              ),
              onTap: () {
                setState(() {
                  selectedPinIndex = items.length - 1;
                });
                _showPinDetails(item);
              },
            ),
          );
          idx++;
        }
      }

      // Restaurants
      debugPrint(
        '🍽️ Processing ${(data['restaurants'] as List?)?.length ?? 0} restaurants',
      );
      if (data['restaurants'] is List) {
        for (final e in List.from(data['restaurants'])) {
          final m = Map<String, dynamic>.from(e);

          // Lấy tọa độ từ backend (giống detail hotel - xử lý num type)
          final latitude = m['latitude'];
          final longitude = m['longitude'];

          double? lat;
          double? lng;

          if (latitude != null && longitude != null) {
            if (latitude is num) lat = latitude.toDouble();
            if (longitude is num) lng = longitude.toDouble();
          }

          final address =
              m['address']?.toString() ?? m['location']?.toString() ?? '';

          LatLng? coords;
          if (lat != null && lng != null) {
            coords = LatLng(lat, lng);
            debugPrint(
              '  📍 Restaurant "${m['title']}": Backend coords ($lat, $lng)',
            );
          } else {
            // KHÔNG geocode - skip nếu backend không có coords
            debugPrint(
              '  ⚠️ Restaurant "${m['title']}": No coords from backend, skipping',
            );
            continue;
          }

          // Kiểm tra tọa độ hợp lệ (chỉ check phạm vi VN)
          if (!_isValidCoordinate(coords, _centerLocation)) {
            debugPrint('    ❌ Invalid coordinates (outside Vietnam), skipping');
            continue;
          }

          // Thêm offset nếu trùng tọa độ
          coords = _addOffset(coords, idx, markers);
          debugPrint('    ✅ Success: ${coords.latitude}, ${coords.longitude}');
          final item = {
            'id': 'restaurant_$idx',
            'restaurantId': m['restaurantId'] ?? m['id'] ?? m['restaurant_id'],
            'name': m['title']?.toString() ?? '',
            'category': 'restaurant',
            'type': 'Nhà hàng',
            'rating': m['ratingAverage'],
            'price': _formatPrice(m['price'], m['currencyCode']?.toString()),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding1.png',
            'lat': coords.latitude,
            'lng': coords.longitude,
            'address': address,
          };
          items.add(item);

          markers.add(
            Marker(
              markerId: MarkerId('restaurant_$idx'),
              position: coords,
              icon:
                  _customIcons['restaurant'] ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: item['name']?.toString() ?? '',
                snippet: '${item['type']} - ${item['price']}',
              ),
              onTap: () {
                setState(() {
                  selectedPinIndex = items.length - 1;
                });
                _showPinDetails(item);
              },
            ),
          );
          idx++;
        }
      }

      // Tours
      debugPrint(
        '🚌 Processing ${(data['tours'] as List?)?.length ?? 0} tours',
      );
      if (data['tours'] is List) {
        for (final e in List.from(data['tours'])) {
          final m = Map<String, dynamic>.from(e);

          // Lấy tọa độ từ backend (giống detail hotel - xử lý num type)
          final latitude = m['latitude'];
          final longitude = m['longitude'];

          double? lat;
          double? lng;

          if (latitude != null && longitude != null) {
            if (latitude is num) lat = latitude.toDouble();
            if (longitude is num) lng = longitude.toDouble();
          }

          final address =
              m['address']?.toString() ?? m['location']?.toString() ?? '';

          LatLng? coords;
          if (lat != null && lng != null) {
            coords = LatLng(lat, lng);
            debugPrint(
              '  📍 Tour "${m['title']}": Backend coords ($lat, $lng)',
            );
          } else {
            // KHÔNG geocode - skip nếu backend không có coords
            debugPrint(
              '  ⚠️ Tour "${m['title']}": No coords from backend, skipping',
            );
            continue;
          }

          // Kiểm tra tọa độ hợp lệ (chỉ check phạm vi VN)
          if (!_isValidCoordinate(coords, _centerLocation)) {
            debugPrint('    ❌ Invalid coordinates (outside Vietnam), skipping');
            continue;
          }

          // Thêm offset nếu trùng tọa độ
          coords = _addOffset(coords, idx, markers);
          debugPrint('    ✅ Success: ${coords.latitude}, ${coords.longitude}');
          final item = {
            'id': 'tour_$idx',
            'tourId': m['tourId'] ?? m['id'] ?? m['tour_id'],
            'name': m['title']?.toString() ?? '',
            'category': 'tour',
            'type': 'Tour dịch vụ',
            'rating': m['ratingAverage'],
            'price': _formatPrice(m['price'], m['currencyCode']?.toString()),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding4.png',
            'lat': coords.latitude,
            'lng': coords.longitude,
            'address': address,
          };
          items.add(item);

          markers.add(
            Marker(
              markerId: MarkerId('tour_$idx'),
              position: coords,
              icon: _customIcons['tour'] ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: item['name']?.toString() ?? '',
                snippet: '${item['type']} - ${item['price']}',
              ),
              onTap: () {
                setState(() {
                  selectedPinIndex = items.length - 1;
                });
                _showPinDetails(item);
              },
            ),
          );
          idx++;
        }
      }

      // Attractions
      debugPrint(
        '🎡 Processing ${(data['attractions'] as List?)?.length ?? 0} attractions',
      );
      if (data['attractions'] is List) {
        for (final e in List.from(data['attractions'])) {
          final m = Map<String, dynamic>.from(e);

          // Lấy tọa độ từ backend (giống detail hotel - xử lý num type)
          final latitude = m['latitude'];
          final longitude = m['longitude'];

          double? lat;
          double? lng;

          if (latitude != null && longitude != null) {
            if (latitude is num) lat = latitude.toDouble();
            if (longitude is num) lng = longitude.toDouble();
          }

          final address =
              m['address']?.toString() ?? m['location']?.toString() ?? '';

          LatLng? coords;
          if (lat != null && lng != null) {
            coords = LatLng(lat, lng);
            debugPrint(
              '  📍 Attraction "${m['title']}": Backend coords ($lat, $lng)',
            );
          } else {
            // KHÔNG geocode - skip nếu backend không có coords
            debugPrint(
              '  ⚠️ Attraction "${m['title']}": No coords from backend, skipping',
            );
            continue;
          }

          // Kiểm tra tọa độ hợp lệ (chỉ check phạm vi VN)
          if (!_isValidCoordinate(coords, _centerLocation)) {
            debugPrint('    ❌ Invalid coordinates (outside Vietnam), skipping');
            continue;
          }

          // Thêm offset nếu trùng tọa độ
          coords = _addOffset(coords, idx, markers);
          debugPrint('    ✅ Success: ${coords.latitude}, ${coords.longitude}');
          final item = {
            'id': 'attraction_$idx',
            'attractionId': m['attractionId'] ?? m['id'] ?? m['attraction_id'],
            'name': m['title']?.toString() ?? '',
            'category': 'attraction',
            'type': 'Hoạt động giải trí',
            'rating': m['ratingAverage'],
            'price': _formatPrice(m['price'], m['currencyCode']?.toString()),
            'imageUrl': m['thumbnailUrl'],
            'assetImage': 'assets/images/onboarding3.png',
            'lat': coords.latitude,
            'lng': coords.longitude,
            'address': address,
          };
          items.add(item);

          markers.add(
            Marker(
              markerId: MarkerId('attraction_$idx'),
              position: coords,
              icon:
                  _customIcons['attraction'] ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: item['name']?.toString() ?? '',
                snippet: '${item['type']} - ${item['price']}',
              ),
              onTap: () {
                setState(() {
                  selectedPinIndex = items.length - 1;
                });
                _showPinDetails(item);
              },
            ),
          );
          idx++;
        }
      }

      debugPrint(
        '📊 Summary: ${markers.length} markers created from ${items.length} items',
      );

      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _markers
          ..clear()
          ..addAll(markers);
        _loading = false;
      });

      // Fit map bounds sau khi có markers
      if (_markers.isNotEmpty) {
        // Delay một chút để map controller sẵn sàng
        await Future.delayed(const Duration(milliseconds: 800));
        await _fitMapBounds();
      }
    } catch (e) {
      debugPrint('❌ Fetch map data error: $e');
      setState(() {
        _loading = false;
        _error =
            'Không thể tải dữ liệu bản đồ. Vui lòng thử lại hoặc đăng nhập.';
      });
    }
  }

  // Tự động zoom map để hiển thị tất cả markers
  Future<void> _fitMapBounds() async {
    if (_mapController == null || _markers.isEmpty || _initialCameraSet) {
      return;
    }

    try {
      debugPrint('🎯 Fitting bounds for ${_markers.length} markers');

      if (_markers.length == 1) {
        // Nếu chỉ có 1 marker, zoom 11 để thấy overview rộng
        final marker = _markers.first;
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(marker.position, 11),
        );
      } else {
        // Tính bounds từ tất cả markers
        double minLat = 90.0;
        double maxLat = -90.0;
        double minLng = 180.0;
        double maxLng = -180.0;

        debugPrint('📍 Marker positions:');
        for (final marker in _markers) {
          final lat = marker.position.latitude;
          final lng = marker.position.longitude;
          debugPrint('  - ${marker.markerId.value}: ($lat, $lng)');

          if (lat < minLat) minLat = lat;
          if (lat > maxLat) maxLat = lat;
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
        }

        // Thêm padding nhỏ để fit vừa khít trong khung hình
        final latPadding =
            (maxLat - minLat) * 0.1; // 10% padding để gói gọn trong màn hình
        final lngPadding = (maxLng - minLng) * 0.1;

        final southwest = LatLng(minLat - latPadding, minLng - lngPadding);
        final northeast = LatLng(maxLat + latPadding, maxLng + lngPadding);
        final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

        // Animate camera với padding tối thiểu cho UI
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            20, // padding 20px - tận dụng tối đa khung hình
          ),
        );
      }

      _initialCameraSet = true;
      debugPrint('✅ Map bounds fitted: ${_markers.length} markers');
    } catch (e) {
      debugPrint('❌ Error fitting map bounds: $e');
      // Fallback: zoom về center location với zoom mặc định
      if (_centerLocation != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_centerLocation!, 13),
        );
      }
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
