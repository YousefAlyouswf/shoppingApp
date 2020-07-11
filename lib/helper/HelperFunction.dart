import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String managerLogin = "managerLogin";
  static String language = "language";
  static String firstlanguage = "Firstlanguage";
  static String employeeInfo = "employeeInfo";
  static String employeeName = "employeeName";
  static Future<void> saveManagerLogin(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(managerLogin, isUserLoggedIn);
  }

  static Future<void> saveLanguage(bool lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(language, lang);
  }

  static Future<void> firstTimeChooseLang(bool lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(firstlanguage, lang);
  }

  static Future<void> emplyeeLogin(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(employeeInfo, id);
  }

  static Future<void> setEmplyeeName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(employeeName, name);
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

  static Future<bool> getFirstLangauge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(firstlanguage);
  }

  static Future<String> getEmployeeLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(employeeInfo);
  }

  static Future<String> getEmployeeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(employeeName);
  }
}
