import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class LanguageController extends ChangeNotifier {
  String _currentLanguage = 'vi';

  String get currentLanguage => _currentLanguage;

  final Map<String, Map<String, String>> languages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'vi': {'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    'ko': {'name': '한국어', 'flag': '🇰🇷'},
  };

  String get currentFlag => languages[_currentLanguage]!['flag']!;
  String get currentName => languages[_currentLanguage]!['name']!;

  Future<void> changeLanguage(String langCode) async {
    if (languages.containsKey(langCode)) {
      _currentLanguage = langCode;
      await AppLocalization.load(langCode);
      notifyListeners();
    }
  }

  Future<void> init() async {
    await AppLocalization.load(_currentLanguage);
  }
}
