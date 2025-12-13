import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/search_history_service.dart';
import 'package:app/services/hotel_api_service.dart';
import 'package:app/services/restaurant_api_service.dart';
import 'package:app/services/tour_api_service.dart';
import 'package:app/services/attraction_api_service.dart';

// Detail screens
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  List<Map<String, dynamic>> _historyItems = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);

      final viewedItems = await historyService.getRecentViewedItems(limit: 100);

      // Convert API response to UI format and fetch latest ratings
      final List<Map<String, dynamic>> items = [];
      for (final item in viewedItems) {
        // Fetch latest rating from API
        dynamic latestRating = item['itemRating'];
        try {
          latestRating = await _fetchLatestRating(
            prefs,
            item['itemType'],
            item['itemId'],
          );
        } catch (e) {
          // Keep old rating if fetch fails
          debugPrint(
            'Failed to fetch rating for ${item['itemType']} ${item['itemId']}: $e',
          );
        }

        items.add({
          'itemType': item['itemType'],
          'itemId': item['itemId'],
          'itemTitle': item['itemTitle'],
          'itemLocation': item['itemLocation'],
          'itemThumbnailUrl': item['itemThumbnailUrl'],
          'itemPrice': item['itemPrice'],
          'itemCurrencyCode': item['itemCurrencyCode'],
          'itemRating': latestRating,
          'clickTimestamp': item['clickTimestamp'],
          // For compatibility
          'name': item['itemTitle'],
          'location': item['itemLocation'],
          'rating': latestRating,
          'price': _formatPrice(item['itemPrice'], item['itemCurrencyCode']),
          'type': item['itemType'],
          'image': item['itemThumbnailUrl'],
          'imageUrl': item['itemThumbnailUrl'],
        });
      }

      setState(() {
        _historyItems = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<dynamic> _fetchLatestRating(
    SharedPreferences prefs,
    String itemType,
    int itemId,
  ) async {
    try {
      final dio = Dio();
      switch (itemType.toLowerCase()) {
        case 'hotel':
          final hotelApi = HotelApiService(dio: dio, prefs: prefs);
          final hotel = await hotelApi.getHotelById(itemId);
          return hotel['ratingAverage'] ?? hotel['rating'] ?? 0.0;
        case 'restaurant':
          final restaurantApi = RestaurantApiService(dio: dio, prefs: prefs);
          final restaurant = await restaurantApi.getRestaurantById(itemId);
          return restaurant['ratingAverage'] ?? restaurant['rating'] ?? 0.0;
        case 'tour':
          final tourApi = TourApiService(dio: dio, prefs: prefs);
          final tour = await tourApi.getTourById(itemId);
          return tour['ratingAverage'] ?? tour['rating'] ?? 0.0;
        case 'attraction':
          final attractionApi = AttractionApiService(dio: dio, prefs: prefs);
          final attraction = await attractionApi.getAttractionById(itemId);
          return attraction['ratingAverage'] ?? attraction['rating'] ?? 0.0;
        default:
          return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }

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

  String _getRatingString(dynamic rating) {
    if (rating == null) return '0.0';
    if (rating is num) return rating.toStringAsFixed(1);
    final parsed = double.tryParse(rating.toString());
    return parsed?.toStringAsFixed(1) ?? '0.0';
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} phút trước';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} giờ trước';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text(
          'Bạn có chắc muốn xóa toàn bộ lịch sử xem? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);
        await historyService.clearSearchHistory();

        setState(() {
          _historyItems = [];
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa lịch sử')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi xóa lịch sử: $e')));
        }
      }
    }
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    final type = item['itemType']?.toString() ?? item['type']?.toString();

    switch (type) {
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
    }
  }

  void _openHotelDetail(Map<String, dynamic> item) {
    final id = _parseId(item, ['itemId', 'hotelId', 'id']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id,
          hotel: {
            'name': item['name']?.toString() ?? '',
            'image':
                item['imageUrl']?.toString() ?? 'assets/images/onboarding2.png',
            'price': item['price']?.toString() ?? '—',
          },
          activeAmenities: const {'Wifi miễn phí'},
        ),
      ),
    );
  }

  void _openRestaurantDetail(Map<String, dynamic> item) {
    final id = _parseId(item, ['itemId', 'restaurantId', 'id']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          restaurantId: id,
          restaurant: {
            'name': item['name']?.toString() ?? '',
            'location': item['location']?.toString() ?? '',
            'rating': _getRatingString(item['rating']),
            'type': 'restaurant',
            'cuisine': '',
            'price': item['price']?.toString() ?? '',
            'reviews': '',
            'tag': '',
            'image':
                item['imageUrl']?.toString() ?? 'assets/images/onboarding4.png',
          },
          activeCuisines: const {},
          activeServices: const {},
          activeDietaries: const {},
          activeStars: const {},
          activeOpenNow: false,
          activeReservation: false,
          activeTakeAway: false,
        ),
      ),
    );
  }

  void _openTourDetail(Map<String, dynamic> item) {
    final id = _parseId(item, ['itemId', 'tourId', 'id']);
    final tourData = {
      'name': item['name']?.toString() ?? '',
      'location': item['location']?.toString() ?? '',
      'rating': _getRatingString(item['rating']),
      'price': item['price']?.toString() ?? '',
      'image': item['imageUrl']?.toString() ?? 'assets/images/onboarding1.png',
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

  void _openAttractionDetail(Map<String, dynamic> item) {
    final id = _parseId(item, ['itemId', 'attractionId', 'id']);
    final attractionData = {
      'name': item['name']?.toString() ?? '',
      'location': item['location']?.toString() ?? '',
      'rating': double.tryParse(_getRatingString(item['rating'])) ?? 0.0,
      'price': 0,
      'description': '',
      'image': item['imageUrl']?.toString() ?? 'assets/images/onboarding3.png',
      'types': [],
      'services': [],
      'times': [],
      'suit': [],
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

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return LucideIcons.building;
      case 'restaurant':
        return LucideIcons.utensils;
      case 'tour':
        return LucideIcons.bus;
      case 'attraction':
        return LucideIcons.ticket;
      default:
        return LucideIcons.mapPin;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return 'Khách sạn';
      case 'restaurant':
        return 'Nhà hàng';
      case 'tour':
        return 'Tour';
      case 'attraction':
        return 'Điểm tham quan';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
        ),
        title: Text(
          'Đã xem gần đây',
          style: context.h5Style.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: Icon(LucideIcons.trash2, color: Colors.red),
              tooltip: 'Xóa lịch sử',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.alertCircle,
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
                onPressed: _loadHistory,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 64,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử xem',
              style: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các địa điểm bạn xem sẽ hiển thị ở đây',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _historyItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildHistoryItem(index),
    );
  }

  Widget _buildHistoryItem(int index) {
    final item = _historyItems[index];
    final imageUrl = (item['imageUrl'] ?? '').toString();
    final hasNetwork = imageUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item),
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
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : Image.asset(
                        'assets/images/onboarding${(index % 4) + 1}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForType(item['itemType']?.toString() ?? ''),
                          size: 14,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeLabel(item['itemType']?.toString() ?? ''),
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['name']?.toString() ?? '',
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
                        Expanded(
                          child: Text(
                            item['location']?.toString() ?? '',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.star,
                          size: 12,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRatingString(item['rating']),
                          style: context.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(item['clickTimestamp']?.toString()),
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
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

  Widget _imageFallback() {
    return Container(
      width: 60,
      height: 60,
      color: context.primaryColor.withValues(alpha: 0.1),
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }
}
