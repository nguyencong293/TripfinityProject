import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/tour_api_service.dart';
import 'package:app/views/screens/tour_booking_checkout_screen.dart';

// Dictionaries for tour categories, services, languages (sync with backend)
const Map<String, String> kCategoriesDict = {
  'culture': 'Văn hóa',
  'nature': 'Thiên nhiên',
  'adventure': 'Phiêu lưu',
  'food': 'Ẩm thực',
  'beach': 'Biển',
  'mountain': 'Núi',
  'city': 'Thành phố',
  'historical': 'Lịch sử',
  'religious': 'Tâm linh',
  'wildlife': 'Động vật hoang dã',
  'photography': 'Nhiếp ảnh',
  'shopping': 'Mua sắm',
  'nightlife': 'Giải trí về đêm',
  'eco-tourism': 'Du lịch sinh thái',
  'wellness': 'Chăm sóc sức khỏe',
};

const Map<String, String> kServicesDict = {
  'pickup': 'Đón tận nơi',
  'airport_transfer': 'Đưa đón sân bay',
  'professional_guide': 'Hướng dẫn viên chuyên nghiệp',
  'tour_leader': 'Trưởng đoàn',
  'photographer': 'Nhiếp ảnh gia',
  'videographer': 'Quay phim',
  'bike_rental': 'Thuê xe đạp',
  'motorcycle_rental': 'Thuê xe máy',
  'car_rental': 'Thuê ô tô',
  'special_meals': 'Bữa ăn đặc biệt',
  'vegetarian_options': 'Thực đơn chay',
  'halal_meals': 'Thực đơn Halal',
  'wifi_on_board': 'WiFi trên xe',
  'audio_guide': 'Hướng dẫn âm thanh',
  'translation_device': 'Thiết bị phiên dịch',
  'first_aid_kit': 'Hộp sơ cứu',
  'travel_insurance': 'Bảo hiểm du lịch',
  'life_jacket': 'Áo phao',
  'helmet': 'Mũ bảo hiểm',
  'rain_gear': 'Áo mưa',
  'sun_protection': 'Kem chống nắng',
  'water_bottle': 'Chai nước',
  'snacks': 'Đồ ăn nhẹ',
  'souvenirs': 'Quà lưu niệm',
  'laundry_service': 'Giặt ủi',
  'medical_support': 'Hỗ trợ y tế',
  'children_care': 'Chăm sóc trẻ em',
  'wheelchair_accessible': 'Tiếp cận xe lăn',
  'baby_seat': 'Ghế em bé',
};

const Map<String, String> kLanguagesDict = {
  'vietnamese': 'Tiếng Việt',
  'english': 'English',
  'chinese': '中文 (Chinese)',
  'japanese': '日本語 (Japanese)',
  'korean': '한국어 (Korean)',
  'french': 'Français (French)',
  'german': 'Deutsch (German)',
  'spanish': 'Español (Spanish)',
  'russian': 'Русский (Russian)',
  'thai': 'ภาษาไทย (Thai)',
};

const Map<String, String> kIncludedDict = {
  'hotel': 'Khách sạn',
  'meals': 'Bữa ăn',
  'breakfast': 'Ăn sáng',
  'lunch': 'Ăn trưa',
  'dinner': 'Ăn tối',
  'transport': 'Phương tiện vận chuyển',
  'guide': 'Hướng dẫn viên',
  'insurance': 'Bảo hiểm',
  'entrance_fees': 'Phí vào cửa',
  'activities': 'Hoạt động',
  'equipment': 'Thiết bị',
  'water': 'Nước uống',
  'snacks': 'Đồ ăn nhẹ',
  'souvenirs': 'Quà lưu niệm',
  'photos': 'Ảnh chụp',
};

const Map<String, String> kExcludedDict = {
  'flights': 'Vé máy bay',
  'visa': 'Visa',
  'tips': 'Tiền tip',
  'personal_expenses': 'Chi phí cá nhân',
  'drinks': 'Đồ uống',
  'alcohol': 'Đồ uống có cồn',
  'laundry': 'Giặt ủi',
  'phone_calls': 'Điện thoại',
  'extra_activities': 'Hoạt động ngoài chương trình',
  'travel_insurance': 'Bảo hiểm du lịch mở rộng',
};

