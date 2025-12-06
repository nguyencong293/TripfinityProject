import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

// API
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/attraction_api_service.dart';

// ===== ATTRACTION CONSTANTS (từ Supplier Portal) =====
const Map<String, String> _kVisitTypesDict = {
  'guided_tour': 'Tham quan có hướng dẫn viên',
  'self_guided': 'Tự do tham quan',
  'audio_guide': 'Hướng dẫn âm thanh',
  'virtual_tour': 'Tham quan ảo',
};

const Map<String, String> _kSuitableForDict = {
  'family': 'Gia đình',
  'kids': 'Trẻ em',
  'elderly': 'Người cao tuổi',
  'couples': 'Cặp đôi',
  'groups': 'Nhóm',
  'solo': 'Một mình',
  'pets': 'Thú cưng',
};

const Map<String, String> _kAvailableTimesDict = {
  'morning': 'Sáng',
  'afternoon': 'Chiều',
  'evening': 'Tối',
  'night': 'Đêm',
};

const Map<int, String> _kHighlightsDict = {
  1: 'View biển',
  2: 'View núi',
  3: 'Trung tâm thành phố',
  4: 'Gần sân bay',
  5: 'Hồ bơi ngoài trời',
  6: 'Hồ bơi trong nhà',
  7: 'Spa & Massage',
  8: 'Phòng gym',
  9: 'Nhà hàng cao cấp',
  10: 'Bar & Lounge',
  11: 'Bãi biển riêng',
  12: 'Hồ bơi vô cực',
  13: 'Bar hồ bơi',
  14: 'Câu lạc bộ trẻ em (Kids Club)',
  15: 'Dịch vụ trông trẻ',
  16: 'Sân tennis',
  17: 'Sân golf gần kề',
  18: 'Thể thao dưới nước',
  19: 'Lặn biển / Snorkeling',
  20: 'Kayak / Chèo SUP',
  21: 'Công viên nước mini',
  22: 'Rooftop bar',
  23: 'Nhà hàng buffet',
  24: 'Trung tâm hội nghị / phòng họp',
  25: 'Dịch vụ đưa đón sân bay',
  26: 'Dịch vụ đưa đón trong khu',
  27: 'Bãi đỗ xe có nhân viên (valet)',
  28: 'Xông hơi / Sauna',
  29: 'Bể sục / Jacuzzi',
  30: 'Khu vui chơi trẻ em',
};

const Map<int, String> _kFeaturesDict = {
  1: 'WiFi miễn phí',
  2: 'Điều hòa',
  3: 'Nhà vệ sinh công cộng',
  4: 'Quầy thông tin',
  5: 'Cửa hàng lưu niệm',
  6: 'Nhà hàng/Quán ăn',
  7: 'Quầy cà phê',
  8: 'Bãi đậu xe miễn phí',
  9: 'Bãi đậu xe có phí',
  10: 'Cho phép thú cưng',
  11: 'Hướng dẫn viên',
  12: 'Audio guide',
  13: 'Phòng trưng bày',
  14: 'Khu vui chơi trẻ em',
  15: 'Khu picnic',
  16: 'Máy bán hàng tự động',
  17: 'Phòng khám y tế',
  18: 'Lễ tân/Quầy vé',
  19: 'Thang máy',
  20: 'Tiện nghi cho người khuyết tật',
  21: 'Đổi tiền / ATM',
  22: 'Trạm sạc xe điện',
  23: 'Khu vực chụp ảnh',
  24: 'Sân khấu/Biểu diễn',
  25: 'Phòng chiếu phim',
  26: 'Thư viện',
  27: 'Phòng VR/AR',
  28: 'Khu vườn',
  29: 'Đài quan sát',
  30: 'Bảo vệ 24/7',
};

const Map<String, String> _kDaysOfWeekDict = {
  'monday': 'Thứ Hai',
  'tuesday': 'Thứ Ba',
  'wednesday': 'Thứ Tư',
  'thursday': 'Thứ Năm',
  'friday': 'Thứ Sáu',
  'saturday': 'Thứ Bảy',
  'sunday': 'Chủ Nhật',
};

