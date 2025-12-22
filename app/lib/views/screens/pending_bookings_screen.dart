import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/hotel_booking_api_service.dart';
import '../../services/tour_booking_api_service.dart';
import '../../services/restaurant_booking_api_service.dart';
import '../../services/attraction_booking_api_service.dart';

/// Screen displaying pending bookings (provider_confirmed = 0 or null)
class PendingBookingsScreen extends StatefulWidget {
  const PendingBookingsScreen({super.key});

  @override
  State<PendingBookingsScreen> createState() => _PendingBookingsScreenState();
}

class _PendingBookingsScreenState extends State<PendingBookingsScreen> {
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      _userId = prefs.getInt('user_id');

      if (_userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final hotelApi = HotelBookingApiService(dio: dio, prefs: prefs);
      final tourApi = TourBookingApiService(dio: dio, prefs: prefs);
      final restaurantApi = RestaurantBookingApiService(dio: dio, prefs: prefs);
      final attractionApi = AttractionBookingApiService(dio: dio, prefs: prefs);

      // Load bookings from all services
      final List<Map<String, dynamic>> allBookings = [];

      try {
        final hotelBookings = await hotelApi.getBookingsByUser(_userId!);
        for (var b in hotelBookings) {
          // Pending = providerConfirmed is 0 or null
          if (b['providerConfirmed'] == 0 || b['providerConfirmed'] == null) {
            b['serviceType'] = 'hotel';
            b['serviceName'] = b['hotelName'] ?? 'Khách sạn';
            allBookings.add(b);
          }
        }
      } catch (e) {
        debugPrint('Error loading hotel bookings: $e');
      }

      try {
        final tourBookings = await tourApi.getBookingsByUser(_userId!);
        for (var b in tourBookings) {
          if (b['providerConfirmed'] == 0 || b['providerConfirmed'] == null) {
            b['serviceType'] = 'tour';
            b['serviceName'] = b['tourName'] ?? 'Tour';
            allBookings.add(b);
          }
        }
      } catch (e) {
        debugPrint('Error loading tour bookings: $e');
      }

      try {
        final restaurantBookings = await restaurantApi.getBookingsByUser(
          _userId!,
        );
        for (var b in restaurantBookings) {
          if (b['providerConfirmed'] == 0 || b['providerConfirmed'] == null) {
            b['serviceType'] = 'restaurant';
            b['serviceName'] = b['restaurantName'] ?? 'Nhà hàng';
            allBookings.add(b);
          }
        }
      } catch (e) {
        debugPrint('Error loading restaurant bookings: $e');
      }

      try {
        final attractionBookings = await attractionApi.getBookingsByUser(
          _userId!,
        );
        for (var b in attractionBookings) {
          if (b['providerConfirmed'] == 0 || b['providerConfirmed'] == null) {
            b['serviceType'] = 'attraction';
            b['serviceName'] = b['attractionName'] ?? 'Điểm tham quan';
            allBookings.add(b);
          }
        }
      } catch (e) {
        debugPrint('Error loading attraction bookings: $e');
      }

      // Sort by createdAt DESC
      allBookings.sort((a, b) {
        final aDate = a['createdAt']?.toString() ?? '';
        final bDate = b['createdAt']?.toString() ?? '';
        return bDate.compareTo(aDate);
      });

      setState(() {
        _allBookings = allBookings;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'hotel':
        return LucideIcons.hotel;
      case 'tour':
        return LucideIcons.map;
      case 'restaurant':
        return LucideIcons.utensils;
      case 'attraction':
        return LucideIcons.landmark;
      default:
        return LucideIcons.ticket;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'hotel':
        return Colors.blue;
      case 'tour':
        return Colors.orange;
      case 'restaurant':
        return Colors.red;
      case 'attraction':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getServiceLabel(String serviceType) {
    switch (serviceType) {
      case 'hotel':
        return 'Khách sạn';
      case 'tour':
        return 'Tour';
      case 'restaurant':
        return 'Nhà hàng';
      case 'attraction':
        return 'Điểm tham quan';
      default:
        return 'Dịch vụ';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0 đ';
    final numPrice = price is num ? price : num.tryParse(price.toString()) ?? 0;
    // Format with thousands separator
    final formatted = numPrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        title: Text(
          'Đang chờ xử lý',
          style: context.h5Style.copyWith(color: context.textPrimaryColor),
        ),
        iconTheme: IconThemeData(color: context.textPrimaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allBookings.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _allBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildBookingCard(_allBookings[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.clock, size: 64, color: context.textSecondaryColor),
          const SizedBox(height: 16),
          Text(
            'Không có đơn đặt nào đang chờ xử lý',
            style: context.bodyOneStyle.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final serviceType = booking['serviceType'] as String? ?? '';
    final serviceName = booking['serviceName'] as String? ?? 'Dịch vụ';
    final location =
        booking['location'] as String? ?? booking['address'] as String? ?? '';
    final totalPrice = booking['totalPrice'];
    final startDate = booking['startDate'] as String?;
    final imageUrl =
        booking['imageUrl'] as String? ??
        booking['thumbnailUrl'] as String? ??
        '';
    final rating = booking['rating'];
    final paymentMethod = booking['paymentMethod'] as String? ?? 'counter';
    // ignore: unused_local_variable
    final isPaid = paymentMethod != 'counter';

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: _getServiceColor(
                              serviceType,
                            ).withValues(alpha: 0.2),
                            child: Icon(
                              _getServiceIcon(serviceType),
                              color: _getServiceColor(serviceType),
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: _getServiceColor(
                            serviceType,
                          ).withValues(alpha: 0.2),
                          child: Icon(
                            _getServiceIcon(serviceType),
                            color: _getServiceColor(serviceType),
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getServiceColor(
                            serviceType,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getServiceLabel(serviceType),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getServiceColor(serviceType),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Service name
                      Text(
                        serviceName,
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.isNotEmpty) ...[
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
                                location,
                                style: context.captionStyle.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Rating and price row
                      Row(
                        children: [
                          if (rating != null) ...[
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: context.captionStyle.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _formatPrice(totalPrice),
                            style: context.bodyTwoStyle.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.w600,
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
          // Bottom info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                if (startDate != null)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: context.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(startDate),
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                // Status: Pending
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đang chờ xác nhận',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[800],
                        ),
                      ),
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