class TourServiceDetailScreen extends StatefulWidget {
  final int? tourId;
  final Map<String, dynamic>? tour;

  const TourServiceDetailScreen({super.key, this.tourId, this.tour})
    : assert(
        tourId != null || tour != null,
        'tourId or tour fallback must be provided',
      );

  @override
  State<TourServiceDetailScreen> createState() =>
      _TourServiceDetailScreenState();
}

class _TourServiceDetailScreenState extends State<TourServiceDetailScreen> {
  bool _introExpanded = false;

  // Loading state
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _reviews = [];

  int? _resolvedId;

  // Image slider
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _resolvedId = widget.tourId ?? _tryParseInt(widget.tour?['tourId']);
    _fetchDetail();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> get _data {
    // Ưu tiên dữ liệu từ API (_detail) hơn fallback (widget.tour)
    if (_detail != null) return _detail!;
    if (widget.tour != null) return widget.tour!;
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

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
                // Image Gallery (như hotel)
                _imageGallery(_imageList(data)),

                // Header Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(context, data),
                ),

                // Quick Meta (duration, capacity)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _quickMeta(context, data),
                ),

                const SizedBox(height: 12),

                // Price & Action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _priceAndAction(context, data),
                ),

                const SizedBox(height: 20),

                // Service Description
                if ((data['serviceDescription'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Giới thiệu',
                    child: _expandableText(
                      context,
                      text: data['serviceDescription']?.toString() ?? '',
                      expanded: _introExpanded,
                      onToggle: () =>
                          setState(() => _introExpanded = !_introExpanded),
                    ),
                  ),

                // Tour Type
                if (data['tourType'] != null)
                  _sectionWrapper(
                    context,
                    title: 'Loại tour',
                    child: _tourTypeChip(context, data['tourType']),
                  ),

                // Difficulty Level
                if (data['difficultyLevel'] != null)
                  _sectionWrapper(
                    context,
                    title: 'Độ khó',
                    child: _difficultyChip(context, data['difficultyLevel']),
                  ),

                // Duration & Schedule
                if (data['startDate'] != null ||
                    data['endDate'] != null ||
                    data['durationDays'] != null)
                  _sectionWrapper(
                    context,
                    title: 'Thời gian & Lịch trình',
                    child: _scheduleInfo(context, data),
                  ),

                // Capacity Info
                if (data['capacity'] != null || data['minParticipants'] != null)
                  _sectionWrapper(
                    context,
                    title: 'Số lượng khách',
                    child: _capacityInfo(context, data),
                  ),

                // Departure Info
                if ((data['departureLocation'] ?? '').toString().isNotEmpty ||
                    (data['meetingPoint'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Thông tin khởi hành',
                    child: _departureInfo(context, data),
                  ),

                // Guide Languages
                if (_parseJsonArray(data['guideLanguagesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Ngôn ngữ hướng dẫn',
                    child: _languageChips(
                      context,
                      _parseJsonArray(data['guideLanguagesJson']),
                    ),
                  ),

                // Categories
                if (_parseJsonArray(data['categoriesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Danh mục',
                    child: _categoryChips(
                      context,
                      _parseJsonArray(data['categoriesJson']),
                    ),
                  ),

                // Services
                if (_parseJsonArray(data['servicesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Dịch vụ đi kèm',
                    child: _serviceChips(
                      context,
                      _parseJsonArray(data['servicesJson']),
                    ),
                  ),

                // Itinerary Overview
                if ((data['itineraryOverview'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Tổng quan lịch trình',
                    child: _bulletList(
                      context,
                      (data['itineraryOverview'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Itinerary Details (day-by-day)
                if (_parseItineraryDetails(
                  data['itineraryDetailsJson'],
                ).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chi tiết lịch trình theo ngày',
                    child: _itineraryDetailsSection(
                      context,
                      _parseItineraryDetails(data['itineraryDetailsJson']),
                    ),
                  ),

                // Included/Excluded
                if (_parseJsonArray(data['includedJson']).isNotEmpty ||
                    _parseJsonArray(data['excludedJson']).isNotEmpty)
                  _includedExcludedSection(context, data),

                // Cancellation Policy
                if ((data['cancellationPolicy'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chính sách hủy tour',
                    child: _bulletList(
                      context,
                      (data['cancellationPolicy'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Policies Text
                if ((data['policiesText'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chính sách khác',
                    child: _bulletList(
                      context,
                      (data['policiesText'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Location (Address + Map)
                if ((data['location'] ?? '').toString().isNotEmpty ||
                    (data['address'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Vị trí',
                    child: _locationBlock(context, data),
                  ),

                // Rating Summary
                _sectionWrapper(
                  context,
                  title: 'Đánh giá',
                  child: _ratingSummary(context, data),
                ),

                // Reviews
                _sectionWrapper(
                  context,
                  title: 'Nhận xét từ khách du lịch',
                  trailing: _reviews.isNotEmpty
                      ? TextButton(
                          onPressed: () {},
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

  // ===== FETCH DETAIL (như hotel) =====
  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? detail;
      List<Map<String, dynamic>> reviews = [];

      if (_resolvedId != null) {
        final prefs = await SharedPreferences.getInstance();
        final api = TourApiService(dio: Dio(), prefs: prefs);

        detail = await api.getTourById(_resolvedId!);

        try {
          reviews = await api.getTourReviews(_resolvedId!);
          reviews.sort((a, b) {
            final aDate = a['createdAt'] as String? ?? '';
            final bDate = b['createdAt'] as String? ?? '';
            return bDate.compareTo(aDate);
          });
        } catch (e) {
          debugPrint('❌ Error loading tour reviews: $e');
        }
      }

      setState(() {
        _detail = detail;
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải chi tiết tour. Vui lòng thử lại.';
      });
    }
  }

  // ===== IMAGE GALLERY (như hotel với PageView) =====
  Widget _imageGallery(List<String> images) {
    final hasImages = images.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? context.primaryColor
                            : context.dividerColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: url.startsWith('http')
                        ? Image.network(url, fit: BoxFit.cover)
                        : Image.asset(url, fit: BoxFit.cover),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: images.length,
            ),
          ),
      ],
    );
  }

  List<String> _imageList(Map<String, dynamic> data) {
    final List<String> result = [];

    // Add thumbnail first
    final thumbnail = data['thumbnailUrl']?.toString();
    if (thumbnail != null && thumbnail.isNotEmpty) {
      result.add(thumbnail);
    }

    // Add imageUrls
    final imageUrls = data['imageUrls'];
    if (imageUrls != null) {
      if (imageUrls is List) {
        for (final url in imageUrls) {
          final urlStr = url?.toString();
          if (urlStr != null && urlStr.isNotEmpty && !result.contains(urlStr)) {
            result.add(urlStr);
          }
        }
      }
    }

    return result;
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor, size: 40),
    );
  }

  // ===== HEADER INFO =====
  Widget _headerInfo(BuildContext context, Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? '';
    final rating = _parseDouble(data['ratingAverage']) ?? 0.0;
    final reviewCount = _reviews.length;
    final location = data['location']?.toString() ?? '';
    final badges = _parseJsonArray(data['badges']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.h5Style.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _starsRow(context, rating),
            const SizedBox(width: 6),
            Text(
              '(${rating.toStringAsFixed(1)})',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (reviewCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '$reviewCount đánh giá',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
        if (location.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 14,
                color: context.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((badge) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: context.captionStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: [
            _inlineAction(context, 'Gọi', data),
            _inlineAction(context, 'Viết đánh giá', data),
            _inlineAction(context, 'Email', data),
          ],
        ),
      ],
    );
  }

  // ===== QUICK META =====
  Widget _quickMeta(BuildContext context, Map<String, dynamic> data) {
    final durationDays = data['durationDays'];
    final capacity = data['capacity'] ?? data['maxParticipants'];

    return Row(
      children: [
        if (durationDays != null)
          Expanded(
            child: _metaChip(
              context,
              icon: LucideIcons.calendar,
              label: '$durationDays ngày',
            ),
          ),
        if (durationDays != null && capacity != null) const SizedBox(width: 12),
        if (capacity != null)
          Expanded(
            child: _metaChip(
              context,
              icon: LucideIcons.users,
              label: '$capacity người',
            ),
          ),
      ],
    );
  }

  Widget _metaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: context.textSecondaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ===== PRICE & ACTION =====
  Widget _priceAndAction(BuildContext context, Map<String, dynamic> data) {
    final price = data['price'];
    final currency = data['currencyCode']?.toString() ?? 'VND';

    String priceText = '';
    if (price != null) {
      if (currency == 'VND') {
        final intVal =
            (price is num ? price : num.tryParse(price.toString()))?.toInt() ??
            0;
        final formatted = intVal.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
        priceText = '$formatted đ';
      } else {
        priceText = '$price $currency';
      }
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giá từ',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              Text(
                priceText.isEmpty ? '—' : priceText,
                style: context.h5Style.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Navigate to tour booking checkout
              final tourData = _data;
              final images = _imageList(tourData);

              // Parse duration from tour data
              final durationDays = tourData['durationDays'] as int? ?? 3;
              final startDate = DateTime.now().add(const Duration(days: 1));
              final endDate = startDate.add(Duration(days: durationDays));

              // Parse capacity from tour data
              final minPart = tourData['minParticipants'] as int?;
              final maxPart = tourData['maxParticipants'] as int?;
              final capacity = tourData['capacity'] as int?;
              final defaultPeople = minPart ?? 2;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TourBookingCheckoutScreen(
                    tourId: _resolvedId ?? 0,
                    tourTitle: tourData['title']?.toString() ?? 'Tour',
                    imageUrl: images.isNotEmpty ? images[0] : null,
                    basePrice:
                        double.tryParse(tourData['price']?.toString() ?? '0') ??
                        0,
                    currencyCode: tourData['currencyCode']?.toString() ?? 'VND',
                    dateRange: DateTimeRange(start: startDate, end: endDate),
                    people: defaultPeople,
                    minParticipants: minPart,
                    maxParticipants: maxPart ?? capacity,
                  ),
                ),
              );
            },
            child: const Text(
              'Đặt ngay',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
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
          maxLines: expanded ? null : 4,
          overflow: expanded ? null : TextOverflow.ellipsis,
          style: context.bodyTwoStyle.copyWith(height: 1.5),
        ),
        if (text.length > 200) ...[
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
      ],
    );
  }

  // ===== TOUR TYPE CHIP =====
  Widget _tourTypeChip(BuildContext context, dynamic type) {
    final typeStr = type?.toString() ?? '';
    String label = '';

    switch (typeStr.toLowerCase()) {
      case 'group':
        label = 'Tour nhóm';
        break;
      case 'private':
        label = 'Tour riêng';
        break;
      case 'custom':
        label = 'Tour tùy chỉnh';
        break;
      default:
        label = typeStr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.primaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.tag, size: 14, color: context.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.captionStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== DIFFICULTY CHIP =====
  Widget _difficultyChip(BuildContext context, dynamic difficulty) {
    final diffStr = difficulty?.toString().toLowerCase() ?? 'easy';

    String label = '';
    Color color = context.primaryColor;

    switch (diffStr) {
      case 'easy':
        label = 'Dễ';
        color = Colors.green;
        break;
      case 'moderate':
        label = 'Trung bình';
        color = Colors.orange;
        break;
      case 'hard':
        label = 'Khó';
        color = Colors.red;
        break;
      default:
        label = difficulty?.toString() ?? 'Dễ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.trendingUp, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.captionStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== SCHEDULE INFO =====
  Widget _scheduleInfo(BuildContext context, Map<String, dynamic> data) {
    final startDate = data['startDate']?.toString();
    final endDate = data['endDate']?.toString();
    final durationDays = data['durationDays'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (startDate != null && startDate.isNotEmpty)
          _infoRow(context, LucideIcons.calendar, 'Ngày bắt đầu: $startDate'),
        if (endDate != null && endDate.isNotEmpty)
          _infoRow(
            context,
            LucideIcons.calendarCheck,
            'Ngày kết thúc: $endDate',
          ),
        if (durationDays != null)
          _infoRow(
            context,
            LucideIcons.clock,
            'Thời lượng: $durationDays ngày',
          ),
      ],
    );
  }

  // ===== CAPACITY INFO =====
  Widget _capacityInfo(BuildContext context, Map<String, dynamic> data) {
    final capacity = data['capacity'];
    final minPart = data['minParticipants'];
    final maxPart = data['maxParticipants'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (capacity != null)
          _infoRow(context, LucideIcons.users, 'Sức chứa: $capacity người'),
        if (minPart != null)
          _infoRow(context, LucideIcons.userMinus, 'Tối thiểu: $minPart người'),
        if (maxPart != null)
          _infoRow(context, LucideIcons.userPlus, 'Tối đa: $maxPart người'),
      ],
    );
  }

  // ===== DEPARTURE INFO =====
  Widget _departureInfo(BuildContext context, Map<String, dynamic> data) {
    final departure = data['departureLocation']?.toString();
    final meeting = data['meetingPoint']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (departure != null && departure.isNotEmpty)
          _infoRow(
            context,
            LucideIcons.navigation,
            'Điểm khởi hành: $departure',
          ),
        if (meeting != null && meeting.isNotEmpty)
          _infoRow(context, LucideIcons.mapPin, 'Điểm tập trung: $meeting'),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: context.bodyTwoStyle)),
        ],
      ),
    );
  }

  // ===== LANGUAGE CHIPS =====
  Widget _languageChips(BuildContext context, List<String> languages) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: languages.map((lang) {
        final label = kLanguagesDict[lang] ?? lang;
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
              Icon(LucideIcons.globe, size: 14, color: context.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.captionStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== CATEGORY CHIPS =====
  Widget _categoryChips(BuildContext context, List<String> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final label = kCategoriesDict[cat] ?? cat;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.dividerColor),
          ),
          child: Text(
            label,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }

  // ===== SERVICE CHIPS =====
  Widget _serviceChips(BuildContext context, List<String> services) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) {
        final label = kServicesDict[service] ?? service;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.check, size: 14, color: context.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== BULLET LIST =====
  Widget _bulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item, style: context.captionStyle)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== ITINERARY DETAILS SECTION (day-by-day) =====
  Widget _itineraryDetailsSection(
    BuildContext context,
    List<Map<String, dynamic>> details,
  ) {
    return Column(
      children: details.map((day) {
        final dayNum = day['day'] ?? 0;
        final title = day['title']?.toString() ?? '';
        final activities = day['activities'];

        List<String> activityList = [];
        if (activities is List) {
          activityList = activities.map((e) => e.toString()).toList();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ngày $dayNum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: context.bodyTwoStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (activityList.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...activityList.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(activity, style: context.captionStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== INCLUDED/EXCLUDED SECTION =====
  Widget _includedExcludedSection(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final included = _parseJsonArray(data['includedJson']);
    final excluded = _parseJsonArray(data['excludedJson']);

    return Column(
      children: [
        if (included.isNotEmpty)
          _sectionWrapper(
            context,
            title: 'Bao gồm',
            child: Column(
              children: included.map((item) {
                final label = kIncludedDict[item] ?? item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 16,
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label, style: context.captionStyle)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        if (excluded.isNotEmpty)
          _sectionWrapper(
            context,
            title: 'Không bao gồm',
            child: Column(
              children: excluded.map((item) {
                final label = kExcludedDict[item] ?? item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.xCircle,
                        size: 16,
                        color: context.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label, style: context.captionStyle)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ===== LOCATION BLOCK (Address + Google Maps) =====
  Widget _locationBlock(BuildContext context, Map<String, dynamic> data) {
    final address = data['address']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final lat = _parseDouble(data['latitude']);
    final lng = _parseDouble(data['longitude']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (location.isNotEmpty)
          Text(
            location,
            style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        if (address.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(address, style: context.captionStyle),
        ],
        if (lat != null && lng != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('tour_location'),
                    position: LatLng(lat, lng),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===== RATING SUMMARY =====
  Widget _ratingSummary(BuildContext context, Map<String, dynamic> data) {
    final rating = _parseDouble(data['ratingAverage']) ?? 0.0;
    final reviewCount = _reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rating.toStringAsFixed(1),
                    style: context.bodyTwoStyle.copyWith(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _starsRow(context, rating),
                    const SizedBox(height: 4),
                    Text(
                      '$reviewCount đánh giá',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== REVIEWS BLOCK =====
  Widget _reviewsBlock(BuildContext context) {
    if (_reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.dividerColor),
        ),
        child: Center(
          child: Text(
            'Chưa có đánh giá',
            style: context.captionStyle.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    final visible = _reviews.take(3).toList();

    return Column(
      children: visible.map((review) {
        final rating = _parseDouble(review['rating']) ?? 0.0;
        final title = review['title']?.toString();
        final content = review['content']?.toString() ?? '';
        final createdAt = review['createdAt']?.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      LucideIcons.user,
                      size: 18,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khách du lịch',
                          style: context.bodyTwoStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (createdAt != null)
                          Text(
                            createdAt,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _starsRow(context, rating),
                ],
              ),
              if (title != null && title.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  title,
                  style: context.bodyTwoStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                content,
                style: context.captionStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== STARS ROW =====
  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: context.primaryColor,
        );
      }),
    );
  }

  // ===== HELPER PARSERS =====
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  List<String> _parseJsonArray(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is List) {
          return parsed.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  List<Map<String, dynamic>> _parseItineraryDetails(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is List) {
          return parsed
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // ===== INLINE ACTIONS =====
  Widget _inlineAction(
    BuildContext context,
    String label,
    Map<String, dynamic> data,
  ) {
    return InkWell(
      onTap: () => _handleAction(context, label, data),
      child: Text(
        label,
        style: context.captionStyle.copyWith(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String action,
    Map<String, dynamic> data,
  ) async {
    if (action == 'Gọi') {
      final providerId = data['providerId'];
      if (providerId == null) {
        _showError('Không tìm thấy thông tin nhà cung cấp');
        return;
      }

      final phone = await _getProviderPhone(providerId);
      if (phone != null && phone.isNotEmpty) {
        _showError('Gọi: $phone');
      } else {
        _showError('Không tìm thấy số điện thoại');
      }
    } else if (action == 'Viết đánh giá') {
      if (_resolvedId == null) {
        _showError('Không tìm thấy ID tour');
        return;
      }
      _showError('Chức năng đánh giá đang được phát triển');
    } else if (action == 'Email') {
      final providerId = data['providerId'];
      if (providerId == null) {
        _showError('Không tìm thấy thông tin nhà cung cấp');
        return;
      }

      final email = await _getProviderEmail(providerId);
      if (email != null && email.isNotEmpty) {
        _showError('Email: $email');
      } else {
        _showError('Không tìm thấy email');
      }
    }
  }

  Future<String?> _getProviderPhone(dynamic providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:8080/api/providers/${providerId.toString()}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (prefs.getString('user_token') != null)
              'Authorization': 'Bearer ${prefs.getString('user_token')}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return response.data['contactPhone']?.toString();
      }
    } catch (e) {
      debugPrint('Error fetching provider phone: $e');
    }
    return null;
  }

  Future<String?> _getProviderEmail(dynamic providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:8080/api/providers/${providerId.toString()}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (prefs.getString('user_token') != null)
              'Authorization': 'Bearer ${prefs.getString('user_token')}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return response.data['contactEmail']?.toString();
      }
    } catch (e) {
      debugPrint('Error fetching provider email: $e');
    }
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
