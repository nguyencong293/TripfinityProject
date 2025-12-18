import 'package:app/views/widgets/rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecentItemTile extends StatelessWidget {
  // Kích thước cố định để ListView ngang cuộn mượt và đồng đều
  static const double kWidth = 320;
  static const double kHeight = 92;

  final String? leftImageAsset;
  final String? leftImageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final VoidCallback? onTap;

  const RecentItemTile({
    super.key,
    this.leftImageAsset,
    this.leftImageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    this.onTap,
  });

  Widget _buildImage(BuildContext context) {
    if (leftImageUrl != null && leftImageUrl!.isNotEmpty) {
      return Image.network(
        leftImageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 56,
          height: 56,
          color: context.primaryColor.withValues(alpha: 0.1),
          child: Icon(LucideIcons.image, color: context.primaryColor, size: 24),
        ),
      );
    } else if (leftImageAsset != null && leftImageAsset!.isNotEmpty) {
      return Image.asset(
        leftImageAsset!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 56,
        height: 56,
        color: context.primaryColor.withValues(alpha: 0.1),
        child: Icon(LucideIcons.image, color: context.primaryColor, size: 24),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kWidth,
      height: kHeight,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImage(context),
                ),
                const SizedBox(width: 12),
                // Dùng Expanded ở trong card có chiều rộng cố định => không phá layout
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.subTitleTwoStyle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RatingStars(rating: rating, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            rating.toStringAsFixed(1),
                            style: context.bodyOneStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyOneStyle,
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
