import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kUserId = 'user_id';
  static const _kEmail = 'email';
  static const _kConsentsSensitive = 'consent_sensitive';
  static const _kRegion = 'region';
  static const _kLanguage = 'language';

  Future<void> saveUser({
    required String id,
    required String email,
    String region = 'KE',
    String language = 'en',
    bool consentSensitive = false,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUserId, id);
    await sp.setString(_kEmail, email);
    await sp.setString(_kRegion, region);
    await sp.setString(_kLanguage, language);
    await sp.setBool(_kConsentsSensitive, consentSensitive);
  }

  Future<String?> getUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUserId);
  }

  Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  Future<bool> getSensitiveConsent() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kConsentsSensitive) ?? false;
  }

  Future<String> getRegion() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRegion) ?? 'KE';
  }

  Future<String> getLanguage() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLanguage) ?? 'en';
  }

  Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
