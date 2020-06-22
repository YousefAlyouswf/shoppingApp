import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/widgets.dart';

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

  getTaxFromFirestore() async {
    await Firestore.instance
        .collection('app')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((r) {
        setState(() {
          tax = r['tax'];
        });
      });
    });
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

  changeLangauge() async {
    setState(() {
      isEnglish = !isEnglish;
    });
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
      home: HomePage(
          onThemeChanged: onThemeChanged, changeLangauge: changeLangauge),
    );
  }
}
