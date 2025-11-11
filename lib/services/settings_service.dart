import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kOpenAiKey = 'openai_api_key';
  static const _kRapidApiKey = 'rapidapi_key';

  Future<void> setOpenAiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOpenAiKey, key.trim());
  }

  Future<String?> getOpenAiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final k = prefs.getString(_kOpenAiKey);
    if (k == null || k.trim().isEmpty) return null;
    return k;
  }

  Future<void> setRapidApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRapidApiKey, key.trim());
  }

  Future<String?> getRapidApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final k = prefs.getString(_kRapidApiKey);
    if (k == null || k.trim().isEmpty) return null;
    return k;
  }
}
