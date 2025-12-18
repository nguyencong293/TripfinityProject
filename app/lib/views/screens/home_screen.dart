import 'package:app/routes/app_router.dart';
import 'package:app/services/area_api_service.dart';
import 'package:app/services/search_api_service.dart';
import 'package:app/services/notification_api_service.dart';
import 'package:app/services/favorite_api_service.dart';
import 'package:app/services/recommendation_service.dart';
import 'package:app/services/search_history_service.dart';
import 'package:app/views/screens/attractions_overview_search_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/general_search_screen.dart';
import 'package:app/views/screens/search_overview_screen.dart';
import 'package:app/views/screens/hotel_overview_search_screen.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_search_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_overview_search_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/trip_user_screen.dart';
import 'package:app/views/screens/trip_review_user_screen.dart';
import 'package:app/views/widgets/article_banner_card.dart';
import 'package:app/views/widgets/bottom_nav.dart';
import 'package:app/views/widgets/home_service_item.dart';
import 'package:app/views/widgets/recent_item_tile.dart';
import 'package:app/views/widgets/section_header.dart';
import 'package:app/views/widgets/area_preview_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

// + theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import 'dashboard_user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  String? _initialSearchQuery;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    DateTime? lastBackPressed;

    // Simple placeholder pages per tab (localized)
    final pages = [
      _HomeContent(
        user: user,
        onSubmitSearch: (q) {
          final query = q.trim();
          if (query.isEmpty) return;
          setState(() {
            _initialSearchQuery = query; // pass query to search screen
            _tabIndex = 1; // switch to Search tab
          });
        },
      ),
      GeneralSearchScreen(
        key: ValueKey(
          _initialSearchQuery ?? 'search',
        ), // Rebuild when query changes
        initialQuery: _initialSearchQuery,
      ),
      const TripUserScreen(),
      const TripReviewUserScreen(),
      const DashboardUserScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2)) {
          lastBackPressed = now;
          Fluttertoast.showToast(msg: "press_back_again_to_exit".tr);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        drawer: _AppDrawer(
          onNavigateToServices: () {
            setState(() {
              _initialSearchQuery = null; // Reset search state
              _tabIndex = 1; // Chuyển về tab Search
            });
          },
        ),
        body: pages[_tabIndex],
        bottomNavigationBar: BottomNav(
          currentIndex: _tabIndex,
          onTap: (i) {
            setState(() {
              // Reset search query when leaving search tab
              if (i != 1 && _tabIndex == 1) {
                _initialSearchQuery = null;
              }
              _tabIndex = i;
            });
          },
        ),
      ),
    );
  }
}

// Dữ liệu danh mục: dùng key i18n thay vì label cứng
class _Category {
  final IconData icon;
  final String labelKey;
  const _Category(this.icon, this.labelKey);
}

// Redesigned home content to match the provided UI
class _HomeContent extends StatefulWidget {
  final dynamic user;
  final ValueChanged<String> onSubmitSearch;
  const _HomeContent({required this.user, required this.onSubmitSearch});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  Set<int> _favoriteHotelIds = {};
  Set<int> _favoriteRestaurantIds = {};
  Set<int> _favoriteAttractionIds = {};
  Set<int> _favoriteTourIds = {};

