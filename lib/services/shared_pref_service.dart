import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _keyIsNewUser = 'isNewUser';

  static Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsNewUser) ?? true;
  }

  static Future<void> setIsNewUser(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsNewUser, value);
  }
}
