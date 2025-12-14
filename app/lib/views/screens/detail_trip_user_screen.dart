import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/services/trip_api_service.dart';
import 'package:app/services/favorite_api_service.dart';
import 'package:intl/intl.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';

class DetailTripUserScreen extends StatefulWidget {
  final int tripId;
  final int initialTab;
  const DetailTripUserScreen({
    super.key,
    required this.tripId,
    this.initialTab = 0,
  });

  @override
  State<DetailTripUserScreen> createState() => _DetailTripUserScreenState();
}

class _DetailTripUserScreenState extends State<DetailTripUserScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _favorites = [];
  List<DateTime> _tripDays = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      final dio = Dio();
      final tripApi = TripApiService(dio: dio, prefs: prefs);
      final favoriteApi = FavoriteApiService(dio: dio, prefs: prefs);

      // Load trip detail and favorites in parallel
      final results = await Future.wait([
        tripApi.getTripDetail(widget.tripId),
        favoriteApi.getUserFavorites(userId),
      ]);

      final trip = results[0] as Map<String, dynamic>;
      final favorites = results[1] as List<Map<String, dynamic>>;

      debugPrint('Loaded ${favorites.length} favorites');
      debugPrint('Favorites: $favorites');

      // Generate trip days
      final startDate = DateTime.parse(trip['startDate'] as String);
      final endDate = DateTime.parse(trip['endDate'] as String);
      final days = <DateTime>[];
      for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
        days.add(startDate.add(Duration(days: i)));
      }

      setState(() {
        _trip = trip;
        _favorites = favorites;
        _tripDays = days;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      debugPrint('Error loading trip detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _trip == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(title: const Text('Chi tiết chuyến đi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Không tải được thông tin chuyến đi'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final String tripName = _trip!['tripName'] as String? ?? 'Chuyến đi';
    final String coverImage =
        _trip!['coverImage'] as String? ?? 'assets/images/onboarding1.png';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            automaticallyImplyLeading: false,
            backgroundColor: context.backgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main background image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          coverImage.contains('onboarding')
                              ? 'assets/images/onboarding${(widget.tripId % 3) + 1}.png'
                              : coverImage,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.black54],
                      ),
                    ),
                  ),
                  // Top navigation buttons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: LucideIcons.chevronLeft,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        _ActionButton(icon: LucideIcons.share, onTap: () {}),
                        const SizedBox(width: 8),
                        _ActionButton(icon: LucideIcons.settings, onTap: () {}),
                      ],
                    ),
                  ),
                  // Title and date information
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'trip_badge'.tr,
                            style: context.captionStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tripName,
                          style: context.h2Style.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.calendar,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateRange(),
                                    style: context.captionStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: context.dividerColor.withValues(alpha: 0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorColor: context.primaryColor,
                  indicatorWeight: 3,
                  labelColor: context.primaryColor,
                  unselectedLabelColor: context.textSecondaryColor,
                  labelStyle: context.subTitleTwoStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: context.subTitleTwoStyle,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'saved_items'.tr),
                    Tab(text: 'itinerary'.tr),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _SavedTab(favorites: _favorites, onRefresh: _loadData),
            _ItineraryTab(
              tripId: widget.tripId,
              tripDays: _tripDays,
              trip: _trip!,
              onRefresh: _loadData,
              favorites: _favorites,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    if (_trip == null) return '';
    try {
      final startDate = DateTime.parse(_trip!['startDate'] as String);
      final endDate = DateTime.parse(_trip!['endDate'] as String);
      final formatter = DateFormat('d thg M', 'vi');
      return '${formatter.format(startDate)} — ${formatter.format(endDate)}, ${startDate.year}';
    } catch (e) {
      return '';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: context.textPrimaryColor, size: 20),
          ),
        ),
      ),
    );
  }
}

class _SavedTab extends StatelessWidget {
  final List<Map<String, dynamic>> favorites;
  final VoidCallback onRefresh;

