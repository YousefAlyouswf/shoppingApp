import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String managerLogin = "managerLogin";
  static String taxTag = "TAXTAG";
  static Future<void> saveManagerLogin(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(managerLogin, isUserLoggedIn);
  }

  static Future<void> saveTax(int tax) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(taxTag, tax);
  }

  //Get Data

  static Future<bool> getManagerLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(managerLogin);
  }
}
