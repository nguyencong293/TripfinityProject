import 'package:flutter/material.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/views/widgets/rating_stars.dart';

class ExperienceCard extends StatelessWidget {
  static const double kWidth = 200;
  static const double kRadius = 16;
  static const double kImageHeight = 160;

  // Giữ lại hằng mặc định (fallback) nếu cần dùng ở nơi khác
  static const double kListHeight = kImageHeight + 86;

  // NEW: tính chiều cao chính xác theo textStyle hiện tại
  static double listHeight(BuildContext context) {
    final titleStyle = context.subTitleTwoStyle.copyWith(
      fontWeight: FontWeight.w700,
    );
    final twoLine =
        ((titleStyle.fontSize ?? 16) * (titleStyle.height ?? 1.25)) * 2;
    const double topSpacing = 6; // khoảng cách sau ảnh
    const double betweenTitleRating = 4;
    const double ratingRow = 24; // icon + text
    const double bottomPadding = 8;
    return kImageHeight +
        topSpacing +
        twoLine +
        betweenTitleRating +
        ratingRow +
        bottomPadding;
  }

  final String imageAsset;
  final String title;
  final double rating;
  final bool showFavorite;

  const ExperienceCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.rating,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.subTitleTwoStyle.copyWith(
      fontWeight: FontWeight.w700,
    );
    final twoLineHeight =
        ((titleStyle.fontSize ?? 16) * (titleStyle.height ?? 1.25)) * 2;

    return SizedBox(
      width: kWidth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  imageAsset,
                  width: kWidth,
                  height: kImageHeight,
                  fit: BoxFit.cover,
                ),
                if (showFavorite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                height: twoLineHeight, // giữ 2 dòng cố định
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Row(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: context.bodyOneStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RatingStars(rating: 4, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
