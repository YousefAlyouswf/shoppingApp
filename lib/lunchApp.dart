import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/widgets.dart';

import 'helper/HelperFunction.dart';

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
          changeLangauge: widget.changeLangauge,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    areYouFristTimeOpenApp().then((v) {
      print(v);
      if (!v) {
        mock().then((value) {
          if (value) {
            navgateToHome();
          }
        });
      }
    });
  }

  bool firstTime = false;
  Future<bool> areYouFristTimeOpenApp() async {
    firstTime = await HelperFunction.getFirstLangauge();
    setState(() {});
    return firstTime;
  }

  bool ispressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      child: firstTime
          ? ispressed
              ? Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        widget.changeLangauge(chooseOne: 'ar');
                        HelperFunction.firstTimeChooseLang(false);
                        mock().then((value) {
                          if (value) {
                            navgateToHome();
                          }
                        });
                        ispressed = true;
                        setState(() {});
                      },
                      child: flagLanguage(
                          "https://i.pinimg.com/originals/dd/6e/8a/dd6e8ae6fff5534ca42e4bd7687190cd.png",
                          "عربي"),
                    ),
                    InkWell(
                      onTap: () {
                        widget.changeLangauge(chooseOne: 'en');
                        HelperFunction.firstTimeChooseLang(false);
                        mock().then((value) {
                          if (value) {
                            navgateToHome();
                          }
                        });
                        ispressed = true;
                        setState(() {});
                      },
                      child: flagLanguage(
                          "https://ak.picdn.net/shutterstock/videos/1021489162/thumb/1.jpg",
                          "English"),
                    ),
                  ],
                )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Color(0xFFFF834F),
                  highlightColor: Colors.grey,
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
                Shimmer.fromColors(
                  baseColor: Color(0xFFFF834F),
                  highlightColor: Colors.grey,
                  child: Padding(
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
                ),
              ],
            ),
    ));
  }

  Widget flagLanguage(String url, String label) {
    return Container(
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        image: DecorationImage(
          image: NetworkImage(
            url,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
