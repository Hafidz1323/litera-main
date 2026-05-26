import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';

/// Manages app locale (language) with SharedPreferences persistence.
/// Supported: 'id' (Bahasa Indonesia), 'en' (English).
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale(AppConstants.defaultLocale);
  bool _hasSelectedLanguage = false;

  Locale get locale => _locale;

  /// True when user has explicitly chosen a language (dismisses first-open dialog).
  bool get hasSelectedLanguage => _hasSelectedLanguage;

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.prefLocale) ?? AppConstants.defaultLocale;
    _locale = Locale(code);
    _hasSelectedLanguage = prefs.getBool(AppConstants.prefLanguageSelected) ?? false;
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    _hasSelectedLanguage = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLocale, languageCode);
    await prefs.setBool(AppConstants.prefLanguageSelected, true);
  }
}
