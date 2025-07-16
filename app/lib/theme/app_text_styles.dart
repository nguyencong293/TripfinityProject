
import 'package:app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const String primaryFontFamily = 'Fz Poppin';

  static final TextStyle displayHeroText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static final TextStyle h1Text = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static final TextStyle h2Text = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  static final TextStyle h3Text = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle h4Text = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle h5Text = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle subTitleOneText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle subTitleTwoText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle bodyOneText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle bodyTwoText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle captionText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle buttonText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle overLineText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

// Extension để dễ dàng truy cập text styles với màu theo theme
extension AppTextStylesExtension on BuildContext {
  TextStyle get displayHeroStyle =>
      AppTextStyles.displayHeroText.copyWith(color: textPrimaryColor);

  TextStyle get h1Style =>
      AppTextStyles.h1Text.copyWith(color: textPrimaryColor);

  TextStyle get h2Style =>
      AppTextStyles.h2Text.copyWith(color: textPrimaryColor);

  TextStyle get h3Style =>
      AppTextStyles.h3Text.copyWith(color: textPrimaryColor);

  TextStyle get h4Style =>
      AppTextStyles.h4Text.copyWith(color: textPrimaryColor);

  TextStyle get h5Style =>
      AppTextStyles.h5Text.copyWith(color: textPrimaryColor);

  TextStyle get subTitleOneStyle =>
      AppTextStyles.subTitleOneText.copyWith(color: textPrimaryColor);

  TextStyle get subTitleTwoStyle =>
      AppTextStyles.subTitleTwoText.copyWith(color: textPrimaryColor);

  TextStyle get bodyOneStyle =>
      AppTextStyles.bodyOneText.copyWith(color: textPrimaryColor);

  TextStyle get bodyTwoStyle =>
      AppTextStyles.bodyTwoText.copyWith(color: textPrimaryColor);

  TextStyle get captionStyle =>
      AppTextStyles.captionText.copyWith(color: textPrimaryColor);

  TextStyle get buttonStyle =>
      AppTextStyles.buttonText.copyWith(color: textPrimaryColor);

  TextStyle get overLineStyle =>
      AppTextStyles.overLineText.copyWith(color: textPrimaryColor);
}
