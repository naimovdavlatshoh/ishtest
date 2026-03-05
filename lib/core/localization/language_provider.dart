import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_strings.dart';

const _kLangKey = 'app_language';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.uz) {
    _load();
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    try {
      final String? code = await _storage.read(key: _kLangKey);
      if (code != null) {
        state = AppLanguageExt.fromCode(code);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    try {
      await _storage.write(key: _kLangKey, value: lang.code);
    } catch (_) {}
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// Convenience provider that returns the current language code string
final langCodeProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).code;
});

/// Extension on BuildContext for easy translation access
extension BuildContextTr on BuildContext {
  String tr(String key) {
    // Will be called inside ConsumerWidget — uses ProviderScope
    return key; // fallback; use ref.tr() instead in ConsumerWidgets
  }
}

/// Extension on WidgetRef for easy translation 
extension WidgetRefTr on WidgetRef {
  String tr(String key) {
    final String code = read(langCodeProvider);
    return AppStrings.tr(key, code);
  }

  String watchTr(String key) {
    final String code = watch(langCodeProvider);
    return AppStrings.tr(key, code);
  }
}
