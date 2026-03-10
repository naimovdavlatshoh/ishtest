import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = const FlutterSecureStorage();

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('uz')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final langCode = await _storage.read(key: 'language_code');
      if (langCode != null && ['uz', 'ru', 'en'].contains(langCode)) {
        state = Locale(langCode);
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> setLocale(Locale tempLocale) async {
    if (!['uz', 'ru', 'en'].contains(tempLocale.languageCode)) return;
    state = tempLocale;
    try {
      await _storage.write(key: 'language_code', value: tempLocale.languageCode);
    } catch (e) {
      // Ignored
    }
  }
}
