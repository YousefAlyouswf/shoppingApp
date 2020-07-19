import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/lunchApp.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
    //HelperFunction.firstTimeChooseLang(true);
    saveLangaugeHelper();
  }

  getTaxFromFirestore() async {
    await Firestore.instance
        .collection('app')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((r) {
        setState(() {
          //  tax = r['tax'];
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

  changeLangauge({String chooseOne = "non"}) async {
    if (chooseOne == "non") {
      setState(() {
        isEnglish = !isEnglish;
      });
    } else if (chooseOne == "en") {
      setState(() {
        isEnglish = true;
      });
    } else if (chooseOne == "ar") {
      setState(() {
        isEnglish = false;
      });
    }

    HelperFunction.saveLanguage(isEnglish);
  }

  bool checkValue;
  saveLangaugeHelper() async {
    checkValue = await HelperFunction.getLangauge();
    if (checkValue == null || checkValue == false) {
      isEnglish = false;
    } else {
      isEnglish = true;
    }
    setState(() {});
  }

  Locale locale = Locale('ar', '');
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        splashColor: Color(0xFFFF834F),
        unselectedWidgetColor: Color(0xFFFF834F),
        primarySwatch: Colors.grey,
        textSelectionHandleColor: Color(0xFFFF834F),
        textSelectionColor: Color(0xFFFF834F),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: brightness,
      ),
      localizationsDelegates: [
        AppLocale.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: isEnglish ? Locale('en', '') : Locale('ar', ''),
      localeResolutionCallback: (currentLocale, supportedLocale) {
        //  Locale ar = Locale('ar', '');

        if (currentLocale != null) {
          for (Locale locale in supportedLocale) {
            if (currentLocale.languageCode == locale.languageCode) {
              return currentLocale;
            }
          }
        }
        //return ar;
        return supportedLocale.first;
      },
      home: LunchApp(
          onThemeChanged: onThemeChanged, changeLangauge: changeLangauge),
    );
  }
}
