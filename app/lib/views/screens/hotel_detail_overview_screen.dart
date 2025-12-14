import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/app_config.dart';

// NEW: API
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/hotel_api_service.dart';
import 'package:app/services/review_api_service.dart';
import 'package:app/services/favorite_api_service.dart';
import 'package:app/views/screens/hotel_booking_checkout_screen.dart';
import 'package:app/views/screens/detail_hotel_review_user_screen.dart';
import 'package:app/views/screens/hotel_reviews_list_screen.dart';
import 'package:app/views/widgets/favorite_button.dart';

// Canonical dictionaries: keep in sync with Supplier (HotelViewPage / Create/Edit)
const Map<int, String> kHighlightsDict = {
  1: "View biển",
  2: "View núi",
  3: "Trung tâm thành phố",
  4: "Gần sân bay",
  5: "Hồ bơi ngoài trời",
  6: "Hồ bơi trong nhà",
  7: "Spa & Massage",
  8: "Phòng gym",
  9: "Nhà hàng cao cấp",
  10: "Bar & Lounge",
  11: "Bãi biển riêng",
  12: "Hồ bơi vô cực",
  13: "Bar hồ bơi",
  14: "Câu lạc bộ trẻ em (Kids Club)",
  15: "Dịch vụ trông trẻ",
  16: "Sân tennis",
  17: "Sân golf gần kề",
  18: "Thể thao dưới nước",
  19: "Lặn biển / Snorkeling",
  20: "Kayak / Chèo SUP",
  21: "Công viên nước mini",
  22: "Rooftop bar",
  23: "Nhà hàng buffet",
  24: "Trung tâm hội nghị / phòng họp",
  25: "Dịch vụ đưa đón sân bay",
  26: "Dịch vụ đưa đón trong khu",
  27: "Bãi đỗ xe có nhân viên (valet)",
  28: "Xông hơi / Sauna",
  29: "Bể sục / Jacuzzi",
  30: "Khu vui chơi trẻ em",
};

const Map<int, String> kAmenitiesDict = {
  1: "WiFi miễn phí",
  2: "Điều hòa",
  3: "Tivi màn hình phẳng",
  4: "Minibar",
  5: "Két an toàn",
  6: "Máy sấy tóc",
  7: "Dịch vụ phòng 24/7",
  8: "Bãi đậu xe miễn phí",
  9: "Đưa đón sân bay",
  10: "Cho phép thú cưng",
  11: "Máy pha cà phê / Ấm đun",
  12: "Áo choàng tắm & Dép đi trong phòng",
  13: "Ban công / Sân hiên",
  14: "Tầm nhìn ra biển / hồ / núi",
  15: "Góc bếp (kitchenette)",
  16: "Máy giặt",
  17: "Bàn ủi / Bàn là",
  18: "Lễ tân 24/7",
  19: "Dịch vụ Concierge",
  20: "Giữ hành lý",
  21: "Thang máy",
  22: "Phòng/tiện nghi cho người khuyết tật",
  23: "Đổi tiền / ATM",
  24: "Trạm sạc xe điện",
  25: "Phòng xông hơi / Sauna",
  26: "Phòng tắm hơi ướt / Steam",
  27: "Bồn tắm nóng / Jacuzzi",
  28: "Hồ bơi trẻ em",
  29: "Sân chơi trẻ em",
  30: "Sân tennis / Thuê vợt",
  31: "Thuê xe đạp",
  32: "Dịch vụ thuê xe / taxi",
  33: "Bãi biển gần",
  34: "Phòng họp / Tiệc",
  35: "Ăn sáng miễn phí",
};

class HotelDetailOverviewScreen extends StatefulWidget {
  // Prefer id to fetch live detail
  final int? hotelId;

  // Optional fallback for instant UI while fetching (from search list)
  final Map<String, String>? hotel;

  // Set of selected amenities to highlight (optional)
  final Set<String>? activeAmenities;

  const HotelDetailOverviewScreen({
    super.key,
    this.hotelId,
    this.hotel,
    this.activeAmenities,
  }) : assert(
         hotelId != null || hotel != null,
         'hotelId or hotel fallback must be provided',
       );

