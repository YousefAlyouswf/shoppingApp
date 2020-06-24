import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String managerLogin = "managerLogin";
  static String language = "language";
  static Future<void> saveManagerLogin(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(managerLogin, isUserLoggedIn);
  }

  static Future<void> saveLanguage(bool lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(language, lang);
  }

  //Get Data

  static Future<bool> getManagerLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(managerLogin);
  }

  static Future<bool> getLangauge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(language);
  }
}
