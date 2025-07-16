import 'package:flutter/material.dart';

class AppColors {
  // Light theme
  static const lightPrimary = Color(0xFF34a853);
  static const lightPrimaryHover = Color(0xFF2c8b47);
  static const lightSecondary = Color(0xFFd9f2e7);
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightCardBackground = Color(0xFFf8f9fa);
  static const lightTextPrimary = Color(0xFF212121);
  static const lightTextSecondary = Color(0xFF616161);
  static const lightTextDisabled = Color(0xFF9e9e9e);
  static const lightBorderLine = Color(0xFFe0e0e0);
  static const lightIconColor = Color(0xFF34a853);
  static const lightIconDisabled = Color(0xFFbdbdbd);
  static const lightButtonTextColor = Color(0xFFffffff);
  static const lightButtonDisabledBackground = Color(0xFFe0e0e0);
  static const lightButtonDisabledText = Color(0xFF9e9e9e);
  static const lightWarningAlert = Color(0xFFffa726);
  static const lightError = Color(0xFFe53935);
  static const lightErrorBackground = Color(0xFFffebee);
  static const lightSuccess = Color(0xFF43a047);
  static const lightInfo = Color(0xFF29b6f6);
  static const lightFocusRing = Color(0xFF34a853);
  static const lightOverlayModalBackdrop = Color(0x66000000);
  static const lightSkeletonPlaceholder = Color(0xFFeeeeee);
  static const lightDivider = Color(0xFFf0f0f0);

  // Dark theme
  static const darkPrimary = Color(0xFF34a853);
  static const darkPrimaryHover = Color(0xFF2c8b47);
  static const darkSecondary = Color(0xFF1e3d34);
  static const darkBackground = Color(0xFF121212);
  static const darkCardBackground = Color(0xFF1e1e1e);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFbdbdbd);
  static const darkTextDisabled = Color(0xFF757575);
  static const darkBorderLine = Color(0xFF333333);
  static const darkIconColor = Color(0xFF34a853);
  static const darkIconDisabled = Color(0xFF666666);
  static const darkButtonTextColor = Color(0xFFffffff);
  static const darkButtonDisabledBackground = Color(0xFF333333);
  static const darkButtonDisabledText = Color(0xFF757575);
  static const darkWarningAlert = Color(0xFFffb74d);
  static const darkError = Color(0xFFef5350);
  static const darkErrorBackground = Color(0xFF311111);
  static const darkSuccess = Color(0xFF66bb6a);
  static const darkInfo = Color(0xFF4fc3f7);
  static const darkFocusRing = Color(0xFF34a853);
  static const darkOverlayModalBackdrop = Color(0x66000000);
  static const darkSkeletonPlaceholder = Color(0xFF2c2c2c);
  static const darkDivider = Color(0xFF2a2a2a);
}

/// Extension để dễ dàng truy cập màu theo theme hiện tại
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor =>
      isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;

  Color get primaryHoverColor =>
      isDarkMode ? AppColors.darkPrimaryHover : AppColors.lightPrimaryHover;

  Color get secondaryColor =>
      isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;

  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  Color get cardBackgroundColor =>
      isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground;

  Color get textPrimaryColor =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get textSecondaryColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get textDisabledColor =>
      isDarkMode ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;

  Color get borderLineColor =>
      isDarkMode ? AppColors.darkBorderLine : AppColors.lightBorderLine;

  Color get iconColor =>
      isDarkMode ? AppColors.darkIconColor : AppColors.lightIconColor;

  Color get iconDisabledColor =>
      isDarkMode ? AppColors.darkIconDisabled : AppColors.lightIconDisabled;

  Color get buttonTextColor => isDarkMode
      ? AppColors.darkButtonTextColor
      : AppColors.lightButtonTextColor;

  Color get buttonDisabledBackgroundColor => isDarkMode
      ? AppColors.darkButtonDisabledBackground
      : AppColors.lightButtonDisabledBackground;

  Color get buttonDisabledTextColor => isDarkMode
      ? AppColors.darkButtonDisabledText
      : AppColors.lightButtonDisabledText;

  Color get warningAlertColor =>
      isDarkMode ? AppColors.darkWarningAlert : AppColors.lightWarningAlert;

  Color get errorColor =>
      isDarkMode ? AppColors.darkError : AppColors.lightError;

  Color get errorBackgroundColor => isDarkMode
      ? AppColors.darkErrorBackground
      : AppColors.lightErrorBackground;

  Color get successColor =>
      isDarkMode ? AppColors.darkSuccess : AppColors.lightSuccess;

  Color get infoColor => isDarkMode ? AppColors.darkInfo : AppColors.lightInfo;

  Color get focusRingColor =>
      isDarkMode ? AppColors.darkFocusRing : AppColors.lightFocusRing;

  Color get overlayModalBackdropColor => isDarkMode
      ? AppColors.darkOverlayModalBackdrop
      : AppColors.lightOverlayModalBackdrop;

  Color get skeletonPlaceholderColor => isDarkMode
      ? AppColors.darkSkeletonPlaceholder
      : AppColors.lightSkeletonPlaceholder;

  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.lightDivider;
}
