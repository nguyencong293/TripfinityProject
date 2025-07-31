import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalization {
  static Map<String, String> _localizedStrings = {};
  static String _currentLang = 'en';

  static String get currentLang => _currentLang;

  static Future<void> load(String langCode) async {
    try {
      _currentLang = langCode;
      String jsonString = await rootBundle.loadString(
        'assets/lang/$langCode.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      // Fallback to VN if loading fails
      if (langCode != 'en') {
        await load('en');
      } else {
        // If even VN fails, use empty map
        _localizedStrings = {};
      }
    }
  }

  static String get(String key) {
    return _localizedStrings[key] ?? key;
  }
}

// Extension để dễ sử dụng
extension StringExtension on String {
  String get tr => AppLocalization.get(this);
}