  @override
  State<HotelDetailOverviewScreen> createState() =>
      _HotelDetailOverviewScreenState();
}

class _HotelDetailOverviewScreenState extends State<HotelDetailOverviewScreen> {
  bool _introExpanded = false;
  final Set<int> _expandedReviews = {}; // Track which reviews are expanded
  final Set<int> _expandedReplies = {}; // Track which replies are expanded
  final Map<int, List<Map<String, dynamic>>> _repliesCache =
      {}; // Cache replies by reviewId

  // Loading state
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  List<Map<String, dynamic>> _reviews = [];
  Map<String, dynamic>? _ratingSummaryData; // NEW: rating summary data

  int? _resolvedId;
  bool _isFavorite = false;

  // Image slider state
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  // Date and guests/rooms selection
  DateTimeRange? _dateRange;
  int _rooms = 1;
  int _peopleCount = 2;

  // Note: amenity catalogs now driven entirely by backend IDs using kAmenitiesDict/kHighlightsDict

  final Map<String, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
    _resolvedId = widget.hotelId ?? _tryParseInt(widget.hotel?['hotelId']);
    _loadFavoriteStatus();
    _fetchDetail();
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
        serviceType: 'hotel',
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
              serviceType: 'hotel',
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
                _imageGallery(_imageList(data)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _headerInfo(context, data),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _quickMeta(context),
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

                // Highlights mapped from backend IDs
                if (_listOfInt(data['highlightsJson']).isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Điểm nổi bật',
                    child: _bulletList(
                      context,
                      _mapIdsToLabels(
                        _listOfInt(data['highlightsJson']),
                        kHighlightsDict,
                      ),
                    ),
                  ),

                // Amenities mapped from backend IDs
                if (_listOfInt(data['amenitiesJson']).isNotEmpty)
                  _amenitiesBlock(
                    context,
                    title: 'Tiện nghi',
                    amenities: _mapIdsToLabels(
                      _listOfInt(data['amenitiesJson']),
                      kAmenitiesDict,
                    ),
                    initiallyVisible: 8,
                  ),

                // Policies
                if ((data['policiesText'] ?? '').toString().isNotEmpty)
                  _sectionWrapper(
                    context,
                    title: 'Chính sách & tuỳ chọn',
                    child: _bulletList(
                      context,
                      (data['policiesText'] as String)
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                    ),
                  ),

                // Khu vực
                _sectionWrapper(
                  context,
                  title: 'Khu vực',
                  child: _locationBlock(context, data),
                ),

                // Thông tin khách du lịch (rating summary placeholder)
                _sectionWrapper(
                  context,
                  title: 'Thông tin khách du lịch',
                  child: _ratingSummary(context, data),
                ),

                // Reviews
                _sectionWrapper(
                  context,
                  title: 'Đánh giá',
                  trailing: _reviews.isNotEmpty
                      ? TextButton(
                          onPressed: () {
                            if (widget.hotelId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HotelReviewsListScreen(
                                    hotelId: widget.hotelId!,
                                    hotelName:
                                        data['title']?.toString() ??
                                        'Khách sạn',
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

  // ===== Fetch & merge =====
  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? detail;
      List<Map<String, dynamic>> reviews = [];
      Map<String, dynamic>? ratingSummary;

      if (_resolvedId != null) {
        final prefs = await SharedPreferences.getInstance();
        final api = HotelApiService(dio: Dio(), prefs: prefs);

        detail = await api.getHotelById(_resolvedId!);
        // Reviews are optional; load but don't fail the whole screen
        try {
          reviews = await api.getHotelReviews(_resolvedId!);

          // Sort by createdAt DESC (newest first)
          reviews.sort((a, b) {
            final aDate = a['createdAt'] as String? ?? '';
            final bDate = b['createdAt'] as String? ?? '';
            return bDate.compareTo(aDate);
          });

          debugPrint(
            '📥 Flutter loaded ${reviews.length} reviews for hotel $_resolvedId',
          );
          if (reviews.isNotEmpty) {
            final first = reviews[0];
            debugPrint(
              '🔍 Sample review: reviewId=${first['reviewId']}, likesCount=${first['likesCount']}, replyCount=${first['replyCount']}',
            );
          }
        } catch (e) {
          debugPrint('❌ Error loading reviews: $e');
        }
        // Rating summary
        try {
          ratingSummary = await api.getRatingSummary(_resolvedId!);
        } catch (_) {}
      } else {
        // No id: render fallback only
        detail = null;
      }

      setState(() {
        _detail = detail;
        _reviews = reviews;
        _ratingSummaryData = ratingSummary;
        _loading = false;
      });

      // Debug log để kiểm tra availableRooms
      if (detail != null) {
        debugPrint(
          '🏨 Hotel Detail: totalRooms=${detail['totalRooms']}, availableRooms=${detail['availableRooms']}, capacity=${detail['capacity']}, availableCapacity=${detail['availableCapacity']}',
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Không thể tải chi tiết khách sạn. Vui lòng thử lại.';
      });
    }
  }

  Map<String, dynamic> get _data {
    // Merge: fetched detail wins over fallback
    final merged = <String, dynamic>{};
    if (widget.hotel != null) merged.addAll(widget.hotel!);
    if (_detail != null) merged.addAll(_detail!);
    return merged;
  }

  // ===== UI pieces =====
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

  Widget _headerInfo(BuildContext context, Map<String, dynamic> d) {
    final name = d['title']?.toString() ?? d['name']?.toString() ?? '';
    final ratingAvg =
        _toDouble(d['ratingAverage']) ?? _toDouble(d['rating']) ?? 0.0;
    final ratingLabel = ratingAvg > 4.2
        ? 'Tuyệt vời'
        : ratingAvg > 3.5
        ? 'Tốt'
        : ratingAvg > 2.5
        ? 'Ổn'
        : '—';

    final reviewsCount =
        _reviews.length; // can replace by aggregate if backend adds

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _starsRow(context, ratingAvg),
            const SizedBox(width: 8),
            Text(
              ratingAvg.toStringAsFixed(1),
              style: context.captionStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '($reviewsCount)',
                style: context.captionStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (ratingLabel != '—') ...[
          const SizedBox(height: 4),
          Text(
            ratingLabel,
            style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          children: [
            _inlineAction(context, 'Gọi', _data),
            _inlineAction(context, 'Viết đánh giá', _data),
            _inlineAction(context, 'Email', _data),
          ],
        ),
      ],
    );
  }

  Widget _quickMeta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.calendar,
            label: _dateRangeLabel(),
            onTap: _openDateRangePicker,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _outlinedChip(
            context,
            icon: LucideIcons.bedSingle,
            label: _guestRoomLabel(),
            onTap: _openGuestRoomSelector,
          ),
        ),
      ],
    );
  }

