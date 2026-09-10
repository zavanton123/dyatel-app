import 'package:shared_preferences/shared_preferences.dart';

import '../models/language.dart';

/// Persists the few choices worth surviving a restart.
class SettingsService {
  static const _languageKey = 'language';
  static const _hideKey = 'hide_number';
  static const _fromKey = 'range_from';
  static const _toKey = 'range_to';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String> loadLanguage() async {
    final code = (await _prefs).getString(_languageKey);
    if (code == null) return kDefaultLanguage;
    return kLanguages.any((l) => l.code == code) ? code : kDefaultLanguage;
  }

  Future<void> saveLanguage(String code) async =>
      (await _prefs).setString(_languageKey, code);

  Future<bool> loadHideNumber() async =>
      (await _prefs).getBool(_hideKey) ?? false;

  Future<void> saveHideNumber(bool value) async =>
      (await _prefs).setBool(_hideKey, value);

  Future<({int from, int to})> loadRange() async {
    final prefs = await _prefs;
    return (
      from: prefs.getInt(_fromKey) ?? 0,
      to: prefs.getInt(_toKey) ?? 100000,
    );
  }

  Future<void> saveRange(int from, int to) async {
    final prefs = await _prefs;
    await prefs.setInt(_fromKey, from);
    await prefs.setInt(_toKey, to);
  }
}
