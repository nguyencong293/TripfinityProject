import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;

// API service
import 'package:app/services/search_api_service.dart';
import 'package:app/services/user_interaction_service.dart';

// Navigation imports
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';

class NearbySearchScreen extends StatefulWidget {
  const NearbySearchScreen({super.key});

  @override
  State<NearbySearchScreen> createState() => _NearbySearchScreenState();
}

class _NearbySearchScreenState extends State<NearbySearchScreen> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
  int? selectedPinIndex;

  // Trạng thái tải
  bool _loading = false;
  String? _error;

  // Google Map controller và tọa độ
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  Map<String, BitmapDescriptor> _customIcons = {};

  // Danh sách item động hiển thị dưới sheet và trên map
  final List<Map<String, dynamic>> _items = [];

  // Chiều cao ước tính của một item và header
  final double _estimatedItemHeight = 100;
  final double _headerHeight = 96;

  // Bán kính tìm kiếm (km)
  final double _searchRadiusKm = 10.0;

  // 🔥 Giới hạn số lượng kết quả để tránh UI bị treo
  final int _maxResults = 50;

  @override
  void initState() {
    super.initState();
    _initializeNearbySearch();
  }

  Future<void> _initializeNearbySearch() async {
    await _loadCustomIcons();
    await _getCurrentLocationAndSearch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Lấy vị trí hiện tại và tìm kiếm xung quanh
  Future<void> _getCurrentLocationAndSearch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Kiểm tra quyền truy cập vị trí
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Dịch vụ vị trí chưa được bật');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng bật trong cài đặt.',
        );
      }

      // Lấy vị trí hiện tại
      debugPrint('📍 Getting current location...');
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      debugPrint(
        '✅ Current location: ${position.latitude}, ${position.longitude}',
      );

      // Tìm kiếm các địa điểm xung quanh
      await _searchNearbyPlaces();
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // 🔥 FIX: Tìm kiếm các địa điểm với timeout và giới hạn kết quả
  Future<void> _searchNearbyPlaces() async {
    if (_currentLocation == null) return;

    try {
      debugPrint('🔍 Searching nearby places within $_searchRadiusKm km...');

      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      // 🔥 FIX 1: Thêm timeout 15 giây để tránh API call bị treo
      final data = await api
          .search(q: '')
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Timeout: Không thể tải dữ liệu. Vui lòng thử lại.',
              );
            },
          );

      final List<Map<String, dynamic>> items = [];
      final Set<Marker> markers = {};
      int idx = 0;
      int totalProcessed = 0;

      // 🔥 FIX 2: Xử lý từng loại địa điểm với giới hạn
      totalProcessed += await _processLocationCategory(
        data['hotels'],
        'hotel',
        'Khách sạn',
        items,
        markers,
        idx,
        _maxResults - totalProcessed,
      );
      idx = items.length;

      if (totalProcessed < _maxResults) {
        totalProcessed += await _processLocationCategory(
          data['restaurants'],
          'restaurant',
          'Nhà hàng',
          items,
          markers,
          idx,
          _maxResults - totalProcessed,
        );
        idx = items.length;
      }

      if (totalProcessed < _maxResults) {
        totalProcessed += await _processLocationCategory(
          data['tours'],
          'tour',
          'Tour dịch vụ',
          items,
          markers,
          idx,
          _maxResults - totalProcessed,
        );
        idx = items.length;
      }

      if (totalProcessed < _maxResults) {
        totalProcessed += await _processLocationCategory(
          data['attractions'],
          'attraction',
          'Hoạt động giải trí',
          items,
          markers,
          idx,
          _maxResults - totalProcessed,
        );
      }

      debugPrint('✅ Found ${items.length} places within $_searchRadiusKm km');

      if (!mounted) return;

      setState(() {
        _items.clear();
        _items.addAll(items);
        _markers.clear();
        _markers.addAll(markers);
        _loading = false;
      });

      // Fit map bounds sau khi load xong markers
      if (_markers.isNotEmpty && _mapController != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _fitMapBounds();
        }
      }
    } catch (e) {
      debugPrint('❌ Error searching nearby: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString().contains('Timeout')
            ? 'Không thể tải dữ liệu. Vui lòng thử lại.'
            : 'Lỗi tìm kiếm: $e';
        _loading = false;
      });
    }
  }

  // 🔥 FIX 3: Xử lý từng loại địa điểm với giới hạn số lượng
  Future<int> _processLocationCategory(
    dynamic dataList,
    String category,
    String typeLabel,
    List<Map<String, dynamic>> items,
    Set<Marker> markers,
    int startIdx,
    int maxToProcess,
  ) async {
    if (dataList == null || dataList is! List || maxToProcess <= 0) {
      return 0;
    }

    int processed = 0;
    int idx = startIdx;

    for (final e in List.from(dataList)) {
      if (processed >= maxToProcess) break;

      try {
        final m = Map<String, dynamic>.from(e);
        final coords = _getCoordinatesFromData(m);

        if (coords != null && _isWithinRadius(coords)) {
          final item = _createItemData(m, category, typeLabel, coords, idx);
          items.add(item);

          markers.add(_createMarker(item, category, idx));
          idx++;
          processed++;
        }
      } catch (e) {
        debugPrint('⚠️ Error processing $category item: $e');
        continue;
      }
    }

    return processed;
  }

  // Lấy tọa độ từ data (giống search_map - xử lý num type)
  LatLng? _getCoordinatesFromData(Map<String, dynamic> data) {
    final latitude = data['latitude'];
    final longitude = data['longitude'];

    double? lat;
    double? lng;

    if (latitude != null && longitude != null) {
      if (latitude is num) lat = latitude.toDouble();
      if (longitude is num) lng = longitude.toDouble();
    }

    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  }

  // Kiểm tra xem tọa độ có trong bán kính không
  bool _isWithinRadius(LatLng coords) {
    if (_currentLocation == null) return false;

    final distanceInMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      coords.latitude,
      coords.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    return distanceInKm <= _searchRadiusKm;
  }

  // Tạo item data
  Map<String, dynamic> _createItemData(
    Map<String, dynamic> data,
    String category,
    String type,
    LatLng coords,
    int index,
  ) {
    return {
      'id': '${category}_$index',
      '${category}Id': data['${category}Id'] ?? data['id'],
      'name': data['title']?.toString() ?? data['name']?.toString() ?? '',
      'category': category,
      'type': type,
      'rating': data['ratingAverage'] ?? data['rating'] ?? 0.0,
      'price': _formatPrice(data['price'], data['currencyCode']?.toString()),
      'imageUrl': data['thumbnailUrl'],
      'assetImage': 'assets/images/onboarding${(index % 4) + 1}.png',
      'lat': coords.latitude,
      'lng': coords.longitude,
      'address':
          data['address']?.toString() ?? data['location']?.toString() ?? '',
      'distance': _calculateDistance(coords),
    };
  }

  // Tính khoảng cách từ vị trí hiện tại
  String _calculateDistance(LatLng coords) {
    if (_currentLocation == null) return '';

    final distanceInMeters = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      coords.latitude,
      coords.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    if (distanceInKm < 1) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  // Format giá
  String _formatPrice(dynamic price, String? currency) {
    if (price == null) return '';
    num? n;
    if (price is num) {
      n = price;
    } else {
      n = num.tryParse(price.toString());
    }
    if (n == null) return '';
    final c = (currency ?? '').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') return '${n.toStringAsFixed(0)} đ';
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }

  // Tạo marker
  Marker _createMarker(Map<String, dynamic> item, String category, int index) {
    return Marker(
      markerId: MarkerId('${category}_$index'),
      position: LatLng(item['lat'], item['lng']),
      icon: _customIcons[category] ?? BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: item['name']?.toString() ?? '',
        snippet: '${item['type']} - ${item['distance']}',
      ),
      onTap: () {
        setState(() {
          selectedPinIndex = _items.indexOf(item);
        });
        _showPinDetails(item);
      },
    );
  }

  // Fit map bounds để hiện tất cả markers
  Future<void> _fitMapBounds() async {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (final marker in _markers) {
      if (marker.position.latitude < minLat) {
        minLat = marker.position.latitude;
      }
      if (marker.position.latitude > maxLat) {
        maxLat = marker.position.latitude;
      }
      if (marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  // Load custom marker icons
  Future<void> _loadCustomIcons() async {
    const markerColor = Color(0xFFE63946);
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

  // Tạo custom marker icon
  Future<BitmapDescriptor> _createCustomMarker(
    IconData icon,
    Color color,
  ) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = 20.0;

      // Vẽ vòng tròn nền
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

      // Vẽ viền trắng
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
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
          fontSize: 10,
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

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is num) return rating.toStringAsFixed(1);
    final parsed = double.tryParse(rating.toString());
    return parsed?.toStringAsFixed(1) ?? '0.0';
  }

  // Lấy icon theo loại địa điểm
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

  // Hiển thị chi tiết pin khi được tap
  void _showPinDetails(Map<String, dynamic> location) {
    final index = _items.indexWhere((item) => item['id'] == location['id']);
    if (index == -1) return;

    setState(() {
      selectedPinIndex = index;
    });

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

  int _parseId(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      if (item[key] != null) {
        if (item[key] is int) return item[key] as int;
        final parsed = int.tryParse(item[key].toString());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  void _navigateToHotelDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['hotelId', 'id', 'hotel_id']);

    final trackingService = await UserInteractionService.create();
    trackingService.recordClick(itemId: id, itemType: 'hotel');

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id,
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

    final trackingService = await UserInteractionService.create();
    trackingService.recordClick(itemId: id, itemType: 'restaurant');

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
            'reviews': '(320)',
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

    final trackingService = await UserInteractionService.create();
    trackingService.recordClick(itemId: id, itemType: 'tour');

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
      'tourId': id,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(tourId: id, tour: tourData),
      ),
    );
  }

  void _navigateToAttractionDetail(Map<String, dynamic> item) async {
    final id = _parseId(item, ['attractionId', 'id', 'attraction_id']);

    final trackingService = await UserInteractionService.create();
    trackingService.recordClick(itemId: id, itemType: 'attraction');

    if (!mounted) return;
    final attractionData = {
      'name': item['name']?.toString() ?? '',
      'location': item['address']?.toString() ?? '',
      'rating': double.tryParse(_getRatingString(item['rating'])) ?? 0.0,
      'price': 0,
      'description': 'Điểm tham quan tại ${item['address']?.toString() ?? ''}',
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
          attractionId: id,
          attraction: attractionData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double minChildSize =
        (_headerHeight + _estimatedItemHeight) / screenHeight;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          _buildMapView(context),
          _buildHeader(context),
          _buildDraggableBottomSheet(context, minChildSize),
        ],
      ),
    );
  }

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
                  'Xung quanh bạn (${_searchRadiusKm}km)',
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: _getCurrentLocationAndSearch,
                icon: Icon(
                  LucideIcons.refreshCw,
                  color: context.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    if (_currentLocation == null || _loading) {
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
                _error ?? 'Đang tải vị trí...',
                style: context.captionStyle.copyWith(
                  color: _error != null
                      ? Colors.red
                      : context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) async {
        _mapController = controller;
        if (_markers.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await _fitMapBounds();
          }
        }
      },
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 13,
      ),
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
      liteModeEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
      onTap: (position) {
        setState(() {
          selectedPinIndex = null;
        });
      },
    );
  }

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
                      'Địa điểm xung quanh',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.mapPinOff,
                size: 48,
                color: context.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: context.bodyOneStyle.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getCurrentLocationAndSearch,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const SizedBox.shrink();
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy địa điểm nào\ntrong bán kính $_searchRadiusKm km',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 12,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location['distance']?.toString() ?? '',
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location['type']?.toString() ?? '',
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
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
}
