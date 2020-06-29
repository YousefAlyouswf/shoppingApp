import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/lunchApp.dart';
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
    saveLangaugeHelper();
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
    HelperFunction.saveLanguage(isEnglish);
  }

  saveLangaugeHelper() async {
    bool checkValue = await HelperFunction.getLangauge();
    if (checkValue == null || checkValue == false) {
      isEnglish = false;
    } else {
      isEnglish = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          //   scaffoldBackgroundColor: isDark ? Colors.grey[800] : Colors.white,
          brightness: brightness,
        ),
        home: LunchApp(
            onThemeChanged: onThemeChanged, changeLangauge: changeLangauge)

        //  HomePage(
        //     onThemeChanged: onThemeChanged, changeLangauge: changeLangauge),
        );
  }
}