  const _SavedTab({required this.favorites, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.heart,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có mục yêu thích nào',
              style: context.subTitleOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    // Group favorites by service type
    final hotels = favorites.where((f) => f['serviceType'] == 'hotel').toList();
    final restaurants = favorites
        .where((f) => f['serviceType'] == 'restaurant')
        .toList();
    final attractions = favorites
        .where((f) => f['serviceType'] == 'attraction')
        .toList();
    final tours = favorites.where((f) => f['serviceType'] == 'tour').toList();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          if (hotels.isNotEmpty) ...[
            _SectionHeader(
              title: '${'hotels'.tr} (${hotels.length})',
              icon: LucideIcons.building,
            ),
            const SizedBox(height: 16),
            ...hotels.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SavedItemCard(favorite: item, onRemoved: onRefresh),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (restaurants.isNotEmpty) ...[
            _SectionHeader(
              title: '${'restaurants'.tr} (${restaurants.length})',
              icon: LucideIcons.utensils,
            ),
            const SizedBox(height: 16),
            ...restaurants.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SavedItemCard(favorite: item, onRemoved: onRefresh),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (attractions.isNotEmpty) ...[
            _SectionHeader(
              title: '${'attractions'.tr} (${attractions.length})',
              icon: LucideIcons.mapPin,
            ),
            const SizedBox(height: 16),
            ...attractions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SavedItemCard(favorite: item, onRemoved: onRefresh),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (tours.isNotEmpty) ...[
            _SectionHeader(
              title: '${'tours'.tr} (${tours.length})',
              icon: LucideIcons.compass,
            ),
            const SizedBox(height: 16),
            ...tours.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SavedItemCard(favorite: item, onRemoved: onRefresh),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: context.primaryColor),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: context.h5Style.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SavedItemCard extends StatefulWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onRemoved;

  const _SavedItemCard({required this.favorite, required this.onRemoved});

  @override
  State<_SavedItemCard> createState() => _SavedItemCardState();
}

class _SavedItemCardState extends State<_SavedItemCard> {
  bool _isFavorite = true;

  List<Widget> _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    // Full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(LucideIcons.star, size: 16, color: Colors.amber));
    }

    // Half star
    if (hasHalfStar) {
      stars.add(
        Icon(
          LucideIcons.star,
          size: 16,
          color: Colors.amber.withValues(alpha: 0.5),
        ),
      );
    }

    // Empty stars
    for (int i = 0; i < emptyStars; i++) {
      stars.add(
        Icon(
          LucideIcons.star,
          size: 16,
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      );
    }

    return stars;
  }

  Future<void> _toggleFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) return;

      final serviceType = widget.favorite['serviceType'] as String;
      final serviceId = widget.favorite['serviceId'] as int;

      final favoriteService = FavoriteApiService(dio: Dio(), prefs: prefs);

      await favoriteService.removeFavorite(
        userId: userId,
        serviceType: serviceType,
        serviceId: serviceId,
      );

      setState(() => _isFavorite = false);
      widget.onRemoved();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xóa khỏi yêu thích')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  void _navigateToDetail() {
    final serviceType = widget.favorite['serviceType'] as String;
    final serviceId = widget.favorite['serviceId'] as int;

    switch (serviceType) {
      case 'hotel':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailOverviewScreen(hotelId: serviceId),
          ),
        );
        break;
      case 'restaurant':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantDetailScreen(restaurantId: serviceId),
          ),
        );
        break;
      case 'attraction':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttractionsOverviewDetailScreen(attractionId: serviceId),
          ),
        );
        break;
      case 'tour':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourServiceDetailScreen(tourId: serviceId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Backend returns flat structure: serviceName, serviceThumbnail, servicePrice, serviceAddress, averageRating
    final String title =
        widget.favorite['serviceName'] as String? ?? 'Không có tên';
    final String? image = widget.favorite['serviceThumbnail'] as String?;
    final double rating =
        (widget.favorite['averageRating'] as num?)?.toDouble() ?? 0.0;
    final double price =
        (widget.favorite['servicePrice'] as num?)?.toDouble() ?? 0.0;
    final String serviceType = widget.favorite['serviceType'] as String;

    String buttonText = 'Xem chi tiết';
    switch (serviceType) {
      case 'hotel':
        buttonText = 'Xem khách sạn';
        break;
      case 'restaurant':
        buttonText = 'Xem nhà hàng';
        break;
      case 'attraction':
        buttonText = 'Xem điểm tham quan';
        break;
      case 'tour':
        buttonText = 'Xem tour';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Circular image with gold border
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: image != null && image.isNotEmpty
                            ? (image.startsWith('http')
                                  ? Image.network(image, fit: BoxFit.cover)
                                  : Image.asset(image, fit: BoxFit.cover))
                            : Container(
                                color: context.dividerColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  LucideIcons.image,
                                  size: 40,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                      ),
                    ),
                    // Heart icon at top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isFavorite ? LucideIcons.heart : LucideIcons.heart,
                            size: 18,
                            color: _isFavorite
                                ? Colors.red
                                : context.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ..._buildRatingStars(rating),
                          const SizedBox(width: 4),
                          Text(
                            '(${rating.toStringAsFixed(1)})',
                            style: context.captionStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Giá từ: ',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          Text(
                            '${price.toInt()} đ',
                            style: context.subTitleOneStyle.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // View button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: context.subTitleOneStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  final int tripId;
  final List<DateTime> tripDays;
  final Map<String, dynamic> trip;
  final VoidCallback onRefresh;
  final List<Map<String, dynamic>> favorites;

  const _ItineraryTab({
    required this.tripId,
    required this.tripDays,
    required this.trip,
    required this.onRefresh,
    required this.favorites,
  });

  String _formatDay(DateTime day, int dayNumber) {
    final formatter = DateFormat('EEEE, d thg M', 'vi');
    return 'Ngày $dayNumber - ${formatter.format(day)}';
  }

  @override
  Widget build(BuildContext context) {
    if (tripDays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có thông tin ngày',
              style: context.subTitleOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      itemCount: tripDays.length,
      itemBuilder: (context, index) {
        final day = tripDays[index];
        // Find corresponding itinerary for this day
        final itineraries = trip['itineraries'] as List<dynamic>?;
        Map<String, dynamic>? itinerary;
        if (itineraries != null) {
          final dateStr = day.toIso8601String().split('T')[0];
          itinerary = itineraries.firstWhere(
            (it) => (it['itineraryDate'] as String).startsWith(dateStr),
            orElse: () => null,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DayCard(
            title: _formatDay(day, index + 1),
            date: day,
            tripId: tripId,
            onRefresh: onRefresh,
            favorites: favorites,
            itinerary: itinerary,
          ),
        );
      },
    );
  }
}

class _DayCard extends StatefulWidget {
  final String title;
  final DateTime date;
  final int tripId;
  final VoidCallback onRefresh;
  final List<Map<String, dynamic>> favorites;
  final Map<String, dynamic>? itinerary;

  const _DayCard({
    required this.title,
    required this.date,
    required this.tripId,
    required this.onRefresh,
    required this.favorites,
    this.itinerary,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    // Initialize notes from itinerary
    _notesController.text = widget.itinerary?['notes'] as String? ?? '';
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadItineraryItems();
  }

  Future<void> _loadItineraryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripService = TripApiService(dio: dio, prefs: prefs);

      final items = await tripService.getItineraryItemsByDate(
        tripId: widget.tripId,
        date: widget.date,
      );

      setState(() {
        _items = items;
      });
    } catch (e) {
      debugPrint('Error loading itinerary items: $e');
      setState(() {
        _items = [];
      });
    }
  }

  Future<void> _showAddActivityDialog() async {
    debugPrint('Favorites count: ${widget.favorites.length}');
    debugPrint('Favorites data: ${widget.favorites}');

    if (widget.favorites.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Chưa có dịch vụ yêu thích nào. Hãy thêm dịch vụ vào yêu thích trước!',
            ),
          ),
        );
      }
      return;
    }

    // Step 1: Calculate available time range
    TimeOfDay startTime;
    if (_items.isEmpty) {
      // First item: start from morning
      startTime = const TimeOfDay(hour: 7, minute: 0);
    } else {
      // Get end time of last item
      final lastItem = _items.last;
      final lastEndTime = lastItem['endTime'] as String?;
      if (lastEndTime != null) {
        final parts = lastEndTime.split(':');
        startTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        startTime = const TimeOfDay(hour: 7, minute: 0);
      }
    }

    // Check if day is full (reached 24:00)
    if (startTime.hour >= 23) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ngày này đã đầy lịch trình (đến 24h)!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Step 2: Show time picker dialog
    final timeRange = await _showTimePicker(startTime);
    if (timeRange == null) return; // User cancelled

    // Step 3: Show service selection with selected time
    final selected = await _showServiceSelection(timeRange);
    if (selected == null) return; // User cancelled

    // Step 4: Add to itinerary with time
    await _addToItinerary(selected, timeRange);
  }

  Future<Map<String, TimeOfDay>?> _showTimePicker(
    TimeOfDay minStartTime,
  ) async {
    TimeOfDay? selectedStart;
    TimeOfDay? selectedEnd;

    final result = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Chọn thời gian hoạt động'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thời gian bắt đầu khả dụng: ${minStartTime.format(context)}',
                  style: context.captionStyle,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Từ'),
                  trailing: Text(
                    selectedStart?.format(context) ?? 'Chọn giờ',
                    style: context.subTitleOneStyle.copyWith(
                      color: selectedStart != null
                          ? context.primaryColor
                          : context.textSecondaryColor,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: minStartTime,
                    );
                    if (picked != null) {
                      // Validate >= minStartTime
                      final pickedMinutes = picked.hour * 60 + picked.minute;
                      final minMinutes =
                          minStartTime.hour * 60 + minStartTime.minute;
                      if (pickedMinutes >= minMinutes) {
                        setState(() {
                          selectedStart = picked;
                          selectedEnd = null; // Reset end time
                        });
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thời gian phải từ ${minStartTime.format(context)} trở đi',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('Đến'),
                  trailing: Text(
                    selectedEnd?.format(context) ?? 'Chọn giờ',
                    style: context.subTitleOneStyle.copyWith(
                      color: selectedEnd != null
                          ? context.primaryColor
                          : context.textSecondaryColor,
                    ),
                  ),
                  enabled: selectedStart != null,
                  onTap: selectedStart == null
                      ? null
                      : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: selectedStart!.hour + 1,
                              minute: selectedStart!.minute,
                            ),
                          );
                          if (picked != null) {
                            // Validate > selectedStart and <= 24:00
                            final pickedMinutes =
                                picked.hour * 60 + picked.minute;
                            final startMinutes =
                                selectedStart!.hour * 60 +
                                selectedStart!.minute;
                            if (pickedMinutes > startMinutes &&
                                picked.hour < 24) {
                              setState(() => selectedEnd = picked);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Thời gian kết thúc phải sau thời gian bắt đầu và trước 24h',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: selectedStart != null && selectedEnd != null
                    ? () => Navigator.pop(context, {
                        'start': selectedStart!,
                        'end': selectedEnd!,
                      })
                    : null,
                child: const Text('Tiếp tục'),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }

  Future<Map<String, dynamic>?> _showServiceSelection(
    Map<String, TimeOfDay> timeRange,
  ) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chọn dịch vụ',
                          style: context.h3Style.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(LucideIcons.x),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timeRange['start']!.format(context)} - ${timeRange['end']!.format(context)}',
                            style: context.subTitleOneStyle.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = widget.favorites[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SelectableFavoriteCard(
                        favorite: favorite,
                        onTap: () => Navigator.pop(context, favorite),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToItinerary(
    Map<String, dynamic> favorite,
    Map<String, TimeOfDay> timeRange,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripService = TripApiService(dio: dio, prefs: prefs);

      final serviceId = favorite['serviceId'] as int;
      final serviceType = favorite['serviceType'] as String;

      // Format time to HH:mm:ss
      final startTime = timeRange['start']!;
      final endTime = timeRange['end']!;
      final startTimeStr =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeStr =
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

      await tripService.addItemToItinerary(
        tripId: widget.tripId,
        date: widget.date,
        serviceId: serviceId,
        serviceType: serviceType,
        startTime: startTimeStr,
        endTime: endTimeStr,
      );

      await _loadItineraryItems();
      // Don't call widget.onRefresh() to avoid resetting tab

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã thêm vào hành trình')));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Đã có lỗi xảy ra';

        final errorStr = e.toString();
        if (errorStr.contains('nằm ngoài phạm vi chuyến đi') ||
            errorStr.contains('No itinerary found')) {
          final dateStr = DateFormat('dd/MM/yyyy').format(widget.date);
          errorMessage = 'Ngày $dateStr nằm ngoài phạm vi chuyến đi!';
        } else if (errorStr.contains('đã có trong hành trình')) {
          errorMessage = 'Dịch vụ này đã có trong hành trình';
        } else if (errorStr.contains('bắt buộc')) {
          errorMessage = 'Vui lòng chọn thời gian bắt đầu và kết thúc';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorStr.contains('đã có trong hành trình')
                ? Colors.blue
                : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa hoạt động'),
        content: const Text(
          'Bạn có chắc muốn xóa hoạt động này khỏi hành trình?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripService = TripApiService(dio: dio, prefs: prefs);

      final itemId = item['itemId'] as int;
      await tripService.removeItineraryItem(itemId);

      await _loadItineraryItems();
      widget.onRefresh();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa khỏi hành trình')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  Future<void> _saveNotes() async {
    final itineraryId = widget.itinerary?['itineraryId'] as int?;
    if (itineraryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy hành trình')),
        );
      }
      return;
    }

    setState(() {
      _isSavingNotes = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripService = TripApiService(dio: dio, prefs: prefs);

      await tripService.updateItineraryNotes(
        itineraryId: itineraryId,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        // Unfocus để tắt bàn phím
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã lưu ghi chú')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingNotes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú cho ngày này',
          style: context.subTitleTwoStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Thêm ghi chú...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _isSavingNotes ? null : _saveNotes,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isSavingNotes
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Lưu ghi chú'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: context.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_items.length}',
                          style: context.captionStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: 20,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: context.dividerColor.withValues(alpha: 0.3),
                ),
                if (_items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.packagePlus,
                          size: 48,
                          color: context.textSecondaryColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có hoạt động nào',
                          style: context.bodyTwoStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddActivityDialog,
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text('Thêm hoạt động'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNotesSection(context),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ..._items.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == _items.length - 1 ? 0 : 16,
                            ),
                            child: _TimelineItem(
                              index: entry.key + 1,
                              item: entry.value,
                              onRemove: () => _removeItem(entry.value),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showAddActivityDialog,
                            icon: const Icon(LucideIcons.plus, size: 18),
                            label: const Text('Thêm hoạt động'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.primaryColor,
                              side: BorderSide(color: context.primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNotesSection(context),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Selectable favorite card for dialog
class _SelectableFavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onTap;

  const _SelectableFavoriteCard({required this.favorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Backend returns flat structure: serviceName, serviceThumbnail, servicePrice
    final String title = favorite['serviceName'] as String? ?? 'Không có tên';
    final String? image = favorite['serviceThumbnail'] as String?;
    final String serviceType = favorite['serviceType'] as String;

    IconData typeIcon;
    switch (serviceType) {
      case 'hotel':
        typeIcon = LucideIcons.building;
        break;
      case 'restaurant':
        typeIcon = LucideIcons.utensils;
        break;
      case 'attraction':
        typeIcon = LucideIcons.mapPin;
        break;
      case 'tour':
        typeIcon = LucideIcons.compass;
        break;
      default:
        typeIcon = LucideIcons.star;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: context.dividerColor.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image != null && image.isNotEmpty
                        ? (image.startsWith('http')
                              ? Image.network(image, fit: BoxFit.cover)
                              : Image.asset(image, fit: BoxFit.cover))
                        : Icon(
                            typeIcon,
                            size: 24,
                            color: context.textSecondaryColor,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            typeIcon,
                            size: 14,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getServiceTypeName(serviceType),
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
                  size: 20,
                  color: context.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getServiceTypeName(String type) {
    switch (type) {
      case 'hotel':
        return 'Khách sạn';
      case 'restaurant':
        return 'Nhà hàng';
      case 'attraction':
        return 'Điểm tham quan';
      case 'tour':
        return 'Tour';
      default:
        return type;
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;
  final VoidCallback? onRemove;

  const _TimelineItem({required this.index, required this.item, this.onRemove});

  void _navigateToDetail(BuildContext context) {
    final serviceType = item['serviceType'] as String?;
    final serviceId = item['serviceId'] as int?;

    if (serviceType == null || serviceId == null) return;

    switch (serviceType) {
      case 'hotel':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailOverviewScreen(hotelId: serviceId),
          ),
        );
        break;
      case 'restaurant':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantDetailScreen(restaurantId: serviceId),
          ),
        );
        break;
      case 'attraction':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttractionsOverviewDetailScreen(attractionId: serviceId),
          ),
        );
        break;
      case 'tour':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourServiceDetailScreen(tourId: serviceId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract service info from item - backend returns flat structure with serviceName
    final String title = item['serviceName'] as String? ?? 'Hoạt động';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$index',
              style: context.captionStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _navigateToDetail(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.subTitleTwoStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onRemove != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(LucideIcons.trash2, size: 18),
                        color: Colors.red,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
