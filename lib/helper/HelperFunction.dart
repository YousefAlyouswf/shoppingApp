import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String managerLogin = "managerLogin";

  static Future<void> saveManagerLogin(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(managerLogin, isUserLoggedIn);
  }

  //Get Data

  static Future<bool> getManagerLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(managerLogin);
  }
}
