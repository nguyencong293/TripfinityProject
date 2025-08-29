import 'package:app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/config/theme/app_text_styles.dart';

class ArticleBannerCard extends StatelessWidget {
  static const double kHeight = 380;
  static const double kRadius = 28;

  final String imageAsset;
  final String title;
  final String ctaLabel;
  final VoidCallback? onTap;

  const ArticleBannerCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.ctaLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadius),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
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
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.subTitleTwoStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    backgroundColor: context.backgroundColor,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    ctaLabel,
                    style: TextStyle(color: context.textPrimaryColor),
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
