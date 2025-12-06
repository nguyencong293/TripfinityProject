import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/restaurant_api_service.dart';

// Canonical dictionaries from supplier portal
const Map<String, String> kCuisinesDict = {
  'vietnamese': 'Việt Nam',
  'chinese': 'Trung Quốc',
  'japanese': 'Nhật Bản',
  'korean': 'Hàn Quốc',
  'italian': 'Ý',
  'french': 'Pháp',
  'thai': 'Thái Lan',
  'indian': 'Ấn Độ',
  'american': 'Mỹ',
  'mexican': 'Mexico',
  'seafood': 'Hải sản',
  'vegetarian': 'Chay',
  'fusion': 'Fusion',
  'bbq': 'Nướng/BBQ',
  'hotpot': 'Lẩu',
};

const Map<String, String> kServicesDict = {
  'dine_in': 'Dùng tại chỗ',
  'takeaway': 'Mang về',
  'delivery': 'Giao hàng',
  'reservation': 'Đặt bàn',
  'private_room': 'Phòng riêng',
  'buffet': 'Buffet',
  'outdoor_seating': 'Chỗ ngồi ngoài trời',
  'live_music': 'Nhạc sống',
  'wifi': 'WiFi',
  'parking': 'Bãi đỗ xe',
};

const Map<String, String> kDietsDict = {
  'vegetarian': 'Chay',
  'vegan': 'Thuần chay',
  'halal': 'Halal',
  'kosher': 'Kosher',
  'gluten_free': 'Không gluten',
  'dairy_free': 'Không sữa',
  'nut_free': 'Không hạt',
  'low_carb': 'Ít carb',
  'keto': 'Keto',
};

const Map<String, String> kAmbianceDict = {
  'romantic': 'Lãng mạn',
  'family_friendly': 'Thân thiện gia đình',
  'business': 'Kinh doanh',
  'casual': 'Thoải mái',
  'formal': 'Trang trọng',
  'cozy': 'Ấm cúng',
  'modern': 'Hiện đại',
  'traditional': 'Truyền thống',
  'rooftop': 'Rooftop',
  'beachfront': 'Ven biển',
};

const Map<String, String> kPaymentMethodsDict = {
  'cash': 'Tiền mặt',
  'credit_card': 'Thẻ tín dụng',
  'debit_card': 'Thẻ ghi nợ',
  'momo': 'MoMo',
  'zalopay': 'ZaloPay',
  'vnpay': 'VNPay',
};

const Map<String, String> kDaysOfWeekDict = {
  'monday': 'Thứ Hai',
  'tuesday': 'Thứ Ba',
  'wednesday': 'Thứ Tư',
  'thursday': 'Thứ Năm',
  'friday': 'Thứ Sáu',
  'saturday': 'Thứ Bảy',
  'sunday': 'Chủ Nhật',
};

class RestaurantDetailScreen extends StatefulWidget {
  final int? restaurantId;
  final Map<String, String>? restaurant;
  final Set<String>? activeCuisines;
  final Set<String>? activeServices;
  final Set<String>? activeDietaries;
  final Set<int>? activeStars;
  final bool activeOpenNow;
  final bool activeReservation;
  final bool activeTakeAway;

  const RestaurantDetailScreen({
    super.key,
    this.restaurantId,
    this.restaurant,
    this.activeCuisines,
    this.activeServices,
    this.activeDietaries,
    this.activeStars,
    this.activeOpenNow = false,
    this.activeReservation = false,
    this.activeTakeAway = false,
  }) : assert(
         restaurantId != null || restaurant != null,
         'restaurantId or restaurant fallback must be provided',
       );

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _introExpanded = false;
  final Set<int> _expandedReviews = {};

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _ratingSummaryData;

  int? _resolvedId;

