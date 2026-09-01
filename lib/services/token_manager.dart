import '../helpers/sp_helper.dart';

class TokenManager {
  static String? _token;

  static String? get token => _token;

  static bool get hasToken => _token != null && _token!.isNotEmpty;

  static void setToken(String? token) {
    _token = token;
    if (token != null) {
      SPHelper.saveToken(token);
    }
  }

  static void clear() {
    _token = null;
    SPHelper.clear();
  }
}
