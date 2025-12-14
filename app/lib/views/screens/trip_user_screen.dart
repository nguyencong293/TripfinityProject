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

import 'detail_trip_user_screen.dart';

class TripUserScreen extends StatefulWidget {
  const TripUserScreen({super.key});

  @override
  State<TripUserScreen> createState() => _TripUserScreenState();
}

class _TripUserScreenState extends State<TripUserScreen> {
  List<Map<String, dynamic>> _trips = [];
  int _totalFavorites = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
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
        setState(() {
          _error = 'Vui lòng đăng nhập';
          _loading = false;
        });
        return;
      }

      final dio = Dio();
      final tripApi = TripApiService(dio: dio, prefs: prefs);
      final favoriteApi = FavoriteApiService(dio: dio, prefs: prefs);

      // Load trips and favorites in parallel
      final results = await Future.wait([
        tripApi.getUserTrips(userId),
        favoriteApi.getUserFavorites(userId),
      ]);

      final trips = results[0];
      final favorites = results[1] as List<dynamic>;

      setState(() {
        _trips = trips;
        _totalFavorites = favorites.length;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      debugPrint('Error loading trip data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      floatingActionButton: _AddTripFab(
        onPressed: () => _showCreateTripSheet(context),
      ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'trips_title'.tr,
                        style: context.h4Style.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Active trips
                      if (_trips.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 64,
                                  color: context.textSecondaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có chuyến đi nào',
                                  style: context.subTitleOneStyle.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nhấn nút + để tạo chuyến đi mới',
                                  style: context.bodyTwoStyle.copyWith(
                                    color: context.textSecondaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._trips.map((trip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TripCard(
                              trip: trip,
                              totalFavorites: _totalFavorites,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailTripUserScreen(
                                      tripId: trip['tripId'] as int,
                                    ),
                                  ),
                                );
                              },
                              onEdit: () => _showEditTripSheet(context, trip),
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      // Completed trips section
                      Text(
                        'completed_trips'.tr,
                        style: context.subTitleTwoStyle.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'completed_trips_hint'.tr,
                        style: context.bodyTwoStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showCreateTripSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateTripBottomSheet(onTripCreated: _loadData),
    );
  }

  void _showEditTripSheet(BuildContext context, Map<String, dynamic> trip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 32), // balance close btn at right
                    Expanded(
                      child: Center(
                        child: Text(
                          'edit_trip'.tr,
                          style: context.subTitleTwoStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.dividerColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          color: context.textPrimaryColor,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: context.dividerColor.withValues(alpha: 0.2),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.calendarClock,
                    color: context.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'edit_time'.tr,
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditDateRange(context, trip);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.trash2,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  'cancel_trip'.tr,
                  style: context.bodyOneStyle.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.red,
                  size: 20,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteTrip(context, trip);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDateRange(
    BuildContext context,
    Map<String, dynamic> trip,
  ) async {
    // Parse current dates
    DateTime? currentStartDate;
    DateTime? currentEndDate;

    try {
      currentStartDate = DateTime.parse(trip['startDate'] as String);
      currentEndDate = DateTime.parse(trip['endDate'] as String);
    } catch (e) {
      currentStartDate = DateTime.now();
      currentEndDate = DateTime.now().add(const Duration(days: 1));
    }

    // Cache scaffold messenger before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: currentStartDate,
        end: currentEndDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripApi = TripApiService(dio: dio, prefs: prefs);

      await tripApi.updateTripDates(
        tripId: trip['tripId'] as int,
        startDate: DateFormat('yyyy-MM-dd').format(picked.start),
        endDate: DateFormat('yyyy-MM-dd').format(picked.end),
      );

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thời gian')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _confirmDeleteTrip(
    BuildContext context,
    Map<String, dynamic> trip,
  ) async {
    // Cache scaffold messenger before any async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa chuyến đi "${trip['tripName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      final tripApi = TripApiService(dio: dio, prefs: prefs);

      await tripApi.deleteTrip(trip['tripId'] as int);

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Đã xóa chuyến đi')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}

class _CreateTripBottomSheet extends StatefulWidget {
  final VoidCallback onTripCreated;

  const _CreateTripBottomSheet({required this.onTripCreated});

  @override
  State<_CreateTripBottomSheet> createState() => _CreateTripBottomSheetState();
}

class _CreateTripBottomSheetState extends State<_CreateTripBottomSheet> {
  final TextEditingController _tripNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  DateTimeRange? _dateRange;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Auto focus vào text field khi mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: context.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Future<void> _createTrip() async {
    if (_tripNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên chuyến đi')),
      );
      return;
    }

    if (_dateRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn thời gian')));
      return;
    }

    setState(() => _isCreating = true);

    // Cache these before async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      final dio = Dio();
      final tripApi = TripApiService(dio: dio, prefs: prefs);

      await tripApi.createTrip(
        userId: userId,
        tripName: _tripNameController.text.trim(),
        startDate: DateFormat('yyyy-MM-dd').format(_dateRange!.start),
        endDate: DateFormat('yyyy-MM-dd').format(_dateRange!.end),
      );

      if (mounted) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Đã tạo chuyến đi thành công')),
        );
        widget.onTripCreated();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header với nút close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 32), // balance close btn at right
                    Expanded(
                      child: Center(
                        child: Text(
                          'create_new_trip'.tr,
                          style: context.subTitleTwoStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.dividerColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          color: context.textPrimaryColor,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 1,
                color: context.dividerColor.withValues(alpha: 0.2),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trip_name_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Text field
                    Container(
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _tripNameController,
                        focusNode: _focusNode,
                        style: context.bodyOneStyle.copyWith(
                          color: context.textPrimaryColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'trip_name_hint'.tr,
                          hintStyle: context.bodyOneStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Để update trạng thái button
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date Range Picker
                    Text(
                      'Thời gian',
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 20,
                              color: context.textSecondaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dateRange == null
                                    ? 'Chọn thời gian'
                                    : '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                                style: context.bodyOneStyle.copyWith(
                                  color: _dateRange == null
                                      ? context.textSecondaryColor
                                      : context.textPrimaryColor,
                                ),
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

                    const SizedBox(height: 24),

                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreating
                            ? null
                            : (_tripNameController.text.trim().isEmpty ||
                                  _dateRange == null)
                            ? null
                            : _createTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'create_trip_button'.tr,
                                style: context.subTitleTwoStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final int totalFavorites;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _TripCard({
    required this.trip,
    required this.totalFavorites,
    required this.onTap,
    required this.onEdit,
  });

  String _formatDateRange() {
    try {
      final startDate = DateTime.parse(trip['startDate'] as String);
      final endDate = DateTime.parse(trip['endDate'] as String);
      final formatter = DateFormat('d MMM', 'vi');
      return '${formatter.format(startDate)} — ${formatter.format(endDate)}, ${startDate.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = trip['tripName'] as String? ?? 'Chuyến đi';

    // Random cover image from onboarding1-3 based on tripId for consistency
    final int tripId = trip['tripId'] as int? ?? 0;
    final int imageIndex = (tripId % 3) + 1;

    // Nếu coverImage null hoặc là default onboarding1, thì random
    final String? dbCoverImage = trip['coverImage'] as String?;
    final String coverImage =
        (dbCoverImage == null ||
            dbCoverImage.isEmpty ||
            dbCoverImage.contains('onboarding'))
        ? 'assets/images/onboarding$imageIndex.png'
        : dbCoverImage;

    final dateRangeText = _formatDateRange();
    final int savedCount = totalFavorites;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image
                AspectRatio(
                  aspectRatio: 1.8,
                  child: coverImage.startsWith('http')
                      ? Image.network(coverImage, fit: BoxFit.cover)
                      : Image.asset(
                          coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: context.dividerColor.withValues(alpha: 0.1),
                            child: Icon(
                              LucideIcons.image,
                              color: context.textSecondaryColor,
                              size: 48,
                            ),
                          ),
                        ),
                ),
                // Gradient overlay - tăng độ tối để text dễ đọc
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.15, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content overlay
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: context.subTitleOneStyle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Edit button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    LucideIcons.pencil,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateRangeText,
                              style: context.bodyTwoStyle.copyWith(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.heart,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$savedCount',
                            style: context.bodyTwoStyle.copyWith(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'yêu thích',
                            style: context.bodyTwoStyle.copyWith(
                              color: Colors.white70,
                              fontSize: 14,
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
        ),
      ),
    );
  }
}

class _AddTripFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddTripFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(27),
          child: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.plus,
              color: context.primaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