  // Image slider
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _resolvedId =
        widget.restaurantId ?? _tryParseInt(widget.restaurant?['restaurantId']);
    _fetchDetail();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
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
                _imageGallery(_imageList(data)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(context, data),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _quickMeta(context, data),
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

                // Cuisines
                if (_listOfStrings(data['cuisinesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Loại ẩm thực',
                    child: _chipsRow(
                      context,
                      _mapKeysToLabels(
                        _listOfStrings(data['cuisinesJson']),
                        kCuisinesDict,
                      ),
                    ),
                  ),

                // Services
                if (_listOfStrings(data['servicesJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Dịch vụ',
                    child: _chipsRow(
                      context,
                      _mapKeysToLabels(
                        _listOfStrings(data['servicesJson']),
                        kServicesDict,
                      ),
                    ),
                  ),

                // Diets
                if (_listOfStrings(data['dietsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chế độ ăn',
                    child: _chipsRow(
                      context,
                      _mapKeysToLabels(
                        _listOfStrings(data['dietsJson']),
                        kDietsDict,
                      ),
                    ),
                  ),

                // Ambiance
                if (_listOfStrings(data['ambianceTagsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Không gian',
                    child: _chipsRow(
                      context,
                      _mapKeysToLabels(
                        _listOfStrings(data['ambianceTagsJson']),
                        kAmbianceDict,
                      ),
                    ),
                  ),

                // Menu highlights
                if (_listOfStrings(data['menuHighlightsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Món nổi bật',
                    child: _bulletList(
                      context,
                      _listOfStrings(data['menuHighlightsJson']),
                    ),
                  ),

                // Payment methods
                if (_listOfStrings(data['paymentMethodsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Phương thức thanh toán',
                    child: _chipsRow(
                      context,
                      _mapKeysToLabels(
                        _listOfStrings(data['paymentMethodsJson']),
                        kPaymentMethodsDict,
                      ),
                    ),
                  ),

                // Opening hours
                if (_openingHoursMap(data['openingHoursJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Giờ mở cửa',
                    child: _openingHoursBlock(
                      context,
                      _openingHoursMap(data['openingHoursJson']),
                    ),
                  ),

                // Policies
                if ((data['policiesText'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chính sách',
                    child: _bulletList(
                      context,
                      (data['policiesText'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Location
                _sectionWrapper(
                  context,
                  title: 'Vị trí',
                  child: _locationBlock(context, data),
                ),

                // Rating summary
                _sectionWrapper(
                  context,
                  title: 'Thông tin khách hàng',
                  child: _ratingSummary(context, data),
                ),

                // Reviews
                _sectionWrapper(
                  context,
                  title: 'Đánh giá',
                  child: _reviewsBlock(context),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  // ===== Data helpers =====
  Map<String, dynamic> get _data {
    if (_detail != null) return _detail!;
    if (widget.restaurant != null) {
      return Map<String, dynamic>.from(widget.restaurant!);
    }
    return {};
  }

  int? _tryParseInt(String? s) {
    if (s == null) return null;
    return int.tryParse(s);
  }

  List<String> _imageList(Map<String, dynamic> data) {
    final urls = data['imageUrls'];
    if (urls == null) return [];
    if (urls is String) {
      try {
        final decoded = jsonDecode(urls);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((u) => u.isNotEmpty)
              .toList();
        }
      } catch (_) {}
      return [];
    }
    if (urls is List) {
      return urls.map((e) => e.toString()).where((u) => u.isNotEmpty).toList();
    }
    return [];
  }

  List<String> _listOfStrings(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
      return [];
    }
    if (json is List) {
      return json.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, String> _openingHoursMap(dynamic json) {
    if (json == null) return {};
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          return Map<String, String>.from(decoded);
        }
      } catch (_) {}
      return {};
    }
    if (json is Map) {
      return Map<String, String>.from(json);
    }
    return {};
  }

  List<String> _mapKeysToLabels(List<String> keys, Map<String, String> dict) {
    return keys.map((key) => dict[key] ?? key).toList();
  }

  // ===== API =====
  Future<void> _fetchDetail() async {
    if (_resolvedId == null) {
      setState(() {
        _loading = false;
        _error = 'Restaurant ID is missing';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = RestaurantApiService(dio: Dio(), prefs: prefs);

      final detail = await api.getRestaurantById(_resolvedId!);

      // Fetch reviews
      List<Map<String, dynamic>> reviews = [];
      try {
        reviews = await api.getRestaurantReviews(_resolvedId!);
        // Sort by newest first
        reviews.sort((a, b) {
          final aDate = a['createdAt'] as String? ?? '';
          final bDate = b['createdAt'] as String? ?? '';
          return bDate.compareTo(aDate);
        });
      } catch (_) {}

      setState(() {
        _detail = detail;
        _reviews = reviews;
        _ratingSummaryData =
            null; // TODO: Add getRatingSummary to RestaurantApiService
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải thông tin nhà hàng';
      });
    }
  }

  // ===== UI Components =====
  Widget _imageGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        color: context.primaryColor.withValues(alpha: 0.1),
        child: Icon(LucideIcons.image, color: context.primaryColor, size: 48),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _imageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _imageIndex = i),
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    LucideIcons.image,
                    color: context.primaryColor,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final selected = index == _imageIndex;
                return GestureDetector(
                  onTap: () {
                    _imageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 64,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? context.primaryColor
                            : context.dividerColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: context.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _headerInfo(BuildContext context, Map<String, dynamic> data) {
    final name = data['title']?.toString() ?? 'Restaurant';
    final rating = data['ratingAverage']?.toString() ?? '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.h3Style.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(LucideIcons.star, size: 18, color: context.primaryColor),
            const SizedBox(width: 4),
            Text(
              rating,
              style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Icon(
              LucideIcons.mapPin,
              size: 16,
              color: context.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                data['location']?.toString() ?? '—',
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickMeta(BuildContext context, Map<String, dynamic> data) {
    final phone = data['phone']?.toString();
    final website = data['website']?.toString();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (phone != null && phone.isNotEmpty)
          _metaChip(
            context,
            icon: LucideIcons.phone,
            label: phone,
            onTap: () async {
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        if (website != null && website.isNotEmpty)
          _metaChip(
            context,
            icon: LucideIcons.globe,
            label: 'Website',
            onTap: () async {
              final uri = Uri.parse(website);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
      ],
    );
  }

  Widget _metaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Icon(icon, size: 14, color: context.primaryColor),
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
      ),
    );
  }

  Widget _priceAndAction(BuildContext context, Map<String, dynamic> data) {
    final price = data['price']?.toString() ?? '0';
    final currency = data['currencyCode']?.toString() ?? 'VND';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giá trung bình/người',
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(price, currency),
                  style: context.h4Style.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to booking
            },
            icon: const Icon(LucideIcons.calendar, size: 18),
            label: const Text('Đặt bàn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.buttonTextColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price, String currency) {
    final num = double.tryParse(price) ?? 0;
    if (currency == 'VND') {
      return '${num.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
    }
    return '$num $currency';
  }

  Widget _sectionWrapper(
    BuildContext context, {
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        border: Border(
          top: BorderSide(color: context.dividerColor.withValues(alpha: 0.3)),
          bottom: BorderSide(
            color: context.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.h5Style.copyWith(fontWeight: FontWeight.w700),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

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
          style: context.bodyOneStyle,
          maxLines: expanded ? null : 3,
          overflow: expanded ? null : TextOverflow.ellipsis,
        ),
        if (text.length > 150)
          TextButton(
            onPressed: onToggle,
            child: Text(
              expanded ? 'Thu gọn' : 'Xem thêm',
              style: TextStyle(color: context.primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _chipsRow(BuildContext context, List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item,
            style: context.captionStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

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
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Text(item, style: context.bodyOneStyle)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _openingHoursBlock(BuildContext context, Map<String, String> hours) {
    return Column(
      children: hours.entries.map((entry) {
        final dayLabel = kDaysOfWeekDict[entry.key] ?? entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayLabel,
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                entry.value,
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _locationBlock(BuildContext context, Map<String, dynamic> data) {
    final lat = data['latitude'];
    final lng = data['longitude'];
    final address = data['address']?.toString() ?? '';

    if (lat == null || lng == null) {
      return Text('Không có thông tin vị trí', style: context.bodyOneStyle);
    }

    final latNum = lat is num
        ? lat.toDouble()
        : double.tryParse(lat.toString());
    final lngNum = lng is num
        ? lng.toDouble()
        : double.tryParse(lng.toString());

    if (latNum == null || lngNum == null) {
      return Text('Tọa độ không hợp lệ', style: context.bodyOneStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.mapPin, size: 18, color: context.primaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(address, style: context.bodyOneStyle)),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latNum, lngNum),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('restaurant'),
                  position: LatLng(latNum, lngNum),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ratingSummary(BuildContext context, Map<String, dynamic> data) {
    if (_ratingSummaryData == null) {
      return Text('Chưa có đánh giá', style: context.bodyOneStyle);
    }

    final summary = _ratingSummaryData!;
    final avgRating = summary['averageRating']?.toString() ?? '0.0';
    final totalReviews = summary['totalReviews']?.toString() ?? '0';

    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  avgRating,
                  style: context.h2Style.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.primaryColor,
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: context.primaryColor,
                    );
                  }),
                ),
                Text(
                  '$totalReviews đánh giá',
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: List.generate(5, (i) {
                  final star = 5 - i;
                  final count = summary['rating${star}Count'] ?? 0;
                  final total = int.tryParse(totalReviews) ?? 1;
                  final percent = (count / total * 100).toInt();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('$star', style: context.captionStyle),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: context.dividerColor,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$percent%', style: context.captionStyle),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewsBlock(BuildContext context) {
    if (_reviews.isEmpty) {
      return Text('Chưa có đánh giá', style: context.bodyOneStyle);
    }

    return Column(
      children: _reviews.map((review) {
        final reviewId = review['reviewId'] as int;
        final isExpanded = _expandedReviews.contains(reviewId);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.3),
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
                    child: Text(
                      (review['userName']?.toString() ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['userName']?.toString() ?? 'User',
                          style: context.bodyOneStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              review['rating'] as int? ?? 0,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review['createdAt']?.toString() ?? '',
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review['comment']?.toString() ?? '',
                style: context.bodyOneStyle,
                maxLines: isExpanded ? null : 3,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
              ),
              if ((review['comment']?.toString() ?? '').length > 150)
                TextButton(
                  onPressed: () {
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
                    style: TextStyle(color: context.primaryColor),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
