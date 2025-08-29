import 'package:flutter/material.dart';
import 'package:app/config/theme/app_text_styles.dart';

class WeekendCityCard extends StatelessWidget {
  static const double kWidth = 260;
  static const double kHeight = 200;
  static const double kRadius = 22;

  final String imageAsset;
  final String city;
  final String country;

  const WeekendCityCard({
    super.key,
    required this.imageAsset,
    required this.city,
    required this.country,
  });

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
            Image.asset(imageAsset, fit: BoxFit.cover),
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    country,
                    style: context.bodyOneStyle.copyWith(color: Colors.white),
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
