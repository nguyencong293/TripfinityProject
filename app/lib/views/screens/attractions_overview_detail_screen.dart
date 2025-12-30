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
import 'package:app/services/favorite_api_service.dart';
import 'package:app/services/user_interaction_service.dart';
import 'package:app/views/screens/attraction_booking_checkout_screen.dart';
import 'package:app/views/screens/detail_attraction_review_user_screen.dart';
import 'package:app/views/screens/attraction_reviews_list_screen.dart';
import 'package:app/views/widgets/favorite_button.dart';

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
  bool _isFavorite = false;

  // Reviews data
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _ratingSummaryData;
  final Set<int> _expandedReviews = {};

  // Image slider state (COPY FROM HOTEL)
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  // Date and people selection
  DateTime? _visitDate;
  int _people = 2;

  @override
  void initState() {
    super.initState();
    _resolvedId =
        widget.attractionId ?? _tryParseInt(widget.attraction?['attractionId']);
    _loadFavoriteStatus();
    _fetchDetail();
    _trackView(); // 🔥 Track VIEW
  }

  /// 🔥 Track VIEW for AI
  Future<void> _trackView() async {
    if (_resolvedId == null) return;
    try {
      final trackingService = await UserInteractionService.create();
      await trackingService.recordView(
        itemId: _resolvedId!,
        itemType: 'attraction',
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadFavoriteStatus() async {
    if (_resolvedId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) return;

      final dio = Dio();
      final favoriteApi = FavoriteApiService(dio: dio, prefs: prefs);
      final isFav = await favoriteApi.isFavorite(
        userId: userId,
        serviceType: 'attraction',
        serviceId: _resolvedId!,
      );

      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    }
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

      // Fetch reviews
      List<Map<String, dynamic>> reviews = [];
      try {
        reviews = await api.getAttractionReviews(_resolvedId!);
        // Sort by newest first
        reviews.sort((a, b) {
          final aDate = a['createdAt'] as String? ?? '';
          final bDate = b['createdAt'] as String? ?? '';
          return bDate.compareTo(aDate);
        });
      } catch (e) {
        debugPrint('❌ Error loading attraction reviews: $e');
      }

      // Fetch rating summary from API
      Map<String, dynamic>? ratingSummary;
      try {
        ratingSummary = await api.getRatingSummary(_resolvedId!);
      } catch (_) {}

      setState(() {
        _detail = data;
        _reviews = reviews;
        _ratingSummaryData = ratingSummary;
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
          if (_resolvedId != null)
            FavoriteButton(
              serviceType: 'attraction',
              serviceId: _resolvedId!,
              size: 24,
              initialIsFavorite: _isFavorite,
            ),
          const SizedBox(width: 8),
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
                  child: _dateAndPeopleSelector(context, data),
                ),

                const SizedBox(height: 16),

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

                // Rating summary (Thông tin khách du lịch)
                _sectionWrapper(
                  context,
                  title: 'Thông tin khách du lịch',
                  child: _ratingSummary(context, data),
                ),

                // Reviews
                _sectionWrapper(
                  context,
                  title: 'Nhận xét từ khách du lịch',
                  trailing: _reviews.isNotEmpty
                      ? TextButton(
                          onPressed: () {
                            //  Navigate to all reviews screen
                            if (_resolvedId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttractionReviewsListScreen(
                                    attractionId: _resolvedId!,
                                    attractionName:
                                        _data['title']?.toString() ??
                                        'Điểm tham quan',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Xem tất cả',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : null,
                  child: _reviewsBlock(context),
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
    final reviewCount =
        _toInt(d['reviewCount']) ?? _toInt(d['totalReviews']) ?? 0;

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
            const SizedBox(width: 6),
            Text(
              '($reviewCount)',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== DATE AND PEOPLE SELECTOR =====
  Widget _dateAndPeopleSelector(BuildContext context, Map<String, dynamic> d) {
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: _visitDateLabel(),
            onTap: _openDatePicker,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.users,
            label: _peopleLabel(),
            onTap: () => _openPeopleSelector(d),
          ),
        ),
      ],
    );
  }

  Widget _outlinedChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: context.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, dynamic> d) {
    final price = _toDouble(d['price']) ?? 0;
    final currency = d['currencyCode']?.toString() ?? 'VND';
    final totalPrice = price * _people;
    final priceText = _formatPrice(totalPrice, currency);

    // Check capacity
    final maxParticipants = _toInt(d['maxParticipants']);
    final isSoldOut = maxParticipants != null && maxParticipants <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tổng: ',
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
              ' ($_people người)',
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
              backgroundColor: isSoldOut ? Colors.grey : context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: isSoldOut ? null : () => _navigateToBooking(d),
            child: Text(
              isSoldOut ? 'Đã hết chỗ' : 'Đặt vé ngay',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
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
        final isFull = rating >= i + 1;
        final isHalf = !isFull && rating >= i + 0.5;
        return Icon(
          isFull
              ? Icons.star_rounded
              : isHalf
              ? Icons.star_half_rounded
              : Icons.star_border_rounded,
          color: const Color(0xFFFFC107),
          size: 18,
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

  // ===== DATE AND PEOPLE PICKERS =====
  String _visitDateLabel() {
    if (_visitDate == null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return _formatDateShort(tomorrow);
    }
    return _formatDateShort(_visitDate!);
  }

  String _formatDateShort(DateTime d) {
    return '${d.day} thg ${d.month}, ${d.year}';
  }

  String _peopleLabel() {
    return '$_people người';
  }

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final initial = _visitDate ?? tomorrow;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Chọn ngày tham quan',
      confirmText: 'Xong',
      cancelText: 'Hủy',
    );

    if (picked != null && mounted) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _openPeopleSelector(Map<String, dynamic> d) async {
    int people = _people;

    final minParticipants = _toInt(d['minParticipants']) ?? 1;
    final maxParticipants = _toInt(d['maxParticipants']) ?? 50;

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Số lượng người',
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Người lớn',
                              style: context.bodyOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Từ $minParticipants-$maxParticipants người',
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: people > minParticipants
                                ? () => setLocal(() => people--)
                                : null,
                            icon: Icon(
                              LucideIcons.minus,
                              color: people > minParticipants
                                  ? context.primaryColor
                                  : context.textSecondaryColor,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$people',
                              textAlign: TextAlign.center,
                              style: context.bodyOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: people < maxParticipants
                                ? () => setLocal(() => people++)
                                : null,
                            icon: Icon(
                              LucideIcons.plus,
                              color: people < maxParticipants
                                  ? context.primaryColor
                                  : context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _people = people);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToBooking(Map<String, dynamic> d) {
    final now = DateTime.now();
    final visitDate = _visitDate ?? now.add(const Duration(days: 1));
    final attractionId = _resolvedId;

    if (attractionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không xác định được điểm tham quan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final title = d['title']?.toString() ?? 'Điểm tham quan';
    final price = _toDouble(d['price']) ?? 0;
    final currency = d['currencyCode']?.toString() ?? 'VND';
    final minParticipants = _toInt(d['minParticipants']);
    final maxParticipants = _toInt(d['maxParticipants']);
    final images = _imageList(d);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionBookingCheckoutScreen(
          attractionId: attractionId,
          attractionTitle: title,
          imageUrl: images.isNotEmpty ? images.first : null,
          basePrice: price,
          currencyCode: currency,
          visitDate: visitDate,
          people: _people,
          minParticipants: minParticipants,
          maxParticipants: maxParticipants,
        ),
      ),
    );
  }

  // ===== RATING SUMMARY (như Hotel) =====
  Widget _ratingSummary(BuildContext context, Map<String, dynamic> d) {
    // Use rating summary data from API if available
    final summary = _ratingSummaryData;
    if (summary == null) {
      return Text(
        'Chưa có đánh giá',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

    final avgRating = _toDouble(summary['avgRating']) ?? 0.0;

    // Aspects for attraction reviews
    final avgExperience = _toDouble(summary['avgExperience']) ?? 0.0;
    final avgValueForMoney = _toDouble(summary['avgValueForMoney']) ?? 0.0;
    final avgAccessibility = _toDouble(summary['avgAccessibility']) ?? 0.0;
    final avgFacilities = _toDouble(summary['avgFacilities']) ?? 0.0;
    final avgStaff = _toDouble(summary['avgStaff']) ?? 0.0;

    final label = avgRating >= 4.5
        ? 'Xuất sắc'
        : avgRating >= 4.0
        ? 'Rất tốt'
        : avgRating >= 3.5
        ? 'Tốt'
        : avgRating >= 2.5
        ? 'Khá'
        : 'Trung bình';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Overall rating
            Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: context.h5Style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  ),
                ),
                Text(
                  label,
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _starsRow(context, avgRating),
              ],
            ),
            const SizedBox(width: 24),
            // Right: 5 Aspects for attraction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAspectRow(context, 'Trải nghiệm', avgExperience),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Giá trị', avgValueForMoney),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Tiếp cận', avgAccessibility),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Tiện nghi', avgFacilities),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Nhân viên', avgStaff),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: () async {
              // Navigate to review screen
              if (_resolvedId != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => _buildReviewScreen()),
                );
                // Refresh if review was submitted successfully
                if (result == true) {
                  _fetchDetail();
                }
              }
            },
            icon: const Icon(LucideIcons.pencil),
            label: Text(
              'Viết đánh giá',
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewScreen() {
    final data = _data;
    return DetailAttractionReviewUserScreen(
      attractionId: _resolvedId!,
      attractionName: data['title']?.toString() ?? 'Điểm tham quan',
      attractionImage: _imageList(data).isNotEmpty
          ? _imageList(data).first
          : null,
    );
  }

  // Helper: Build aspect row with progress bar
  Widget _buildAspectRow(BuildContext context, String label, double value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (value / 5.0).clamp(0.0, 1.0),
              backgroundColor: context.dividerColor,
              valueColor: AlwaysStoppedAnimation(_getColorForRating(value)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            value.toStringAsFixed(1),
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // Helper: Get color based on rating value
  Color _getColorForRating(double rating) {
    if (rating >= 4.0) {
      return const Color(0xFF23A455); // Green
    } else if (rating >= 3.0) {
      return Colors.orange; // Orange
    } else {
      return Colors.red; // Red
    }
  }

  // ===== REVIEWS BLOCK =====
  Widget _reviewsBlock(BuildContext context) {
    if (_reviews.isEmpty) {
      return Text(
        'Chưa có đánh giá',
        style: context.captionStyle.copyWith(color: context.textSecondaryColor),
      );
    }

    // Show only first 3 reviews
    final visible = _reviews.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...visible.map((r) => _reviewItem(context, r))],
    );
  }

  Widget _reviewItem(BuildContext context, Map<String, dynamic> r) {
    final userName = r['userName']?.toString() ?? 'Người dùng';
    final rating = _toDouble(r['rating']) ?? 5.0;
    final content = r['content']?.toString() ?? '';
    final createdAt = r['createdAt']?.toString() ?? '';
    final date = _formatDate(createdAt);
    final reviewId = _toInt(r['reviewId']) ?? 0;
    final isExpanded = _expandedReviews.contains(reviewId);

    // Parse imageUrls (comma-separated string or list)
    List<String> imageUrls = [];
    final imageUrlsRaw = r['imageUrls'];
    if (imageUrlsRaw is String && imageUrlsRaw.isNotEmpty) {
      imageUrls = imageUrlsRaw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (imageUrlsRaw is List) {
      imageUrls = imageUrlsRaw
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userName,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _starsRow(context, rating),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: context.bodyTwoStyle.copyWith(height: 1.35),
                maxLines: isExpanded ? null : 4,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
              ),
              if (content.length > 150) ...[
                // Show button if content is long
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedReviews.remove(reviewId);
                      } else {
                        _expandedReviews.add(reviewId);
                      }
                    });
                  },
                  child: Text(
                    isExpanded ? 'Thu gọn' : 'Xem thêm',
                    style: context.captionStyle.copyWith(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Image gallery (if any)
          if (imageUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final url = imageUrls[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: url.startsWith('http')
                        ? Image.network(
                            url,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imagePlaceholder(context),
                          )
                        : Image.asset(url, fit: BoxFit.cover),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: imageUrls.length,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: context.dividerColor,
      child: Icon(LucideIcons.image, color: context.textSecondaryColor),
    );
  }

  String _formatDate(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
