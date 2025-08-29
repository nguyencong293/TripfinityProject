import 'package:flutter/material.dart';
import 'package:app/config/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  final int starCount;
  final Color? filledColor;
  final Color? emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.starCount = 5,
    this.filledColor,
    this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(starCount, (i) {
      final isFilled = i < rating.round();
      return Icon(
        isFilled ? Icons.star_rounded : Icons.star_border_rounded,
        size: size,
        color: isFilled
            ? (filledColor ?? context.successColor)
            : (emptyColor ?? context.textSecondaryColor.withValues(alpha: .6)),
      );
    });
    return Row(children: stars);
  }
}