  // Cache futures to avoid reloading on every rebuild
  late final Future<List<HomeServiceItem>> _hotelsFuture;
  late final Future<List<HomeServiceItem>> _toursFuture;
  late final Future<List<HomeServiceItem>> _attractionsFuture;
  late final Future<List<HomeServiceItem>> _restaurantsFuture;
  late final Future<List<AreaPreviewItem>> _areasFuture;
  late final Future<List<HomeServiceItem>> _recommendationsFuture;
  late final Future<List<Map<String, dynamic>>> _recentViewedFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    // Initialize all futures once
    _hotelsFuture = _loadHomeHotels();
    _toursFuture = _loadHomeTours();
    _attractionsFuture = _loadHomeAttractions();
    _restaurantsFuture = _loadHomeRestaurants();
    _areasFuture = _loadHomeAreas();
    _recommendationsFuture = _loadRecommendations();
    _recentViewedFuture = _loadRecentViewed();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        return;
      }

      final dio = Dio();
      final favoriteApi = FavoriteApiService(dio: dio, prefs: prefs);

      // Load all favorite IDs in parallel
      final results = await Future.wait([
        favoriteApi.getFavoriteServiceIds(userId: userId, serviceType: 'hotel'),
        favoriteApi.getFavoriteServiceIds(
          userId: userId,
          serviceType: 'restaurant',
        ),
        favoriteApi.getFavoriteServiceIds(
          userId: userId,
          serviceType: 'attraction',
        ),
        favoriteApi.getFavoriteServiceIds(userId: userId, serviceType: 'tour'),
      ]);

      setState(() {
        _favoriteHotelIds = results[0].toSet();
        _favoriteRestaurantIds = results[1].toSet();
        _favoriteAttractionIds = results[2].toSet();
        _favoriteTourIds = results[3].toSet();
      });

      debugPrint(
        '✅ Loaded favorites: hotels=${_favoriteHotelIds.length}, restaurants=${_favoriteRestaurantIds.length}, attractions=${_favoriteAttractionIds.length}, tours=${_favoriteTourIds.length}',
      );
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
    }
  }

  Future<List<HomeServiceItem>> _loadHomeRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final api = SearchApiService(dio: Dio(), prefs: prefs);
    final data = await api.search(q: '', type: 'restaurant');

    final list = (data['restaurants'] is List)
        ? List.from(data['restaurants'])
        : const [];

    final items = <HomeServiceItem>[];
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);

      final title = (m['title'] ?? m['name'] ?? '').toString();
      if (title.isEmpty) continue;

      final ratingAny =
          m['ratingAverage'] ??
          m['rating'] ??
          m['ratingAvg'] ??
          m['avg_rating'];
      final rating = (ratingAny is num)
          ? ratingAny.toDouble()
          : (double.tryParse(ratingAny?.toString() ?? '') ?? 0.0);

      final imageUrl =
          (m['thumbnailUrl'] ?? m['imageUrl'] ?? m['image'])?.toString() ?? '';

      final priceText = _formatPrice(m['price'], m['currencyCode']?.toString());
      final serviceId = (m['restaurantId'] ?? m['id'] ?? 0) as int;

      items.add(
        HomeServiceItem(
          title: title,
          rating: rating,
          imageUrl: imageUrl,
          price: priceText,
          serviceType: 'restaurant',
          serviceId: serviceId,
          isFavorite: _favoriteRestaurantIds.contains(serviceId),
        ),
      );
    }

    items.shuffle();
    return items.length > 10 ? items.sublist(0, 10) : items;
  }

  Future<List<HomeServiceItem>> _loadHomeHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final api = SearchApiService(dio: Dio(), prefs: prefs);
    final data = await api.search(q: '', type: 'hotel');

    final list = (data['hotels'] is List)
        ? List.from(data['hotels'])
        : const [];
    final items = <HomeServiceItem>[];

    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);

      final title = (m['title'] ?? m['name'] ?? '').toString();
      if (title.isEmpty) continue;

      final ratingAny =
          m['ratingAverage'] ??
          m['rating'] ??
          m['ratingAvg'] ??
          m['avg_rating'];
      final rating = (ratingAny is num)
          ? ratingAny.toDouble()
          : (double.tryParse(ratingAny?.toString() ?? '') ?? 0.0);

      final imageUrl =
          (m['thumbnailUrl'] ?? m['imageUrl'] ?? m['image'])?.toString() ?? '';

      final priceText = _formatPrice(m['price'], m['currencyCode']?.toString());
      final serviceId = (m['hotelId'] ?? m['id'] ?? 0) as int;

      items.add(
        HomeServiceItem(
          title: title,
          rating: rating,
          imageUrl: imageUrl,
          price: priceText,
          serviceType: 'hotel',
          serviceId: serviceId,
          isFavorite: _favoriteHotelIds.contains(serviceId),
        ),
      );
    }

    items.shuffle();
    return items.length > 10 ? items.sublist(0, 10) : items;
  }

  Future<List<HomeServiceItem>> _loadHomeTours() async {
    final prefs = await SharedPreferences.getInstance();
    final api = SearchApiService(dio: Dio(), prefs: prefs);
    final data = await api.search(q: '', type: 'tour');

    final list = (data['tours'] is List) ? List.from(data['tours']) : const [];
    final items = <HomeServiceItem>[];

    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);

      final title = (m['title'] ?? m['name'] ?? '').toString();
      if (title.isEmpty) continue;

      final ratingAny =
          m['ratingAverage'] ??
          m['rating'] ??
          m['ratingAvg'] ??
          m['avg_rating'];
      final rating = (ratingAny is num)
          ? ratingAny.toDouble()
          : (double.tryParse(ratingAny?.toString() ?? '') ?? 0.0);

      final imageUrl =
          (m['thumbnailUrl'] ?? m['imageUrl'] ?? m['image'])?.toString() ?? '';

      final priceText = _formatPrice(m['price'], m['currencyCode']?.toString());
      final serviceId = (m['tourId'] ?? m['id'] ?? 0) as int;

      items.add(
        HomeServiceItem(
          title: title,
          rating: rating,
          imageUrl: imageUrl,
          price: priceText,
          serviceType: 'tour',
          serviceId: serviceId,
          isFavorite: _favoriteTourIds.contains(serviceId),
        ),
      );
    }

    items.shuffle();
    return items.length > 10 ? items.sublist(0, 10) : items;
  }

  Future<List<HomeServiceItem>> _loadHomeAttractions() async {
    final prefs = await SharedPreferences.getInstance();
    final api = SearchApiService(dio: Dio(), prefs: prefs);
    final data = await api.search(q: '', type: 'attraction');

    final list = (data['attractions'] is List)
        ? List.from(data['attractions'])
        : const [];
    final items = <HomeServiceItem>[];

    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);

      final title = (m['title'] ?? m['name'] ?? '').toString();
      if (title.isEmpty) continue;

      final ratingAny =
          m['ratingAverage'] ??
          m['rating'] ??
          m['ratingAvg'] ??
          m['avg_rating'];
      final rating = (ratingAny is num)
          ? ratingAny.toDouble()
          : (double.tryParse(ratingAny?.toString() ?? '') ?? 0.0);

      final imageUrl =
          (m['thumbnailUrl'] ?? m['imageUrl'] ?? m['image'])?.toString() ?? '';

      // At attractions, price may be missing; empty string is fine for UI
      final priceText = _formatPrice(m['price'], m['currencyCode']?.toString());
      final serviceId = (m['attractionId'] ?? m['id'] ?? 0) as int;

      items.add(
        HomeServiceItem(
          title: title,
          rating: rating,
          imageUrl: imageUrl,
          price: priceText,
          serviceType: 'attraction',
          serviceId: serviceId,
          isFavorite: _favoriteAttractionIds.contains(serviceId),
        ),
      );
    }

    items.shuffle();
    return items.length > 10 ? items.sublist(0, 10) : items;
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

  Future<List<AreaPreviewItem>> _loadHomeAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final api = AreaApiService(dio: Dio(), prefs: prefs);

    final List<Map<String, dynamic>> list = await api.getAll();
    final items = <AreaPreviewItem>[];

    for (final e in list) {
      final m = Map<String, dynamic>.from(e);

      final name = (m['name'] ?? '').toString();
      if (name.isEmpty) continue;

      final imageUrl =
          (m['coverImageUrl'] ?? m['imageUrl'] ?? m['bannerUrl'])?.toString() ??
          '';

      final shortDesc = m['shortDescription']?.toString();
      final type = (m['areaType']?.toString() ?? '').toLowerCase();
      String country;
      if (shortDesc != null && shortDesc.trim().isNotEmpty) {
        country = shortDesc.trim();
      } else if (type == 'province') {
        country = 'Tỉnh, Việt Nam';
      } else if (type == 'city') {
        country = 'Thành phố, Việt Nam';
      } else if (type == 'district') {
        country = 'Quận/Huyện, Việt Nam';
      } else {
        country = 'Việt Nam';
      }

      items.add(
        AreaPreviewItem(name: name, country: country, imageUrl: imageUrl),
      );
    }

    items.shuffle();
    return items.length > 5 ? items.sublist(0, 5) : items;
  }

  Future<List<Map<String, dynamic>>> _loadRecentViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);
      final viewedItems = await historyService.getRecentViewedItems(limit: 5);

      // Convert to format expected by UI
      final List<Map<String, dynamic>> items = [];
      for (final item in viewedItems) {
        items.add({
          'itemType': item['itemType'],
          'itemId': item['itemId'],
          'itemTitle': item['itemTitle'],
          'itemLocation': item['itemLocation'],
          'itemThumbnailUrl': item['itemThumbnailUrl'],
          'itemPrice': item['itemPrice'],
          'itemCurrencyCode': item['itemCurrencyCode'],
          'itemRating': item['itemRating'],
        });
      }

      return items;
    } catch (e) {
      debugPrint('❌ Error loading recent viewed: $e');
      return [];
    }
  }

  Future<List<HomeServiceItem>> _loadRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        debugPrint('⚠️ Cannot load recommendations: user_id not found');
        return [];
      }

      final dio = Dio();
      final recommendationService = RecommendationService(dio: dio);
      final response = await recommendationService.getRecommendations(userId);

      if (!response.success || response.data == null) {
        debugPrint('⚠️ No recommendations available');
        return [];
      }

      debugPrint('🔍 Processing ${response.data!.length} recommendations');

      // Load all service data in parallel for better performance
      final searchApi = SearchApiService(dio: dio, prefs: prefs);
      final futures = <Future<Map<String, dynamic>>>[];
      final serviceTypes = <String>{
        'hotel',
        'restaurant',
        'attraction',
        'tour',
      };

      for (final type in serviceTypes) {
        futures.add(searchApi.search(q: '', type: type));
      }

      final searchResults = await Future.wait(futures);
      final serviceDataCache = <String, List<Map<String, dynamic>>>{};

      // Build cache
      int idx = 0;
      for (final type in serviceTypes) {
        final result = searchResults[idx];
        List? serviceList;

        if (type == 'hotel') {
          serviceList = result['hotels'] as List?;
        } else if (type == 'restaurant') {
          serviceList = result['restaurants'] as List?;
        } else if (type == 'attraction') {
          serviceList = result['attractions'] as List?;
        } else if (type == 'tour') {
          serviceList = result['tours'] as List?;
        }

        if (serviceList != null) {
          serviceDataCache[type] = serviceList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          debugPrint('📦 Cached ${serviceList.length} $type items');
        }
        idx++;
      }

      final items = <HomeServiceItem>[];

      for (final item in response.data!) {
        final serviceType = item.itemType.toLowerCase();
        final serviceId = item.itemId;

        debugPrint('🔎 Looking for $serviceType #$serviceId: ${item.title}');

        // Determine if this item is favorited
        bool isFavorite = false;
        if (serviceType == 'hotel') {
          isFavorite = _favoriteHotelIds.contains(serviceId);
        } else if (serviceType == 'restaurant') {
          isFavorite = _favoriteRestaurantIds.contains(serviceId);
        } else if (serviceType == 'attraction') {
          isFavorite = _favoriteAttractionIds.contains(serviceId);
        } else if (serviceType == 'tour') {
          isFavorite = _favoriteTourIds.contains(serviceId);
        }

        // Find item in cache
        final serviceList = serviceDataCache[serviceType];
        if (serviceList == null) {
          debugPrint('⚠️ No cache for service type: $serviceType');
          continue;
        }

        String idKey = '';
        if (serviceType == 'hotel') {
          idKey = 'hotelId';
        } else if (serviceType == 'restaurant') {
          idKey = 'restaurantId';
        } else if (serviceType == 'attraction') {
          idKey = 'attractionId';
        } else if (serviceType == 'tour') {
          idKey = 'tourId';
        }

        debugPrint(
          '   Searching with key: $idKey in ${serviceList.length} items',
        );

        final matchedItem = serviceList.firstWhere((m) {
          final foundId = m[idKey] ?? m['id'] ?? 0;
          return foundId == serviceId;
        }, orElse: () => <String, dynamic>{});

        if (matchedItem.isEmpty) {
          debugPrint('   ❌ Not found in search results');
          // Fallback: use basic info from recommendation
          items.add(
            HomeServiceItem(
              title: item.title,
              rating: 0.0,
              imageUrl: '',
              price: item.priceFmt,
              serviceType: serviceType,
              serviceId: serviceId,
              isFavorite: isFavorite,
            ),
          );
          debugPrint('   ✅ Added with fallback data');
        } else {
          debugPrint('   ✅ Found match!');
          final ratingAny =
              matchedItem['ratingAverage'] ??
              matchedItem['rating'] ??
              matchedItem['ratingAvg'] ??
              matchedItem['avg_rating'];
          final rating = (ratingAny is num)
              ? ratingAny.toDouble()
              : (double.tryParse(ratingAny?.toString() ?? '') ?? 0.0);

          final imageUrl =
              (matchedItem['thumbnailUrl'] ??
                      matchedItem['imageUrl'] ??
                      matchedItem['image'])
                  ?.toString() ??
              '';

          items.add(
            HomeServiceItem(
              title: item.title,
              rating: rating,
              imageUrl: imageUrl,
              price: item.priceFmt,
              serviceType: serviceType,
              serviceId: serviceId,
              isFavorite: isFavorite,
            ),
          );
          debugPrint('   ✅ Added with full data');
        }
      }

      debugPrint('✅ Loaded ${items.length} recommendation items');
      return items;
    } catch (e) {
      debugPrint('❌ Error loading recommendations: $e');
      return [];
    }
  }

  void _navigateToDetail(
    BuildContext context,
    String serviceType,
    int serviceId,
  ) {
    switch (serviceType.toLowerCase()) {
      case 'hotel':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HotelDetailOverviewScreen(hotelId: serviceId),
          ),
        );
        break;
      case 'restaurant':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurantId: serviceId),
          ),
        );
        break;
      case 'attraction':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                AttractionsOverviewDetailScreen(attractionId: serviceId),
          ),
        );
        break;
      case 'tour':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourServiceDetailScreen(tourId: serviceId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = const <_Category>[
      _Category(LucideIcons.hotel, 'cat_hotels'),
      _Category(LucideIcons.bus, 'cat_tour'),
      _Category(LucideIcons.utensils, 'cat_food'),
      _Category(LucideIcons.ticket, 'cat_attraction'),
      _Category(LucideIcons.partyPopper, 'cat_entertainment'),
      _Category(LucideIcons.map, 'cat_itinerary'),
      _Category(LucideIcons.tag, 'cat_deals'),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo + actions
            Row(
              children: [
                Image.asset(
                  'assets/images/logotripfinity.png',
                  height: 32,
                  color: context.textPrimaryColor,
                ),
                const Spacer(),
                _NotificationBellIcon(user: widget.user),
                IconButton(
                  icon: Icon(LucideIcons.menu, color: context.textPrimaryColor),
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: context.textPrimaryColor,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction:
                  TextInputAction.search, // show search action on keyboard
              onSubmitted: (value) =>
                  widget.onSubmitSearch(value), // trigger navigation + query
              onTap: () {}, // keep existing if you want tap behavior
            ),
            const SizedBox(height: 20),
            // Optional greeting (uses user if available)
            if (widget.user != null) ...[
              Text(
                '${'hello'.tr}, ${widget.user.fullName} 👋',
                style: context.subTitleTwoStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Categories grid (square cells, 4 per row)
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: categories.map((c) {
                return _CategoryItem(
                  icon: c.icon,
                  label: c.labelKey.tr,
                  surface: context.cardBackgroundColor,
                  onSurface: context.textSecondaryColor,

                  onTap: () {
                    switch (c.labelKey) {
                      case 'cat_hotels':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HotelOverviewSearchScreen(
                              searchQuery: '',
                            ),
                          ),
                        );
                        break;
                      case 'cat_attraction':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AttractionOverviewSearchScreen(
                                  searchQuery: '',
                                ),
                          ),
                        );
                        break;
                      case 'cat_food':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const RestaurantOverviewSearchScreen(
                                  searchQuery: '',
                                ),
                          ),
                        );
                        break;
                      case 'cat_tour':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TourServiceOverviewScreen(
                              searchQuery: '',
                            ),
                          ),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Recommendations for you - prioritized to show first
            FutureBuilder<List<HomeServiceItem>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                // Show loading indicator while waiting
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      SectionHeader(title: 'Gợi ý dành cho bạn'),
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 30),
                    ],
                  );
                }

                // Don't show if error or no data
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Show section with data
                return Column(
                  children: [
                    HomeHorizontalSection(
                      title: 'Gợi ý dành cho bạn',
                      pageStorageKey: 'recommendations',
                      futureItems: Future.value(snapshot.data!),
                    ),
                    const SizedBox(height: 30),
                  ],
                );
              },
            ),

            // Recently viewed
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _recentViewedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'recently_viewed'.tr),
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'recently_viewed'.tr),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: RecentItemTile.kHeight,
                      child: ListView.separated(
                        key: const PageStorageKey('recently_viewed'),
                        primary: false,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final rating = (item['itemRating'] is num)
                              ? (item['itemRating'] as num).toDouble()
                              : (double.tryParse(
                                      item['itemRating']?.toString() ?? '',
                                    ) ??
                                    0.0);

                          return RecentItemTile(
                            leftImageUrl:
                                item['itemThumbnailUrl']?.toString() ?? '',
                            title: item['itemTitle']?.toString() ?? '',
                            subtitle: item['itemLocation']?.toString() ?? '',
                            rating: rating,
                            onTap: () => _navigateToDetail(
                              context,
                              item['itemType']?.toString() ?? '',
                              item['itemId'] ?? 0,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: items.length,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // Weekend cities
            SectionHeader(title: 'weekend_ideas'.tr),
            const SizedBox(height: 8),
            SizedBox(
              height: AreaPreviewCard.kHeight,
              child: FutureBuilder<List<AreaPreviewItem>>(
                future: _areasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Không thể tải khu vực',
                        style: context.captionStyle.copyWith(
                          color: context.errorColor,
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data ?? const <AreaPreviewItem>[];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có khu vực',
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchOverviewScreen(searchQuery: it.name),
                            ),
                          );
                        },
                        child: AreaPreviewCard(
                          imageUrl: it.imageUrl,
                          city: it.name,
                          country: it.country,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: items.length,
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Interesting articles banner
            SectionHeader(title: 'discover_interesting_posts'.tr),
            const SizedBox(height: 8),
            ArticleBannerCard(
              imageAsset: 'assets/images/onboarding4.png',
              title: 'Top 8 cây cầu Đà Nẵng',
              ctaLabel: 'explore_now'.tr,
            ),

            const SizedBox(height: 24),

            HomeHorizontalSection(
              title: 'nearby_hotels'.tr,
              pageStorageKey: 'hotels',
              futureItems: _hotelsFuture,
              onSeeMore: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const HotelOverviewSearchScreen(searchQuery: ''),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            HomeHorizontalSection(
              title: 'nearby_tours'.tr,
              pageStorageKey: 'tours',
              futureItems: _toursFuture,
              onSeeMore: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const TourServiceOverviewScreen(searchQuery: ''),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            HomeHorizontalSection(
              title: 'nearby_attractions'.tr,
              pageStorageKey: 'attractions',
              futureItems: _attractionsFuture,
              onSeeMore: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const AttractionOverviewSearchScreen(searchQuery: ''),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Nearby restaurants (reuse ExperienceCard)
            HomeHorizontalSection(
              title: 'nearby_restaurants'.tr,
              pageStorageKey: 'restaurants',
              futureItems: _restaurantsFuture,
              onSeeMore: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const RestaurantOverviewSearchScreen(searchQuery: ''),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surface;
  final Color onSurface;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.surface,
    required this.onSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.captionStyle.copyWith(
      color: onSurface,
      height: 1.15,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          // slightly tighter padding to avoid rounding overflows
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: context.textPrimaryColor),
              const SizedBox(height: 6),
              // Flexible text area prevents RenderFlex overflow in square tiles
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Left drawer menu
class _AppDrawer extends StatelessWidget {
  final VoidCallback onNavigateToServices;
  const _AppDrawer({required this.onNavigateToServices});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simple brand mark with logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logotripfinity.png',
                    height: 40,
                    color: context.textPrimaryColor,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerTile(
              title: 'drawer_home'.tr,
              icon: LucideIcons.home,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerTile(
              title: 'drawer_services'.tr,
              icon: LucideIcons.briefcase,
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                onNavigateToServices(); // Gọi callback để chuyển tab
              },
            ),
            _DrawerTile(
              title: 'drawer_contact'.tr,
              icon: LucideIcons.phone,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.contactUser),
              },
            ),
            _DrawerTile(
              title: 'drawer_posts'.tr,
              icon: LucideIcons.newspaper,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.postsList),
              },
            ),
            _DrawerTile(
              title: 'drawer_about'.tr,
              icon: LucideIcons.info,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.aboutTripfinity),
              },
            ),
            _DrawerTile(
              title: 'drawer_terms_policies'.tr,
              icon: LucideIcons.shield,
              onTap: () => {
                Navigator.pop(context),
                context.push(AppRouter.termsPolicies),
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: context.textPrimaryColor),
      title: Text(title, style: context.bodyOneStyle),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: context.textPrimaryColor,
      ),
      onTap: onTap,
    );
  }
}

/// Bell icon với badge hiển thị số thông báo chưa đọc
class _NotificationBellIcon extends StatefulWidget {
  final dynamic user;
  const _NotificationBellIcon({required this.user});

  @override
  State<_NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<_NotificationBellIcon> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    // Auto refresh every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) _loadUnreadCount();
    });
  }

  Future<void> _loadUnreadCount() async {
    if (widget.user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final service = NotificationApiService(dio: dio, prefs: prefs);

      // Lấy userId từ UserDTO
      final userId = widget.user.userId;
      if (userId == null) return;

      final count = await service.getUnreadCount(userId);
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (e) {
      // Không hiển thị lỗi, giữ badge = 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.notifications);
        // Reset badge sau khi vào trang notification
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadUnreadCount();
        });
      },
      child: Stack(
        children: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: context.textPrimaryColor),
            onPressed: () {
              context.push(AppRouter.notifications);
              // Reset badge sau khi vào trang notification
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _loadUnreadCount();
              });
            },
          ),
          if (_unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
