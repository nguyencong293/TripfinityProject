import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Quản lý theme system cho ứng dụng
class AppTheme {
  // Private constructor
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Cấu hình cơ bản
      useMaterial3: true,
      brightness: Brightness.light,
      // Font family
      fontFamily: AppTextStyles.primaryFontFamily,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightBackground,
        error: AppColors.lightError,
        onPrimary: AppColors.lightButtonTextColor,
        onSecondary: AppColors.lightButtonTextColor,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightButtonTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightButtonTextColor,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // nền status bar
          statusBarIconBrightness: Brightness.dark, // icon tối (đen)
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightButtonTextColor,
          disabledBackgroundColor: AppColors.lightButtonDisabledBackground,
          disabledForegroundColor: AppColors.lightButtonDisabledText,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          disabledForegroundColor: AppColors.lightButtonDisabledText,
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          disabledForegroundColor: AppColors.lightButtonDisabledText,
          side: const BorderSide(color: AppColors.lightBorderLine),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.lightBorderLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.lightBorderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.lightError),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.bodyOneText,
        hintStyle: TextStyle(fontSize: 12, color: AppColors.lightTextDisabled),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: AppColors.lightIconColor, size: 24),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayHeroText,
        displayMedium: AppTextStyles.h1Text,
        displaySmall: AppTextStyles.h2Text,
        headlineLarge: AppTextStyles.h3Text,
        headlineMedium: AppTextStyles.h4Text,
        headlineSmall: AppTextStyles.h5Text,
        titleLarge: AppTextStyles.subTitleOneText,
        titleMedium: AppTextStyles.subTitleTwoText,
        bodyLarge: AppTextStyles.bodyOneText,
        bodyMedium: AppTextStyles.bodyTwoText,
        labelLarge: AppTextStyles.buttonText,
        labelMedium: AppTextStyles.overLineText,
        labelSmall: AppTextStyles.captionText,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightButtonTextColor,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightCardBackground,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Snack Bar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: TextStyle(color: AppColors.lightCardBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      // Cấu hình cơ bản
      useMaterial3: true,
      brightness: Brightness.dark,

      // Font family
      fontFamily: AppTextStyles.primaryFontFamily,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkBackground,
        error: AppColors.darkError,
        onPrimary: AppColors.darkButtonTextColor,
        onSecondary: AppColors.darkButtonTextColor,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCardBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 2,
        shadowColor: Colors.black54,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkButtonTextColor,
          disabledBackgroundColor: AppColors.darkButtonDisabledBackground,
          disabledForegroundColor: AppColors.darkButtonDisabledText,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          disabledForegroundColor: AppColors.darkButtonDisabledText,
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          disabledForegroundColor: AppColors.darkButtonDisabledText,
          side: const BorderSide(color: AppColors.darkBorderLine),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.darkBorderLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.darkBorderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.darkError),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: AppTextStyles.bodyOneText,
        hintStyle: TextStyle(fontSize: 12, color: AppColors.darkTextDisabled),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: AppColors.darkIconColor, size: 24),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayHeroText,
        displayMedium: AppTextStyles.h1Text,
        displaySmall: AppTextStyles.h2Text,
        headlineLarge: AppTextStyles.h3Text,
        headlineMedium: AppTextStyles.h4Text,
        headlineSmall: AppTextStyles.h5Text,
        titleLarge: AppTextStyles.subTitleOneText,
        titleMedium: AppTextStyles.subTitleTwoText,
        bodyLarge: AppTextStyles.bodyOneText,
        bodyMedium: AppTextStyles.bodyTwoText,
        labelLarge: AppTextStyles.buttonText,
        labelMedium: AppTextStyles.overLineText,
        labelSmall: AppTextStyles.captionText,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkButtonTextColor,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCardBackground,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Snack Bar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkCardBackground,
        contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
