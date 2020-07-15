import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'database/firestore.dart';
import 'helper/HelperFunction.dart';
import 'models/itemShow.dart';

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
    await Future.delayed(Duration(seconds: 3), () {});
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

  Future<void> getAllimagesFromFireStore() async {
    try {
      itemShow = new List();
      networkImage = new List();
      await FirestoreFunctions().getAllImages().then((value) {
        int listLength = value.length;
        for (var i = 0; i < listLength; i++) {
          networkImage.add(NetworkImage(value[i].image));
          itemShow.add(value[i]);
        }

        setState(() {});
        networkImage2 = networkImage;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    getAllimagesFromFireStore().whenComplete(() {
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
    });
  }

  bool firstTime = false;
  Future<bool> areYouFristTimeOpenApp() async {
    firstTime = await HelperFunction.getFirstLangauge();
    setState(() {});
    if (firstTime == null) {
      firstTime = true;
    }
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
              : Center(
                  child: Row(
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
                        child: flagLanguage("عربي"),
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
                        child: flagLanguage("English"),
                      ),
                    ],
                  ),
                )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer.fromColors(
                  baseColor: Color(0xFFFF834F),
                  highlightColor: Colors.white,
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
                  highlightColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      "Colors & Touches",
                      style: TextStyle(
                        fontSize: 35,
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

  Widget flagLanguage(String label) {
    return Container(
      margin: EdgeInsets.all(16.0),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