  Widget _priceAndAction(BuildContext context, Map<String, dynamic> d) {
    final price = d['price'];
    final currency = d['currencyCode']?.toString();
    num? unit;
    if (price is num) {
      unit = price;
    } else if (price != null) {
      unit = num.tryParse(price.toString());
    }
    final total = unit == null ? null : unit * _rooms;
    final priceText = total == null
        ? (d['price']?.toString() ?? '—')
        : _formatPrice(total, currency);

    // Lấy số phòng còn trống từ API (khai báo ở đầu để dùng trong toàn bộ widget)
    int? availableRooms;
    int? totalRooms;

    final availableRaw = d['availableRooms'] ?? d['available_rooms'];
    if (availableRaw is int) {
      availableRooms = availableRaw;
    } else if (availableRaw != null) {
      availableRooms = int.tryParse(availableRaw.toString());
    }

    final totalRaw = d['totalRooms'] ?? d['total_rooms'];
    if (totalRaw is int) {
      totalRooms = totalRaw;
    } else if (totalRaw != null) {
      totalRooms = int.tryParse(totalRaw.toString());
    }

    // Nếu không có availableRooms, fallback về totalRooms hoặc capacity
    availableRooms ??= totalRooms;
    if (availableRooms == null) {
      final capRaw = d['capacity'];
      if (capRaw is num) {
        availableRooms = capRaw.toInt();
      } else if (capRaw != null) {
        availableRooms = int.tryParse(capRaw.toString());
      }
    }

    // Debug log
    debugPrint(
      '🎯 Button render: availableRooms=$availableRooms, _rooms=$_rooms, totalRooms=$totalRooms',
    );
    final isSoldOut = availableRooms != null && availableRooms <= 0;
    debugPrint('🚫 isSoldOut=$isSoldOut');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
          style: context.bodyOneStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSoldOut
                  ? Colors.grey
                  : const Color(0xFF23A455),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            onPressed: isSoldOut
                ? null
                : () {
                    // Prepare date range: use user's selection if any.
                    // Otherwise, default to tonight→tomorrow to ensure at least 1 night.
                    final now = DateTime.now();
                    final range =
                        _dateRange ??
                        DateTimeRange(
                          start: DateTime(now.year, now.month, now.day),
                          end: DateTime(
                            now.year,
                            now.month,
                            now.day,
                          ).add(const Duration(days: 1)),
                        );

                    // Resolve fields
                    final hotelId =
                        _resolvedId ??
                        (_tryParseInt(d['hotelId']) ?? _tryParseInt(d['id']));
                    final title =
                        d['title']?.toString() ??
                        d['name']?.toString() ??
                        'Khách sạn';
                    final currency = d['currencyCode']?.toString();
                    num basePrice = 0;
                    final price = d['price'];
                    if (price is num) {
                      basePrice = price;
                    } else if (price != null) {
                      basePrice = num.tryParse(price.toString()) ?? 0;
                    }
                    num? extraPerNight;
                    final extraRaw = d['pricePerNight'];
                    if (extraRaw is num) {
                      extraPerNight = extraRaw;
                    } else if (extraRaw != null) {
                      extraPerNight = num.tryParse(extraRaw.toString());
                    }

                    // Constraints
                    int? minParticipants;
                    final minRaw =
                        d['minParticipants'] ?? d['min_participants'];
                    if (minRaw is num) {
                      minParticipants = minRaw.toInt();
                    } else if (minRaw != null) {
                      minParticipants = int.tryParse(minRaw.toString());
                    }

                    int? maxParticipants;
                    final maxRaw =
                        d['maxParticipants'] ?? d['max_participants'];
                    if (maxRaw is num) {
                      maxParticipants = maxRaw.toInt();
                    } else if (maxRaw != null) {
                      maxParticipants = int.tryParse(maxRaw.toString());
                    }

                    int? maxBedsPerRoom;
                    final bedsRaw =
                        d['maxBedsPerRoom'] ?? d['max_beds_per_room'];
                    if (bedsRaw is num) {
                      maxBedsPerRoom = bedsRaw.toInt();
                    } else if (bedsRaw != null) {
                      maxBedsPerRoom = int.tryParse(bedsRaw.toString());
                    }

                    if (hotelId == null) {
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      messenger?.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Không xác định được khách sạn để đặt.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Kiểm tra còn phòng trống không
                    if (availableRooms != null && availableRooms <= 0) {
                      // Không còn phòng trống
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Khách sạn đã hết phòng trống!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HotelBookingCheckoutScreen(
                          hotelId: hotelId,
                          hotelTitle: title,
                          imageUrl: _imageList(d).isNotEmpty
                              ? _imageList(d).first
                              : null,
                          basePrice: basePrice,
                          extraPricePerNight: extraPerNight,
                          currencyCode: currency,
                          dateRange: range,
                          rooms: _rooms,
                          people: _peopleCount,
                          minParticipants: minParticipants,
                          maxParticipants: maxParticipants,
                          maxBedsPerRoom: maxBedsPerRoom,
                          maxRooms:
                              availableRooms, // Sử dụng availableRooms thay vì capacity
                        ),
                      ),
                    );
                  },
            child: Text(
              isSoldOut ? 'Đã hết phòng' : 'Đặt khách sạn',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _amenitiesBlock(
    BuildContext context, {
    required String title,
    required List amenities, // accepts List<String> or List<_Amenity>
    int initiallyVisible = 6,
  }) {
    final List<_Amenity> amenityObjs = _coerceAmenities(amenities);
    final active = widget.activeAmenities ?? const <String>{};
    final showAllKey = '_showAll_$title';
    final showingAll = _expandedState[showAllKey] ?? false;
    final visibleList = showingAll
        ? amenityObjs
        : amenityObjs
              .take(initiallyVisible.clamp(0, amenityObjs.length))
              .toList();

    return _sectionWrapper(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visibleList.map((a) {
              final highlighted = active.contains(a.name);
              return _amenityChip(context, a, highlighted);
            }).toList(),
          ),
          if (amenityObjs.length > initiallyVisible)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _expandedState[showAllKey] = !showingAll;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  showingAll ? 'Thu gọn' : 'Hiển thị thêm',
                  style: context.captionStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_Amenity> _coerceAmenities(List raw) {
    return raw.map<_Amenity>((e) {
      if (e is _Amenity) return e;
      return _Amenity(e.toString(), LucideIcons.check);
    }).toList();
  }

  Widget _amenityChip(BuildContext context, _Amenity a, bool highlighted) {
    final bg = highlighted ? context.primaryColor : context.cardBackgroundColor;
    final fg = highlighted
        ? context.buttonTextColor
        : context.textSecondaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? context.primaryColor : context.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(a.icon, size: 16, color: fg),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              a.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
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
    final maxLines = expanded ? null : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: context.bodyTwoStyle.copyWith(
            height: 1.35,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onToggle,
          child: Text(
            expanded ? 'Thu gọn' : 'Đọc thêm',
            style: context.captionStyle.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $e',
                style: context.bodyTwoStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

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

    // Aspects từ hotel_review_aspects
    final avgCleanliness = _toDouble(summary['avgCleanliness']) ?? 0.0;
    final avgService = _toDouble(summary['avgService']) ?? 0.0;
    final avgValueForMoney = _toDouble(summary['avgValueForMoney']) ?? 0.0;
    final avgLocation = _toDouble(summary['avgLocation']) ?? 0.0;
    final avgFacilities = _toDouble(summary['avgFacilities']) ?? 0.0;

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
            // Left: Overall rating (từ cột rating trong hotel_reviews)
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
            // Right: 5 Aspects từ hotel_review_aspects
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAspectRow(context, 'Độ sạch sẽ', avgCleanliness),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Dịch vụ', avgService),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Giá trị', avgValueForMoney),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Vị trí', avgLocation),
                  const SizedBox(height: 6),
                  _buildAspectRow(context, 'Tiện nghi', avgFacilities),
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
    return DetailHotelReviewUserScreen(
      hotelId: _resolvedId!,
      hotelName: data['title']?.toString() ?? 'Khách sạn',
      hotelLocation:
          data['address']?.toString() ?? data['location']?.toString() ?? '',
      hotelImage: _imageList(data).isNotEmpty
          ? _imageList(data).first
          : 'assets/images/onboarding1.png',
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
    final replyCount = _toInt(r['replyCount']) ?? 0;
    final likesCount = _toInt(r['likesCount']) ?? 0;
    final reviewId = _toInt(r['reviewId']) ?? 0;
    final isExpanded = _expandedReviews.contains(reviewId);

    debugPrint(
      '🔍 Flutter _reviewItem: reviewId=$reviewId, likesCount=$likesCount, replyCount=$replyCount',
    );

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
      padding: const EdgeInsets.only(bottom: 18),
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

          // Display review images
          if (imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrls[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: context.dividerColor,
                        child: Icon(
                          LucideIcons.image,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Likes and replies count
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$likesCount',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.comment_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '$replyCount phản hồi',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),

          // Load and display replies
          if (replyCount > 0 && reviewId > 0) ...[
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadReplies(reviewId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data!.map((reply) {
                    return _buildReplyItem(context, reply);
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadReplies(int reviewId) async {
    if (_repliesCache.containsKey(reviewId)) {
      return _repliesCache[reviewId]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final reviewApi = ReviewApiService(dio: dio, prefs: prefs);

      // Get current user ID
      final currentUserId = prefs.getInt('user_id');

      final replies = await reviewApi.getReviewReplies(
        reviewType: 'hotel',
        reviewId: reviewId,
        currentUserId: currentUserId,
      );

      // Sort replies DESC (newest first)
      replies.sort((a, b) {
        final aDate = a['createdAt'] as String? ?? '';
        final bDate = b['createdAt'] as String? ?? '';
        return bDate.compareTo(aDate);
      });

      debugPrint('📝 Loaded ${replies.length} replies for review $reviewId');
      _repliesCache[reviewId] = replies;
      return replies;
    } catch (e) {
      debugPrint('❌ Error loading replies: $e');
      return [];
    }
  }

  Widget _buildReplyItem(BuildContext context, Map<String, dynamic> reply) {
    final replierName = reply['replierName']?.toString() ?? 'Người trả lời';
    final content = reply['content']?.toString() ?? '';
    final isProvider = reply['isProvider'] == 1;
    final replyId = _toInt(reply['replyId']) ?? 0;
    final createdAt = reply['createdAt']?.toString() ?? '';
    final isExpanded = _expandedReplies.contains(replyId);

    // Format date
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = '';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isProvider ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isProvider ? Colors.green : Colors.grey[400]!,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isProvider ? Colors.green : Colors.grey[400],
                  child: Icon(
                    isProvider ? Icons.business : Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            replierName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isProvider
                                  ? Colors.green[800]
                                  : Colors.grey[800],
                            ),
                          ),
                          if (isProvider) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Nhà cung cấp',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13, height: 1.4),
              maxLines: isExpanded ? null : 4,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (content.length > 150) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedReplies.remove(replyId);
                    } else {
                      _expandedReplies.add(replyId);
                    }
                  });
                },
                child: Text(
                  isExpanded ? 'Thu gọn' : 'Hiển thị thêm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _locationBlock(BuildContext context, Map<String, dynamic> d) {
    final address = d['address']?.toString();
    final location = d['location']?.toString();
    final text = address?.isNotEmpty == true ? address! : (location ?? '');

    // Lấy latitude và longitude từ backend
    final latitude = d['latitude'];
    final longitude = d['longitude'];

    double? lat;
    double? lng;

    if (latitude != null && longitude != null) {
      if (latitude is num) lat = latitude.toDouble();
      if (longitude is num) lng = longitude.toDouble();
    }

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
                        markerId: const MarkerId('hotel_location'),
                        position: LatLng(lat, lng),
                        infoWindow: InfoWindow(
                          title: d['title']?.toString() ?? 'Khách sạn',
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
                    liteModeEnabled: true, // Chế độ lite giảm rendering
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

  // Reverse Geocoding với Nominatim OpenStreetMap
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
          // Trả về địa chỉ tiếng Việt từ Nominatim
          return displayName;
        }
      }
    } catch (e) {
      debugPrint('❌ Reverse geocode error: $e');
    }

    // Fallback: hiển thị tọa độ nếu API lỗi
    return '$lat, $lng';
  }

  // ===== Helpers =====
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

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  // primary image helper removed; using PageView gallery instead

  List<String> _imageList(Map<String, dynamic> d) {
    final List<String> images = [];

    // 1. Thêm thumbnail_url (ảnh chính)
    final thumbnail = d['thumbnail_url'] ?? d['thumbnailUrl'];
    if (thumbnail != null && thumbnail.toString().isNotEmpty) {
      images.add(thumbnail.toString());
    }

    // 2. Thêm image_urls (mảng ảnh phụ)
    final imageUrlsRaw = d['image_urls'] ?? d['imageUrls'];
    if (imageUrlsRaw is List) {
      for (final url in imageUrlsRaw) {
        final urlStr = url.toString();
        if (urlStr.isNotEmpty && !images.contains(urlStr)) {
          images.add(urlStr);
        }
      }
    } else if (imageUrlsRaw is String && imageUrlsRaw.isNotEmpty) {
      // Nếu là string phân tách bằng dấu phẩy
      final urls = imageUrlsRaw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (final url in urls) {
        if (!images.contains(url)) {
          images.add(url);
        }
      }
    }

    // 3. Fallback: nếu không có ảnh nào, thử lấy từ imageUrls (legacy)
    if (images.isEmpty) {
      final raw = d['imageUrls'];
      if (raw is List) {
        return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    }

    return images;
  }

  List<int> _listOfInt(dynamic v) {
    if (v is List) {
      return v
          .map((e) {
            if (e is int) return e;
            return int.tryParse(e.toString());
          })
          .where((e) => e != null)
          .cast<int>()
          .toList();
    }
    return const [];
  }

  List<String> _mapIdsToLabels(List<int> ids, Map<int, String> dict) {
    // Deduplicate while preserving order
    final seen = <int>{};
    final labels = <String>[];
    for (final id in ids) {
      if (seen.add(id)) {
        labels.add(dict[id] ?? 'ID: $id');
      }
    }
    return labels;
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    // Cheap formatter: take yyyy-mm-dd or yyyy-mm-ddTHH
    final parts = iso.split('T').first.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return iso;
  }

  String _formatDateShort(DateTime d) {
    // Example: 11 thg 6
    return '${d.day} thg ${d.month}';
  }

  String _dateRangeLabel() {
    if (_dateRange == null) {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      return '${_formatDateShort(now)} → ${_formatDateShort(tomorrow)}';
    }
    final s = _formatDateShort(_dateRange!.start);
    final e = _formatDateShort(_dateRange!.end);
    return '$s → $e';
  }

  String _guestRoomLabel() {
    return '$_rooms phòng · $_peopleCount khách';
  }

  Future<void> _openDateRangePicker() async {
    final now = DateTime.now();
    final initial =
        _dateRange ??
        DateTimeRange(start: now, end: now.add(const Duration(days: 1)));
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Chọn ngày',
      saveText: 'Xong',
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _openGuestRoomSelector() async {
    int rooms = _rooms;
    int people = _peopleCount;

    // Min/Max people from backend (supplier parity)
    final d = _data;
    final minPeople = _toInt(d['minParticipants']) ?? 1;
    final maxPeople = _toInt(d['maxParticipants']) ?? (minPeople + 8);

    // Lấy số phòng còn trống từ API (availableRooms = totalRooms - bookedRooms)
    int? availableRooms;
    final availableRaw = d['availableRooms'] ?? d['available_rooms'];
    if (availableRaw is int) {
      availableRooms = availableRaw;
    } else if (availableRaw != null) {
      availableRooms = int.tryParse(availableRaw.toString());
    }

    // Fallback về totalRooms nếu không có availableRooms
    if (availableRooms == null) {
      final totalRaw = d['totalRooms'] ?? d['total_rooms'];
      if (totalRaw is int) {
        availableRooms = totalRaw;
      } else if (totalRaw != null) {
        availableRooms = int.tryParse(totalRaw.toString());
      }
    }

    // Nếu vẫn null, fallback về capacity
    if (availableRooms == null) {
      final capRaw = d['capacity'];
      if (capRaw is num) {
        availableRooms = capRaw.toInt();
      } else if (capRaw != null) {
        availableRooms = int.tryParse(capRaw.toString());
      }
    }

    final maxRooms = availableRooms ?? 10; // Default 10 nếu không có giới hạn

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Widget row(
              String label,
              int value,
              VoidCallback onMinus,
              VoidCallback onPlus, {
              String? hint,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (hint != null)
                            Text(
                              hint,
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _qtyBtn(icon: LucideIcons.minus, onTap: onMinus),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$value',
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _qtyBtn(icon: LucideIcons.plus, onTap: onPlus),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Chọn phòng & số người',
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  row(
                    'Phòng',
                    rooms,
                    () {
                      if (rooms > 1) setLocal(() => rooms--);
                    },
                    () {
                      if (rooms < maxRooms) setLocal(() => rooms++);
                    },
                    hint: availableRooms != null
                        ? 'Còn $availableRooms phòng trống'
                        : null,
                  ),
                  row(
                    'Số người',
                    people,
                    () {
                      if (people > minPeople) setLocal(() => people--);
                    },
                    () {
                      if (people < maxPeople) setLocal(() => people++);
                    },
                    hint: 'Tối thiểu $minPeople · Tối đa $maxPeople',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF23A455),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _rooms = rooms;
                          _peopleCount = people.clamp(minPeople, maxPeople);
                        });
                      },
                      child: const Text(
                        'Xong',
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

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 16),
      ),
    );
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
      // Format with dot thousand separators for Vietnamese currency
      final s = n.toStringAsFixed(0);
      final rev = s.split('').reversed.toList();
      final parts = <String>[];
      for (int i = 0; i < rev.length; i++) {
        if (i > 0 && i % 3 == 0) parts.add('.');
        parts.add(rev[i]);
      }
      final grouped = parts.reversed.join();
      return '$grouped đ';
    }
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }

  // NEW: unified image fallback (used for hero image load errors)
  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  Widget _starsRow(BuildContext context, double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            LucideIcons.star,
            size: 14,
            color: filled ? const Color(0xFF23A455) : context.dividerColor,
          ),
        );
      }),
    );
  }

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
    // Debug: Print hotel data to see what we have
    // debugPrint('=== Hotel Data ===');
    // debugPrint('hotelId: ${_resolvedId}');
    // debugPrint('providerId: ${data['providerId']}');
    // debugPrint('title: ${data['title']}');
    // debugPrint('location: ${data['location']}');
    // debugPrint('==================');

    if (action == 'Gọi') {
      // Get provider contact phone from providerId
      final providerId = data['providerId'];
      if (providerId == null) {
        _showError('Không tìm thấy thông tin nhà cung cấp');
        return;
      }

      final phone = await _getProviderPhone(providerId);
      if (phone != null && phone.isNotEmpty) {
        final uri = Uri.parse('tel:$phone');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Error launching dialer: $e');
          _showError('Không thể mở ứng dụng gọi điện');
        }
      } else {
        _showError('Không tìm thấy số điện thoại');
      }
    } else if (action == 'Viết đánh giá') {
      // Navigate to review screen
      if (_resolvedId == null) {
        _showError('Không tìm thấy ID khách sạn');
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailHotelReviewUserScreen(
            hotelId: _resolvedId!,
            hotelName: data['title']?.toString() ?? '',
            hotelLocation: data['location']?.toString() ?? '',
            hotelImage: _imageList(data).isNotEmpty
                ? _imageList(data).first
                : '',
          ),
        ),
      );

