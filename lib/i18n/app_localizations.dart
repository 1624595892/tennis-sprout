import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  final Locale locale;
  final Map<String, dynamic> _data;

  AppLocalizations(this.locale, this._data);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _get(String key) {
    final keys = key.split('.');
    dynamic value = _data;
    for (final k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return key;
      }
    }
    return value?.toString() ?? key;
  }

  // ── Convenience getters ──
  String get appName => _get('app_name');
  String get appNameSub => _get('app_name_sub');
  String bottomNav(String key) => _get('bottom_nav.$key');
  String dailyStatus(String key) => _get('daily_status.$key');
  String vocab(String key) => _get('vocab_academy.$key');
  String vocabCategory(String key) => _get('vocab_academy.category_$key');
  String coach(String key) => _get('coach.$key');
  String practice(String key) => _get('practice.$key');
  String match(String key) => _get('match.$key');
  String skillTree(String key) => _get('skill_tree.$key');
  String insights(String key) => _get('insights.$key');
  String profile(String key) => _get('profile.$key');
  String common(String key) => _get('common.$key');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final jsonString =
        await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    return AppLocalizations(locale, data);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
