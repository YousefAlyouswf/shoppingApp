import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocale {
  Locale locale;
  AppLocale(this.locale);

  Map<String, String> _translator;
  static AppLocale of(BuildContext context) {
    return Localizations.of(context, AppLocale);
  }

  Future loadLanguage() async {
    String _fileLang =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> _loadsValue = jsonDecode(_fileLang);
    _translator =
        _loadsValue.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslated(String key) {
    return _translator[key];
  }

  static const LocalizationsDelegate<AppLocale> delegate = _ApplocaleDelegate();
}

class _ApplocaleDelegate extends LocalizationsDelegate<AppLocale> {
  const _ApplocaleDelegate();
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocale> load(Locale locale) async {
    AppLocale appLocale = new AppLocale(locale);
    await appLocale.loadLanguage();
    return appLocale;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocale> old) => false;
}