      // Refresh if review was submitted
      if (result == true) {
        _fetchDetail();
      }
    } else if (action == 'Email') {
      // Get provider contact email from providerId
      final providerId = data['providerId'];
      if (providerId == null) {
        _showError('Không tìm thấy thông tin nhà cung cấp');
        return;
      }

      final email = await _getProviderEmail(providerId);
      if (email != null && email.isNotEmpty) {
        final uri = Uri.parse('mailto:$email');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Error launching email: $e');
          _showError('Không thể mở ứng dụng email');
        }
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
        '${AppConfig.baseUrl}/providers/${providerId.toString()}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (prefs.getString('user_token') != null)
              'Authorization': 'Bearer ${prefs.getString('user_token')}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final phone = response.data['contactPhone']?.toString();
        debugPrint('Provider phone: $phone');
        return phone;
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
        '${AppConfig.baseUrl}/providers/${providerId.toString()}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (prefs.getString('user_token') != null)
              'Authorization': 'Bearer ${prefs.getString('user_token')}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final email = response.data['contactEmail']?.toString();
        debugPrint('Provider email: $email');
        return email;
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

  Widget _outlinedChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: context.textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MODEL =====
class _Amenity {
  final String name;
  final IconData icon;
  const _Amenity(this.name, this.icon);
}
