import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh');

  Locale get locale => _locale;
  bool get isZh => _locale.languageCode == 'zh';

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void toggle() {
    _locale = isZh ? const Locale('en') : const Locale('zh');
    notifyListeners();
  }
}
