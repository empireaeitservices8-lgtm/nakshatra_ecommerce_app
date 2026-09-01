import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SPHelper {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserReferralCode = 'user_referral_code';
  static const String _keyUserReferralBalance = 'user_referral_balance';
  static const String _keyUserCreatedAt = 'user_created_at';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> saveString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setString(key, value);
  }

  static Future<void> saveUser(User user) async {
    await _prefs?.setString(_keyUserId, user.id);
    await _prefs?.setString(_keyUserName, user.name);
    await _prefs?.setString(_keyUserEmail, user.email);
    await _prefs?.setString(_keyUserPhone, user.phone);
    await _prefs?.setString(_keyUserReferralCode, user.referralCode);
    await _prefs?.setDouble(_keyUserReferralBalance, user.referralBalance);
    await _prefs?.setString(_keyUserCreatedAt, user.createdAt);
  }

  static User? getUser() {
    final id = _prefs?.getString(_keyUserId);
    final name = _prefs?.getString(_keyUserName);
    final email = _prefs?.getString(_keyUserEmail);
    final phone = _prefs?.getString(_keyUserPhone);
    final referralCode = _prefs?.getString(_keyUserReferralCode) ?? '';
    final referralBalance = _prefs?.getDouble(_keyUserReferralBalance) ?? 0.0;
    final createdAt = _prefs?.getString(_keyUserCreatedAt) ?? '';

    if (id != null && name != null && email != null && phone != null) {
      return User(
        id: id,
        name: name,
        phone: phone,
        email: email,
        referralCode: referralCode,
        referralBalance: referralBalance,
        createdAt: createdAt,
      );
    }
    return null;
  }

  static Future<void> clear() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyUserName);
    await _prefs?.remove(_keyUserEmail);
    await _prefs?.remove(_keyUserPhone);
    await _prefs?.remove(_keyUserReferralCode);
    await _prefs?.remove(_keyUserReferralBalance);
    await _prefs?.remove(_keyUserCreatedAt);
  }
}

typedef SpHelper = SPHelper;
