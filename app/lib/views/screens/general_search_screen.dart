import 'package:app/views/screens/attractions_overview_search_screen.dart';
import 'package:app/views/screens/tour_service_overview_search_screen.dart';
import 'package:app/views/screens/restaurant_overview_search_screen.dart';
import 'package:app/views/screens/hotel_overview_search_screen.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/nearby_search_screen.dart';
import 'package:app/views/screens/search_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/services/recommendation_service.dart';

// Theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

// Screens
import 'search_overview_screen.dart';

// Networking
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use centralized API service and config
import 'package:app/services/search_api_service.dart';
import 'package:app/services/search_history_service.dart';
import 'package:app/services/user_interaction_service.dart';
import 'package:app/services/hotel_api_service.dart';
import 'package:app/services/restaurant_api_service.dart';
import 'package:app/services/tour_api_service.dart';
import 'package:app/services/attraction_api_service.dart';

// Quick filter categories
enum _QuickFilter { all, restaurant, hotel, tour, attraction }

class GeneralSearchScreen extends StatefulWidget {
  final String? initialQuery; // add this
  const GeneralSearchScreen({super.key, this.initialQuery});

  @override
  State<GeneralSearchScreen> createState() => _GeneralSearchScreenState();
}

class _GeneralSearchScreenState extends State<GeneralSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  _QuickFilter _selected = _QuickFilter.all;

  // ====== Dynamic data ======
  bool _loading = false;
  String? _error;
  bool _hasSearched = false; // Chỉ hiển thị kết quả sau khi user tìm

  // Top results
  List<Map<String, dynamic>> _hotelItems = [];
  List<Map<String, dynamic>> _restaurantItems = [];
  List<Map<String, dynamic>> _tourItems = [];
  List<Map<String, dynamic>> _attractionItems = [];
  List<Map<String, dynamic>> _destinationItems = []; // từ "area" trong response

  // Recent viewed items from search history
  List<Map<String, dynamic>> _recentViewedItems = [];
  bool _loadingRecentViewed = false;
  final String _lastSearchQuery = ''; // Track the last search query

  // Recommendations future
  late final Future<List<Map<String, dynamic>>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecentViewedItems();
    _recommendationsFuture = _loadRecommendations();
    final iq = widget.initialQuery?.trim();
    if (iq != null && iq.isNotEmpty) {
      _searchController.text = iq;
      // ensure it runs after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(iq);
      });
    }
  }

  @override
  void didUpdateWidget(covariant GeneralSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newQ = widget.initialQuery?.trim();
    final oldQ = oldWidget.initialQuery?.trim();
    if (newQ != null && newQ.isNotEmpty && newQ != oldQ) {
      _searchController.text = newQ;
      _performSearch(newQ);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: context.backgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickFilters(context),
                const SizedBox(height: 20),
                _buildSearchResults(context),
                const SizedBox(height: 32),
                _buildSuggestedPlaces(context),
                const SizedBox(height: 32),
                _buildNearbySection(context),
                const SizedBox(height: 32),
                _buildRecentSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Search bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 20),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_hint'.tr,
          hintStyle: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: context.textSecondaryColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: context.textSecondaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _hotelItems = [];
                      _restaurantItems = [];
                      _tourItems = [];
                      _attractionItems = [];
                      _destinationItems = [];
                      _error = null;
                      _loading = false;
                      _hasSearched = false;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: context.textDisabledColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: context.bodyOneStyle,
        onChanged: (value) => setState(() {}),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _performSearch(value),
      ),
    );
  }

  // Quick filters
  Widget _buildQuickFilters(BuildContext context) {
    final items = [
      ('Tất cả', LucideIcons.layoutPanelTop, _QuickFilter.all),
      ('Nhà hàng', LucideIcons.utensils, _QuickFilter.restaurant),
      ('Khách sạn', LucideIcons.hotel, _QuickFilter.hotel),
      ('Tour du lịch', LucideIcons.bus, _QuickFilter.tour),
      ('Điểm tham quan', LucideIcons.ticket, _QuickFilter.attraction),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bộ lọc',
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            final sel = _selected == e.$3;
            return FilterChip(
              selected: sel,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    e.$2,
                    size: 16,
                    color: sel
                        ? context.buttonTextColor
                        : context.textSecondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.$1,
                    style: context.bodyTwoStyle.copyWith(
                      color: sel
                          ? context.buttonTextColor
                          : context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: context.cardBackgroundColor,
              selectedColor: context.primaryColor,
              side: BorderSide(
                color: sel ? context.primaryColor : context.dividerColor,
              ),
              onSelected: (_) => setState(() => _selected = e.$3),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Results section (dynamic theo filter)
  Widget _buildSearchResults(BuildContext context) {
    if (!_hasSearched) return const SizedBox.shrink();

    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.primaryColor,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          _error!,
          style: context.captionStyle.copyWith(color: Colors.red),
        ),
      );
    }

    List<Map<String, dynamic>> items;
    switch (_selected) {
      case _QuickFilter.hotel:
        items = _hotelItems.take(5).toList();
        break;
      case _QuickFilter.restaurant:
        items = _restaurantItems.take(5).toList();
        break;
      case _QuickFilter.tour:
        items = _tourItems.take(5).toList();
        break;
      case _QuickFilter.attraction:
        items = _attractionItems.take(5).toList();
        break;
      case _QuickFilter.all:
        items = _composeAllItemsMax5();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Không có kết quả',
              style: context.captionStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),
        if (items.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = (item['imageUrl'] ?? '').toString();
              final hasNetwork = imageUrl.startsWith('http');
              final isDestination =
                  (item['type']?.toString() ?? '') == 'destination';

              Widget leading;
              if (hasNetwork) {
                // Network image: if destination and load fails -> use provided fallback
                leading = Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    if (isDestination) {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: _imageFallback(context),
                      );
                    }
                    // keep existing small placeholder for others
                    return Container(
                      width: 60,
                      height: 60,
                      color: context.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        LucideIcons.image,
                        color: context.primaryColor,
                        size: 20,
                      ),
                    );
                  },
                );
              } else {
                // Asset image: if destination and asset fails -> use provided fallback
                leading = Image.asset(
                  item['image']?.toString() ?? 'assets/images/onboarding1.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    if (isDestination) {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: _imageFallback(context),
                      );
                    }
                    return Container(
                      width: 60,
                      height: 60,
                      color: context.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        LucideIcons.image,
                        color: context.primaryColor,
                        size: 20,
                      ),
                    );
                  },
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    final type = item['type']?.toString();
                    if (type == 'hotel') {
                      _openHotelDetail(item);
                    } else if (type == 'restaurant') {
                      _openRestaurantDetail(item);
                    } else if (type == 'tour') {
                      _openTourDetail(item);
                    } else if (type == 'attraction') {
                      _openAttractionDetail(item);
                    } else if (type == 'destination') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SearchOverviewScreen(
                            searchQuery: item['name'].toString(),
                          ),
                        ),
                      );
                    } else {
                      _navigateToSpecificPage(
                        item['name'].toString(),
                        type ?? 'general',
                      );
                    }
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: leading,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']?.toString() ?? '',
                              style: context.bodyOneStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['location']?.toString() ?? '',
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Không hiển thị rating cho destination
                            if (!isDestination)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: context.primaryColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getRatingString(item['rating']),
                                    style: context.captionStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if ((item['price']?.toString() ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      item['price'].toString(),
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
                        LucideIcons.chevronRight,
                        color: context.textSecondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              final query = _searchController.text.trim();
              _openSeeMoreForCurrentFilter(query);
            },
            child: Text(
              'Xem thêm',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openSeeMoreForCurrentFilter(String query) {
    switch (_selected) {
      case _QuickFilter.hotel:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HotelOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case _QuickFilter.restaurant:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case _QuickFilter.tour:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourServiceOverviewScreen(searchQuery: query),
          ),
        );
        break;
      case _QuickFilter.attraction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AttractionOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case _QuickFilter.all:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchOverviewScreen(searchQuery: query),
          ),
        );
        break;
    }
  }

  // Suggested places (Recommendations)
  Widget _buildSuggestedPlaces(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _recommendationsFuture,
      builder: (context, snapshot) {
        // Show loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Có thể bạn quan tâm',
                style: context.subTitleOneStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ],
          );
        }

        // Don't show if error or no data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show section with data (only 3 items)
        final items = snapshot.data!.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Có thể bạn quan tâm',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final imageUrl =
                    item['imageUrl']?.toString() ??
                    item['image']?.toString() ??
                    '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      final type =
                          item['type']?.toString() ??
                          item['itemType']?.toString() ??
                          '';
                      final itemId = item['itemId'] ?? 0;

                      // Navigate to detail screen based on type
                      _navigateToServiceDetail(type, itemId);
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: _imageFallback(context),
                                  ),
                                )
                              : SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: _imageFallback(context),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']?.toString() ??
                                    item['title']?.toString() ??
                                    '',
                                style: context.bodyOneStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if ((item['location']?.toString() ?? '')
                                  .isNotEmpty)
                                Text(
                                  item['location']!.toString(),
                                  style: context.captionStyle.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: context.primaryColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getRatingString(item['rating']),
                                    style: context.captionStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if ((item['price']?.toString() ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      item['price'].toString(),
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
                          LucideIcons.chevronRight,
                          color: context.textSecondaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Nearby section
  Widget _buildNearbySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.navigation, color: context.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: () {
              // Chuyển đến màn hình Nearby Search
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NearbySearchScreen()),
              );
            },
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, color: context.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm kiếm xung quanh',
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Khám phá địa điểm gần vị trí của bạn',
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
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
      ],
    );
  }

  // Recent section
  Widget _buildRecentSection(BuildContext context) {
    if (_loadingRecentViewed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: context.primaryColor,
            ),
          ),
        ),
      );
    }

    if (_recentViewedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã xem gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_recentViewedItems.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchHistoryScreen(),
                    ),
                  );
                },
                child: Text(
                  'Xem thêm',
                  style: context.captionStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentViewedItems.length > 3
              ? 3
              : _recentViewedItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRecentItemTile(context, index),
        ),
      ],
    );
  }

  Widget _buildRecentItemTile(BuildContext context, int index) {
    if (index >= _recentViewedItems.length) {
      return const SizedBox.shrink();
    }

    final item = _recentViewedItems[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          final type = item['itemType']?.toString() ?? item['type']?.toString();
          if (type == 'hotel') {
            _openHotelDetail(item);
          } else if (type == 'restaurant') {
            _openRestaurantDetail(item);
          } else if (type == 'attraction') {
            _openAttractionDetail(item);
          } else if (type == 'tour') {
            _openTourDetail(item);
          } else {
            _navigateToSpecificPage(
              item['itemTitle']?.toString() ?? item['name']?.toString() ?? '',
              type ?? 'general',
            );
          }
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildRecentItemImage(item, index),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['itemTitle']?.toString() ??
                        item['name']?.toString() ??
                        '',
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['itemLocation']?.toString() ??
                        item['location']?.toString() ??
                        '',
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: context.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRatingString(item['itemRating'] ?? item['rating']),
                        style: context.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
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
    );
  }

  // ===== NAVIGATION HELPERS =====
  void _navigateToServiceDetail(String serviceType, int serviceId) {
    // Create a simple item map with required fields
    final item = {'itemId': serviceId, 'id': serviceId};

    switch (serviceType.toLowerCase()) {
      case 'hotel':
        item['hotelId'] = serviceId;
        _openHotelDetail(item);
        break;
      case 'restaurant':
        item['restaurantId'] = serviceId;
        _openRestaurantDetail(item);
        break;
      case 'tour':
        item['tourId'] = serviceId;
        _openTourDetail(item);
        break;
      case 'attraction':
        item['attractionId'] = serviceId;
        _openAttractionDetail(item);
        break;
      default:
        debugPrint('⚠️ Unknown service type: $serviceType');
    }
  }

  Future<void> _openHotelDetail(Map<String, dynamic> hotel) async {
    final id = _parseId(hotel, ['hotelId', 'id', 'hotel_id', 'itemId']);
    final title =
        hotel['itemTitle']?.toString() ?? hotel['name']?.toString() ?? '';
    final location =
        hotel['itemLocation']?.toString() ??
        hotel['location']?.toString() ??
        '';
    final imageUrl =
        hotel['itemThumbnailUrl']?.toString() ?? hotel['imageUrl']?.toString();

    // Save to history
    final searchQuery = _searchController.text.trim().isEmpty
        ? _lastSearchQuery.isEmpty
              ? title
              : _lastSearchQuery
        : _searchController.text.trim();

    await _saveClickedItem(
      searchQuery: searchQuery,
      searchType: 'hotel',
      itemType: 'hotel',
      itemId: id,
      itemTitle: title,
      itemLocation: location,
      itemThumbnailUrl: imageUrl,
    );

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'hotel');
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HotelDetailOverviewScreen(
          hotelId: id,
          hotel: {
            'name': title,
            'image':
                hotel['image']?.toString() ??
                imageUrl ??
                'assets/images/onboarding1.png',
            'price': hotel['price']?.toString() ?? '—',
          },
          activeAmenities: const {'Wifi miễn phí', 'Bể bơi'},
        ),
      ),
    );
  }

  Future<void> _openRestaurantDetail(Map<String, dynamic> restaurant) async {
    final id = _parseId(restaurant, [
      'restaurantId',
      'id',
      'restaurant_id',
      'itemId',
    ]);
    final title =
        restaurant['itemTitle']?.toString() ??
        restaurant['name']?.toString() ??
        '';
    final location =
        restaurant['itemLocation']?.toString() ??
        restaurant['location']?.toString() ??
        '';
    final imageUrl =
        restaurant['itemThumbnailUrl']?.toString() ??
        restaurant['imageUrl']?.toString();
    final rating = restaurant['itemRating'] ?? restaurant['rating'];

    // Save to history
    final searchQuery = _searchController.text.trim().isEmpty
        ? _lastSearchQuery.isEmpty
              ? title
              : _lastSearchQuery
        : _searchController.text.trim();

    await _saveClickedItem(
      searchQuery: searchQuery,
      searchType: 'restaurant',
      itemType: 'restaurant',
      itemId: id,
      itemTitle: title,
      itemLocation: location,
      itemThumbnailUrl: imageUrl,
    );

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
            'name': title,
            'location': location,
            'rating': _getRatingString(rating),
            'type': 'restaurant',
            'cuisine': restaurant['cuisine']?.toString() ?? '—',
            'price': restaurant['price']?.toString() ?? '',
            'reviews': '(320)',
            'tag': restaurant['tag']?.toString() ?? '',
            'image':
                restaurant['image']?.toString() ??
                imageUrl ??
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

  Future<void> _openTourDetail(Map<String, dynamic> tour) async {
    final id = _parseId(tour, ['tourId', 'id', 'tour_id', 'itemId']);
    final title =
        tour['itemTitle']?.toString() ?? tour['name']?.toString() ?? '';
    final location =
        tour['itemLocation']?.toString() ?? tour['location']?.toString() ?? '';
    final imageUrl =
        tour['itemThumbnailUrl']?.toString() ?? tour['imageUrl']?.toString();
    final rating = tour['itemRating'] ?? tour['rating'];

    // Save to history
    final searchQuery = _searchController.text.trim().isEmpty
        ? _lastSearchQuery.isEmpty
              ? title
              : _lastSearchQuery
        : _searchController.text.trim();

    await _saveClickedItem(
      searchQuery: searchQuery,
      searchType: 'tour',
      itemType: 'tour',
      itemId: id,
      itemTitle: title,
      itemLocation: location,
      itemThumbnailUrl: imageUrl,
    );

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'tour');
    }

    final tourData = {
      'name': title,
      'location': location,
      'rating': _getRatingString(rating),
      'price': tour['price']?.toString() ?? '',
      'image':
          tour['image']?.toString() ??
          imageUrl ??
          'assets/images/onboarding1.png',
      'duration': tour['duration']?.toString() ?? '',
      'description': tour['description']?.toString() ?? '',
      'tourId': id,
    };

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TourServiceDetailScreen(tourId: id, tour: tourData),
      ),
    );
  }

  Future<void> _openAttractionDetail(Map<String, dynamic> attraction) async {
    final id = _parseId(attraction, [
      'attractionId',
      'id',
      'attraction_id',
      'itemId',
    ]);
    final title =
        attraction['itemTitle']?.toString() ??
        attraction['name']?.toString() ??
        '';
    final location =
        attraction['itemLocation']?.toString() ??
        attraction['location']?.toString() ??
        '';
    final imageUrl =
        attraction['itemThumbnailUrl']?.toString() ??
        attraction['imageUrl']?.toString();
    final rating = attraction['itemRating'] ?? attraction['rating'];
    final priceInt = _extractPrice(attraction['price']?.toString() ?? '');

    // Save to history
    final searchQuery = _searchController.text.trim().isEmpty
        ? _lastSearchQuery.isEmpty
              ? title
              : _lastSearchQuery
        : _searchController.text.trim();

    await _saveClickedItem(
      searchQuery: searchQuery,
      searchType: 'attraction',
      itemType: 'attraction',
      itemId: id,
      itemTitle: title,
      itemLocation: location,
      itemThumbnailUrl: imageUrl,
    );

    // 🔥 Track CLICK for AI recommendation
    if (id != null && id > 0) {
      final trackingService = await UserInteractionService.create();
      trackingService.recordClick(itemId: id, itemType: 'attraction');
    }

    final attractionData = {
      'name': title,
      'location': location,
      'rating': double.tryParse(_getRatingString(rating)) ?? 0.0,
      'price': priceInt,
      'description':
          attraction['description']?.toString() ??
          'Điểm tham quan tại ${attraction['location']?.toString() ?? ''}',
      'image':
          attraction['image']?.toString() ??
          attraction['imageUrl']?.toString() ??
          'assets/images/onboarding3.png',
      'types': attraction['types'] is List
          ? List.from(attraction['types'])
          : ['Tham quan'],
      'services': attraction['services'] is List
          ? List.from(attraction['services'])
          : ['Chụp ảnh'],
      'times': attraction['times'] is List
          ? List.from(attraction['times'])
          : ['Sáng', 'Chiều'],
      'suit': attraction['suit'] is List
          ? List.from(attraction['suit'])
          : ['Solo', 'Cặp đôi'],
      'attractionId': id,
    };

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttractionsOverviewDetailScreen(
          attractionId: id,
          attraction: attractionData,
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====
  // Gom danh sách "Tất cả" tối đa 5, ưu tiên area trước, sau đó round-robin các loại
  List<Map<String, dynamic>> _composeAllItemsMax5() {
    final List<Map<String, dynamic>> result = [];
    if (_destinationItems.isNotEmpty) {
      result.add(_destinationItems.first); // area lên đầu nếu có
    }
    final lists = [
      _hotelItems.iterator,
      _restaurantItems.iterator,
      _tourItems.iterator,
      _attractionItems.iterator,
    ];

    while (result.length < 5) {
      bool progressed = false;
      for (final it in lists) {
        if (result.length >= 5) break;
        if (it.moveNext()) {
          result.add(it.current);
          progressed = true;
          if (result.length >= 5) break;
        }
      }
      if (!progressed) break;
    }
    return result;
  }

  // Helper to extract numeric price from string
  int _extractPrice(String priceString) {
    final numbers = priceString.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(numbers) ?? 0;
  }

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
    if (rating is num) {
      return rating.toString();
    }
    return '0.0';
  }

  String _getSearchCategory(String query) {
    final q = query.toLowerCase();
    if (q.contains('resort') ||
        q.contains('khách sạn') ||
        q.contains('hotel') ||
        q.contains('vinpearl')) {
      return 'hotel';
    }
    if (q.contains('nhà hàng') ||
        q.contains('restaurant') ||
        q.contains('white rose')) {
      return 'restaurant';
    }
    if (q.contains('tour')) {
      return 'tour';
    }
    if (q.contains('spa') ||
        q.contains('massage') ||
        q.contains('tháp chăm') ||
        q.contains('po nagar')) {
      return 'activity';
    }
    return 'general';
  }

  void _navigateToSpecificPage(String query, String category) {
    switch (category) {
      case 'hotel':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HotelOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case 'restaurant':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      case 'tour':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TourServiceOverviewScreen(searchQuery: query),
          ),
        );
        break;
      case 'activity':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AttractionOverviewSearchScreen(searchQuery: query),
          ),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchOverviewScreen(searchQuery: query),
          ),
        );
    }
  }

  // Submit search: ở màn hình này chỉ tải và hiển thị top 5, KHÔNG điều hướng
  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _hasSearched = true;
    });

    final category = _getSearchCategory(trimmed);
    String searchType = 'general';
    if (category == 'hotel') {
      _selected = _QuickFilter.hotel;
      searchType = 'hotel';
    } else if (category == 'tour') {
      _selected = _QuickFilter.tour;
      searchType = 'tour';
    } else if (category == 'restaurant') {
      _selected = _QuickFilter.restaurant;
      searchType = 'restaurant';
    } else if (category == 'activity') {
      _selected = _QuickFilter.attraction;
      searchType = 'attraction';
    } else {
      _selected = _QuickFilter.all;
      searchType = 'general';
    }

    // Save search query to history
    await _saveSearchQuery(trimmed, searchType);

    // 🔥 Track SEARCH action for AI
    _trackSearch(searchType);

    _fetchSearch(trimmed);
  }

  /// 🔥 Track SEARCH for AI
  Future<void> _trackSearch(String searchType) async {
    try {
      final trackingService = await UserInteractionService.create();

      // Map searchType to itemType
      String itemType;
      switch (searchType) {
        case 'hotel':
          itemType = 'hotel';
          break;
        case 'restaurant':
          itemType = 'restaurant';
          break;
        case 'tour':
          itemType = 'tour';
          break;
        case 'attraction':
          itemType = 'attraction';
          break;
        default:
          // General search: track theo loại có nhiều kết quả nhất
          final counts = {
            'hotel': _hotelItems.length,
            'restaurant': _restaurantItems.length,
            'tour': _tourItems.length,
            'attraction': _attractionItems.length,
          };
          final maxEntry = counts.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
          );
          itemType = maxEntry.value > 0
              ? maxEntry.key
              : 'tour'; // Fallback to tour
      }

      await trackingService.recordSearch(itemType: itemType);
    } catch (e) {
      // Silent fail
    }
  }

  // ===== API =====
  Future<void> _fetchSearch(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final api = SearchApiService(dio: Dio(), prefs: prefs);

      final data = await api.search(q: query);

      // Map "area" -> destination item (hiện đầu tiên nếu có)
      final List<Map<String, dynamic>> dst = [];
      if (data['area'] is Map) {
        final area = Map<String, dynamic>.from(data['area'] as Map);
        dst.add({
          'name': area['name']?.toString() ?? 'Khu vực',
          'location': area['slug']?.toString() ?? '',
          'type': 'destination',
          // try common image keys so errorBuilder can trigger fallback if bad
          'imageUrl':
              (area['thumbnailUrl'] ??
                      area['imageUrl'] ??
                      area['bannerUrl'] ??
                      area['coverUrl'])
                  ?.toString(),
          'image': 'assets/images/onboarding1.png',
        });
      }

      List<Map<String, dynamic>> hotels = [];
      List<Map<String, dynamic>> restaurants = [];
      List<Map<String, dynamic>> tours = [];
      List<Map<String, dynamic>> attractions = [];

      if (data['hotels'] is List) {
        hotels = List.from(data['hotels']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'hotelId': m['hotelId'] ?? m['id'] ?? m['hotel_id'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'hotel',
            'price': _formatPrice(price, currency),
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding2.png',
          };
        }).toList();
      }

      if (data['restaurants'] is List) {
        restaurants = List.from(data['restaurants']).map<Map<String, dynamic>>((
          e,
        ) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'restaurantId': m['restaurantId'] ?? m['id'] ?? m['restaurant_id'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'restaurant',
            'cuisine': m['cuisineType']?.toString(),
            'price': _formatPrice(price, currency),
            'tag': (m['badges'] is List && (m['badges'] as List).isNotEmpty)
                ? (m['badges'] as List).first.toString()
                : null,
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding3.png',
          };
        }).toList();
      }

      if (data['tours'] is List) {
        tours = List.from(data['tours']).map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'tourId': m['tourId'] ?? m['id'] ?? m['tour_id'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'tour',
            'duration': (m['durationDays']?.toString() ?? ''),
            'price': _formatPrice(price, currency),
            'description': m['itineraryOverview']?.toString() ?? '',
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding1.png',
          };
        }).toList();
      }

      if (data['attractions'] is List) {
        attractions = List.from(data['attractions']).map<Map<String, dynamic>>((
          e,
        ) {
          final m = Map<String, dynamic>.from(e);
          final price = m['price'];
          final currency = m['currencyCode']?.toString();
          return {
            'attractionId': m['attractionId'] ?? m['id'] ?? m['attraction_id'],
            'name': m['title']?.toString() ?? '',
            'location': m['location']?.toString() ?? '',
            'rating': m['ratingAverage'],
            'type': 'attraction',
            'price': _formatPrice(price, currency),
            'description': m['serviceDescription']?.toString() ?? '',
            'imageUrl': m['thumbnailUrl'],
            'image': 'assets/images/onboarding4.png',
            'types': m['types'] is List ? List.from(m['types']) : [],
            'services': m['services'] is List ? List.from(m['services']) : [],
            'times': m['times'] is List ? List.from(m['times']) : [],
            'suit': m['suit'] is List ? List.from(m['suit']) : [],
          };
        }).toList();
      }

      setState(() {
        _destinationItems = dst;
        _hotelItems = hotels;
        _restaurantItems = restaurants;
        _tourItems = tours;
        _attractionItems = attractions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        // backend yêu cầu Authorization bắt buộc -> 401 nếu thiếu token
        _error = 'Không thể tải dữ liệu. Vui lòng thử lại hoặc đăng nhập.';
      });
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
    if (n == null) return price.toString();
    final c = (currency ?? '').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') {
      return '${n.toStringAsFixed(0)} đ';
    }
    if (c.isEmpty) return n.toString();
    return '$n $c';
  }

  // Provided fallback for area image error
  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 180,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  // Build image for recent viewed item
  Widget _buildRecentItemImage(Map<String, dynamic> item, int index) {
    final imageUrl =
        item['itemThumbnailUrl']?.toString() ??
        item['imageUrl']?.toString() ??
        '';

    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/onboarding${(index % 4) + 1}.png',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      'assets/images/onboarding${(index % 4) + 1}.png',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  // Load recent viewed items from search history
  Future<void> _loadRecentViewedItems() async {
    setState(() {
      _loadingRecentViewed = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);

      final viewedItems = await historyService.getRecentViewedItems(limit: 10);

      // Convert API response to the format expected by the UI and fetch latest ratings
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
          // For compatibility with existing navigation methods
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
        _recentViewedItems = items;
        _loadingRecentViewed = false;
      });
    } catch (e) {
      // If user is not logged in or error occurs, just show empty list
      setState(() {
        _recentViewedItems = [];
        _loadingRecentViewed = false;
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

  // Load recommendations
  Future<List<Map<String, dynamic>>> _loadRecommendations() async {
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

      final items = <Map<String, dynamic>>[];

      for (final item in response.data!) {
        final serviceType = item.itemType.toLowerCase();
        final serviceId = item.itemId;

        debugPrint('🔎 Looking for $serviceType #$serviceId: ${item.title}');

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
          items.add({
            'name': item.title,
            'title': item.title,
            'rating': 0.0,
            'image': '',
            'imageUrl': '',
            'price': item.priceFmt,
            'type': serviceType,
            'itemType': serviceType,
            'itemId': serviceId,
            'location': '',
          });
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

          items.add({
            'name': item.title,
            'title': item.title,
            'rating': rating,
            'image': imageUrl,
            'imageUrl': imageUrl,
            'price': item.priceFmt,
            'type': serviceType,
            'itemType': serviceType,
            'itemId': serviceId,
            'location': matchedItem['location'] ?? matchedItem['address'] ?? '',
          });
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

  // Save search query to history
  Future<void> _saveSearchQuery(String query, String searchType) async {
    debugPrint(
      '🔍 _saveSearchQuery called: query="$query", type="$searchType"',
    );
    if (query.isEmpty) {
      debugPrint('⚠️ Query is empty, skipping save');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Check if user is logged in
      final token = prefs.getString('user_token');
      debugPrint('🔑 Token exists: ${token != null && token.isNotEmpty}');
      if (token == null || token.isEmpty) {
        // User not logged in - skip saving silently
        debugPrint('⚠️ No token found, skipping save');
        return;
      }

      debugPrint('📡 Calling SearchHistoryService.saveSearchQuery...');
      final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);
      await historyService.saveSearchQuery(
        searchQuery: query,
        searchType: searchType,
      );
      debugPrint('✅ Saved search query: $query ($searchType)');
    } catch (e) {
      // Silently fail - don't interrupt user experience
      if (e.toString().contains('authentication') ||
          e.toString().contains('token')) {
        // Auth error - user not logged in, skip silently
        debugPrint('⚠️ Auth error, skipping: $e');
        return;
      }
      debugPrint('❌ Failed to save search query: $e');
    }
  }

  // Save clicked item to history
  Future<void> _saveClickedItem({
    required String searchQuery,
    required String searchType,
    required String itemType,
    int? itemId,
    String? itemTitle,
    String? itemLocation,
    String? itemThumbnailUrl,
  }) async {
    debugPrint(
      '👆 _saveClickedItem called: query="$searchQuery", item="$itemTitle", type="$itemType", id=$itemId',
    );
    if (searchQuery.isEmpty) {
      debugPrint('⚠️ Search query is empty, skipping save');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // Check if user is logged in
      final token = prefs.getString('user_token');
      debugPrint('🔑 Token exists: ${token != null && token.isNotEmpty}');
      if (token == null || token.isEmpty) {
        // User not logged in - skip saving silently
        debugPrint('⚠️ No token found, skipping save');
        return;
      }

      debugPrint('📡 Calling SearchHistoryService.saveClickedItem...');
      final historyService = SearchHistoryService(dio: Dio(), prefs: prefs);
      await historyService.saveClickedItem(
        searchQuery: searchQuery,
        searchType: searchType,
        itemType: itemType,
        itemId: itemId,
        itemTitle: itemTitle,
        itemLocation: itemLocation,
        itemThumbnailUrl: itemThumbnailUrl,
      );
      debugPrint(
        '✅ Saved clicked item: $itemTitle ($itemType) for query "$searchQuery"',
      );
    } catch (e) {
      // Silently fail - don't interrupt user experience
      if (e.toString().contains('authentication') ||
          e.toString().contains('token')) {
        // Auth error - user not logged in, skip silently
        debugPrint('⚠️ Auth error, skipping: $e');
        return;
      }
      debugPrint('❌ Failed to save clicked item: $e');
    }
  }
}
