import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static Locale currentLocale = const Locale('en');
  static AppLocalizations get currentLocalizations => lookupAppLocalizations(currentLocale);

  LocaleNotifier() : super(currentLocale) {
    _loadLocale();
  }

  static const _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    currentLocale = Locale(localeCode);
    state = currentLocale;
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'hi', 'mr'].contains(locale.languageCode)) return;
    currentLocale = locale;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
