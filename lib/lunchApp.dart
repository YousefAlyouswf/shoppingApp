import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

class LunchApp extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;

  const LunchApp({Key key, this.onThemeChanged, this.changeLangauge})
      : super(key: key);
  @override
  _LunchAppState createState() => _LunchAppState();
}

class _LunchAppState extends State<LunchApp> {
  Future<bool> mock() async {
    await Future.delayed(Duration(seconds: 1), () {});
    return true;
  }

  navgateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(
            onThemeChanged: widget.onThemeChanged,
            changeLangauge: widget.changeLangauge),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mock().then((value) {
      if (value) {
        navgateToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Color(0xFFFF834F),
            highlightColor: Colors.teal,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(width: 10),
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Image.asset(
                "assets/images/logoBigTrans.png",
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
         Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "RFOOF",
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: "EN",
                  color: Color(0xFFFF834F),
                  shadows: <Shadow>[
                    Shadow(
                        blurRadius: 18.0,
                        color: Colors.teal,
                        offset: Offset.fromDirection(120, 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }
}