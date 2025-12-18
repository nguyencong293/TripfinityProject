import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/views/widgets/section_header.dart';
import 'package:app/views/widgets/favorite_button.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';
import 'package:app/services/user_interaction_service.dart';

class HomeServiceItem {
  final String title;
  final double rating;
  final String price; // đã format sẵn, ví dụ: "250.000 đ" hoặc "30 USD"
  final String imageUrl; // URL thật (có fallback nếu lỗi)
  final String serviceType; // hotel, restaurant, attraction, tour
  final int serviceId;
  final bool isFavorite;

  HomeServiceItem({
    required this.title,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.serviceType,
    required this.serviceId,
    this.isFavorite = false,
  });
}

class HomeHorizontalSection extends StatelessWidget {
  final String title;
  final String pageStorageKey;
  final Future<List<HomeServiceItem>> futureItems;
  final VoidCallback? onSeeMore;

  const HomeHorizontalSection({
    super.key,
    required this.title,
    required this.pageStorageKey,
    required this.futureItems,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onSeeMore != null)
          SectionHeader(
            title: title,
            actionLabel: 'see_more'.tr,
            onAction: onSeeMore!,
          )
        else
          SectionHeader(title: title),
        const SizedBox(height: 8),
        SizedBox(
          // Tăng chiều cao danh sách để tránh overflow khi có 2 dòng tiêu đề + giá
          height: _HomeServiceCard.listHeight(context),
          child: FutureBuilder<List<HomeServiceItem>>(
            future: futureItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Không thể tải dữ liệu',
                    style: context.captionStyle.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }
              final items = snapshot.data ?? const <HomeServiceItem>[];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'Không có dữ liệu',
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                );
              }
              return ListView.separated(
                key: PageStorageKey(pageStorageKey),
                primary: false,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return _HomeServiceCard(
                    imageUrl: it.imageUrl,
                    title: it.title,
                    rating: it.rating,
                    price: it.price,
                    serviceType: it.serviceType,
                    serviceId: it.serviceId,
                    isFavorite: it.isFavorite,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: items.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;
  final String serviceType;
  final int serviceId;
  final bool isFavorite;

  const _HomeServiceCard({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
    required this.serviceType,
    required this.serviceId,
    required this.isFavorite,
  });

  static double listHeight(BuildContext context) {
    // Tăng nhẹ để đảm bảo nội dung luôn vừa vặn (kể cả 2 dòng tiêu đề + giá)
    return 225;
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 120,
      color: context.primaryColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(LucideIcons.image, color: context.primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        // Bảo đảm item cao bằng chiều cao list để Column nhận đúng constraints
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.dividerColor.withValues(alpha: .25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: (imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imageFallback(context),
                        )
                      : _imageFallback(context),
                ),
                // Favorite button positioned at top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(
                    serviceType: serviceType,
                    serviceId: serviceId,
                    size: 20,
                    initialIsFavorite: isFavorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                // Giảm line-height để tiết kiệm chiều cao, tránh tràn
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Stars + số điểm dùng màu primary (xanh)
                  _StarRating(
                    rating: rating,
                    size: 14,
                    color: context.primaryColor,
                  ),
                  Text(
                    '(${rating.toStringAsFixed(1)})',
                    style: context.bodyTwoStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (price.isNotEmpty) ...[
              const SizedBox(height: 4), // thu gọn spacing một chút
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // "Giá từ" nhỏ hơn và nghiêng
                    Text(
                      'Giá từ:',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Giá tiền dùng màu primary (xanh)
                    Text(
                      price,
                      style: context.bodyOneStyle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) async {
    // 🔥 Track CLICK for AI recommendation
    final trackingService = await UserInteractionService.create();
    if (!context.mounted) return;

    switch (serviceType) {
      case 'hotel':
        trackingService.recordClick(itemId: serviceId, itemType: 'hotel');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailOverviewScreen(hotelId: serviceId),
          ),
        );
        break;
      case 'restaurant':
        trackingService.recordClick(itemId: serviceId, itemType: 'restaurant');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantDetailScreen(restaurantId: serviceId),
          ),
        );
        break;
      case 'attraction':
        trackingService.recordClick(itemId: serviceId, itemType: 'attraction');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttractionsOverviewDetailScreen(attractionId: serviceId),
          ),
        );
        break;
      case 'tour':
        trackingService.recordClick(itemId: serviceId, itemType: 'tour');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourServiceDetailScreen(tourId: serviceId),
          ),
        );
        break;
    }
  }
}

// Widget sao 5 mức với nửa sao, hiển thị gọn và đẹp
class _StarRating extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  final Color color;

  const _StarRating({
    required this.rating,
    this.size = 14,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    final r = rating.isNaN ? 0.0 : rating.clamp(0.0, 5.0);
    int full = r.floor();
    final frac = r - full;

    bool hasHalf = false;
    if (frac >= 0.75) {
      full += 1;
    } else if (frac >= 0.25) {
      hasHalf = true;
    }
    final empty = 5 - full - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < full; i++)
          Icon(Icons.star_rounded, size: size, color: color),
        if (hasHalf) Icon(Icons.star_half_rounded, size: size, color: color),
        for (int i = 0; i < empty; i++)
          Icon(Icons.star_outline_rounded, size: size, color: color),
      ],
    );
  }
}