class AttractionsOverviewDetailScreen extends StatefulWidget {
  final int? attractionId;
  final Map<String, dynamic>? attraction;

  const AttractionsOverviewDetailScreen({
    super.key,
    this.attractionId,
    this.attraction,
  }) : assert(
         attractionId != null || attraction != null,
         'Cần truyền attractionId hoặc attraction',
       );

  @override
  State<AttractionsOverviewDetailScreen> createState() =>
      _AttractionsOverviewDetailScreenState();
}

class _AttractionsOverviewDetailScreenState
    extends State<AttractionsOverviewDetailScreen> {
  bool _introExpanded = false;

  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;

  int? _resolvedId;

  // Image slider state (COPY FROM HOTEL)
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _resolvedId =
        widget.attractionId ?? _tryParseInt(widget.attraction?['attractionId']);
    _fetchDetail();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    if (_resolvedId == null) {
      setState(() {
        _loading = false;
        if (widget.attraction == null) {
          _error = 'Không xác định được ID điểm tham quan';
        }
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = AttractionApiService(dio: Dio(), prefs: prefs);
      final data = await api.getAttractionById(_resolvedId!);

      debugPrint('🔍 Attraction Data: attractionId=$_resolvedId');
      debugPrint('🔍 Title: ${data['title']}');
      debugPrint('🔍 ImageUrls: ${data['imageUrls']}');
      debugPrint('🔍 Latitude: ${data['latitude']}');
      debugPrint('🔍 Longitude: ${data['longitude']}');

      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading attraction: $e');
      setState(() {
        _error = 'Không thể tải thông tin điểm tham quan';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data; // merged view

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.share2, color: context.textPrimaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.heart, color: context.textPrimaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.primaryColor,
                ),
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: context.bodyOneStyle.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // IMAGE GALLERY (COPY FROM HOTEL)
                _imageGallery(_imageList(data)),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(context, data),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _priceAndAction(context, data),
                ),

                const SizedBox(height: 20),

                // Giới thiệu
                _sectionWrapper(
                  context,
                  title: 'Giới thiệu',
                  child: _expandableText(
                    context,
                    text: data['serviceDescription']?.toString() ?? '—',
                    expanded: _introExpanded,
                    onToggle: () =>
                        setState(() => _introExpanded = !_introExpanded),
                  ),
                ),

                // Highlights
                if (_highlightsToNames(data['highlightsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Điểm nổi bật',
                    child: _bulletList(
                      context,
                      _highlightsToNames(data['highlightsJson']),
                    ),
                  ),

                // Visit Types
                if (_visitTypesToNames(data['visitTypesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Loại hình tham quan',
                    child: _chipsRow(
                      context,
                      _visitTypesToNames(data['visitTypesJson']),
                    ),
                  ),

                // Features/Services
                if (_featuresToNames(data['featuresJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Dịch vụ & Tiện ích',
                    child: _chipsRow(
                      context,
                      _featuresToNames(data['featuresJson']),
                    ),
                  ),

                // Available Times
                if (_availableTimesToNames(
                  data['availableTimesJson'],
                ).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Thời gian hoạt động',
                    child: _chipsRow(
                      context,
                      _availableTimesToNames(data['availableTimesJson']),
                    ),
                  ),

                // Suitable For
                if (_suitableForToNames(data['suitableForJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Phù hợp với',
                    child: _chipsRow(
                      context,
                      _suitableForToNames(data['suitableForJson']),
                    ),
                  ),

                // Opening Hours
                if (data['openingHoursJson'] != null)
                  _sectionWrapper(
                    context,
                    title: 'Giờ mở cửa',
                    child: _openingHoursBlock(
                      context,
                      data['openingHoursJson'],
                    ),
                  ),

                // Tips
                if (data['tipsText'] != null &&
                    data['tipsText'].toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Mẹo tham quan',
                    child: _bulletList(
                      context,
                      _splitLines(data['tipsText'].toString()),
                    ),
                  ),

                // LOCATION WITH GOOGLE MAPS (COPY FROM HOTEL)
                _sectionWrapper(
                  context,
                  title: 'Vị trí',
                  child: _locationBlock(context, data),
                ),

                const SizedBox(height: 28),
              ],
            ),
    );
  }

  // ===== IMAGE GALLERY (COPIED FROM HOTEL) =====
  Widget _imageGallery(List<String> images) {
    final hasImages = images.isNotEmpty;

    debugPrint(
      '🖼️ Image Gallery: hasImages=$hasImages, count=${images.length}',
    );
    if (hasImages) {
      debugPrint('🖼️ Images: $images');
    }

    return Container(
      color: context.backgroundColor,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!hasImages)
                  _imageFallback(context)
                else
                  PageView.builder(
                    controller: _imageController,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemCount: images.length,
                    itemBuilder: (_, i) {
                      final url = images[i];
                      final isNetwork = url.startsWith('http');
                      if (url.isEmpty) return _imageFallback(context);
                      return isNetwork
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imageFallback(context),
                            )
                          : Image.asset(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imageFallback(context),
                            );
                    },
                  ),
                if (hasImages && images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.image,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_imageIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
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
          if (hasImages && images.length > 1)
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final url = images[i];
                  final selected = i == _imageIndex;
                  return InkWell(
                    onTap: () => _imageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 86,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? context.primaryColor
                              : context.dividerColor,
                          width: selected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: url.startsWith('http')
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imageFallback(context),
                              )
                            : Image.asset(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imageFallback(context),
                              ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: images.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      color: context.skeletonPlaceholderColor,
      child: Icon(Icons.image, size: 48, color: context.textSecondaryColor),
    );
  }

  // ===== HEADER INFO =====
  Widget _headerInfo(BuildContext context, Map<String, dynamic> d) {
    final title = d['title']?.toString() ?? '';
    final location =
        d['location']?.toString() ?? d['address']?.toString() ?? '';
    final rating = _toDouble(d['ratingAverage']) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(LucideIcons.mapPin, size: 16, color: context.primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _starsRow(context, rating),
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              'Đánh giá',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, dynamic> d) {
    final price = _toDouble(d['price']) ?? 0;
    final currency = d['currencyCode']?.toString() ?? 'VND';
    final priceText = _formatPrice(price, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Từ ',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            Text(
              priceText,
              style: context.bodyOneStyle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: context.primaryColor,
              ),
            ),
            Text(
              '/người',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              'Đặt vé ngay',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  // ===== LOCATION BLOCK WITH GOOGLE MAPS (COPIED FROM HOTEL) =====
  Widget _locationBlock(BuildContext context, Map<String, dynamic> d) {
    final address = d['address']?.toString();
    final location = d['location']?.toString();
    final text = address?.isNotEmpty == true ? address! : (location ?? '');

    final latitude = d['latitude'];
    final longitude = d['longitude'];

    double? lat;
    double? lng;

    if (latitude != null && longitude != null) {
      if (latitude is num) lat = latitude.toDouble();
      if (longitude is num) lng = longitude.toDouble();
    }

    debugPrint('📍 Location Block: lat=$lat, lng=$lng, address=$text');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lat != null && lng != null)
          FutureBuilder<String>(
            future: _reverseGeocode(lat, lng),
            builder: (context, snapshot) {
              final displayAddress = snapshot.data ?? text;
              return InkWell(
                onTap: () {
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                  launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Text(
                  displayAddress,
                  style: context.bodyTwoStyle.copyWith(
                    color: context.primaryColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          )
        else if (text.isNotEmpty)
          Text(
            text,
            style: context.bodyTwoStyle.copyWith(
              color: context.primaryColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: lat != null && lng != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('attraction_location'),
                        position: LatLng(lat, lng),
                        infoWindow: InfoWindow(
                          title: d['title']?.toString() ?? 'Điểm tham quan',
                          snippet: text,
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                    liteModeEnabled: true,
                  )
                : Image.asset(
                    'assets/images/onboarding2.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=vi',
      );

      final response = await http
          .get(url, headers: {'User-Agent': 'TripfinityApp/1.0'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] as String?;

        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (e) {
      debugPrint('❌ Reverse geocode error: $e');
    }

    return '$lat, $lng';
  }

  // ===== OPENING HOURS =====
  Widget _openingHoursBlock(BuildContext context, dynamic openingHours) {
    if (openingHours == null) return const SizedBox.shrink();

    if (openingHours is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: openingHours.entries.map((e) {
          final dayKey = e.key.toString().toLowerCase();
          final dayName = _kDaysOfWeekDict[dayKey] ?? e.key.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    dayName,
                    style: context.captionStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value.toString(),
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Text(
      openingHours.toString(),
      style: context.captionStyle.copyWith(color: context.textSecondaryColor),
    );
  }

  // ===== BULLET LIST =====
  Widget _bulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== CHIPS ROW =====
  Widget _chipsRow(BuildContext context, List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.check, size: 14, color: context.primaryColor),
              const SizedBox(width: 6),
              Text(
                item,
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== SECTION WRAPPER =====
  Widget _sectionWrapper(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.bodyOneStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ===== EXPANDABLE TEXT =====
  Widget _expandableText(
    BuildContext context, {
    required String text,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: context.bodyTwoStyle.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onToggle,
          child: Text(
            expanded ? 'Thu gọn' : 'Xem thêm',
            style: context.captionStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ===== HELPERS =====
  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= (i + 1) - 0.25;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: context.primaryColor,
          size: 16,
        );
      }),
    );
  }

  Map<String, dynamic> get _data {
    return {...?widget.attraction, if (_detail != null) ..._detail!};
  }

  List<String> _imageList(Map<String, dynamic> d) {
    final imgs = d['imageUrls'];
    if (imgs is List) {
      return imgs.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    final thumb = d['thumbnailUrl']?.toString();
    if (thumb != null && thumb.isNotEmpty) {
      return [thumb];
    }
    return const [];
  }

  List<String> _listOfStrings(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  List<int> _listOfIntegers(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e is int ? e : int.tryParse(e.toString()))
          .where((e) => e != null)
          .cast<int>()
          .toList();
    }
    return const [];
  }

  List<String> _highlightsToNames(dynamic highlightsJson) {
    final ids = _listOfIntegers(highlightsJson);
    return ids.map((id) => _kHighlightsDict[id] ?? 'ID: $id').toList();
  }

  List<String> _featuresToNames(dynamic featuresJson) {
    final ids = _listOfIntegers(featuresJson);
    return ids.map((id) => _kFeaturesDict[id] ?? 'ID: $id').toList();
  }

  List<String> _visitTypesToNames(dynamic visitTypesJson) {
    final keys = _listOfStrings(visitTypesJson);
    return keys.map((key) => _kVisitTypesDict[key] ?? key).toList();
  }

  List<String> _suitableForToNames(dynamic suitableForJson) {
    final keys = _listOfStrings(suitableForJson);
    return keys.map((key) => _kSuitableForDict[key] ?? key).toList();
  }

  List<String> _availableTimesToNames(dynamic availableTimesJson) {
    final keys = _listOfStrings(availableTimesJson);
    return keys.map((key) => _kAvailableTimesDict[key] ?? key).toList();
  }

  List<String> _splitLines(String text) {
    return text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String _formatPrice(double price, String currency) {
    if (price == 0) return 'Miễn phí';
    final isVnd = currency.toUpperCase() == 'VND';
    if (isVnd) {
      if (price >= 1000000) {
        return '${(price / 1000000).toStringAsFixed(1)}Mđ';
      } else if (price >= 1000) {
        return '${(price / 1000).toStringAsFixed(0)}Kđ';
      }
      return '${price.toStringAsFixed(0)}đ';
    }
    return '$price $currency';
  }
}
