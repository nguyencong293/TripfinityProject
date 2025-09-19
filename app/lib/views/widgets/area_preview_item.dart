import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';

class AreaPreviewItem {
  final String name; // city/province name
  final String country; // subtitle (shortDescription or derived label)
  final String imageUrl; // cover image
  const AreaPreviewItem({
    required this.name,
    required this.country,
    required this.imageUrl,
  });
}

class AreaPreviewCard extends StatelessWidget {
  static const double kWidth = 260;
  static const double kHeight = 200;
  static const double kRadius = 22;

  final String imageUrl;
  final String city;
  final String country;

  const AreaPreviewCard({
    super.key,
    required this.imageUrl,
    required this.city,
    required this.country,
  });

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
    return SizedBox(
      width: kWidth,
      height: kHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(context),
              )
            else
              _imageFallback(context),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: context.subTitleTwoStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    country,
                    style: context.bodyOneStyle.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
