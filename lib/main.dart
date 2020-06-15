import 'package:flutter/material.dart';
import 'package:shop_app/screens/homePage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  @override
  void initState() {
    super.initState();
  }

  Brightness brightness = Brightness.light;
  onThemeChanged() {
    if (brightness == Brightness.light) {
      brightness = Brightness.dark;
    } else {
      brightness = Brightness.light;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //   scaffoldBackgroundColor: isDark ? Colors.grey[800] : Colors.white,
        brightness: brightness,
      ),
      home: HomePage(onThemeChanged: onThemeChanged),
    );
  }
}
