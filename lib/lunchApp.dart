import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neon/neon.dart';
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

  int pickNum = 0;
  @override
  void initState() {
    super.initState();
    pickNum = _random.nextInt(neonList.length);
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
  double fontSize = 40;
  NeonFont neonFont = NeonFont.Automania;
  List<NeonFont> neonList = [
    NeonFont.Automania,
    NeonFont.Beon,
    NeonFont.Cyberpunk,
    NeonFont.Membra,
    NeonFont.Monoton,
  ];
  final _random = new Random();
  //var element = neonList[0];

  @override
  Widget build(BuildContext context) {
    print(pickNum);
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
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
              : Container(
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Neon(
                              text: "sroloC",
                              color: Colors.orange,
                              fontSize: fontSize,
                              blurRadius: 50,
                              font: neonList[pickNum],
                              flickeringText: true,
                              flickeringLetters: [0, 1, 2, 3, 4, 5],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Neon(
                              text: "sehcuoT",
                              color: Colors.orange,
                              fontSize: fontSize,
                              blurRadius: 50,
                              font: neonList[pickNum],
                              flickeringText: true,
                              flickeringLetters: [0, 1, 2, 3, 4, 5, 6],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "إصدار رقم: 0.0.21",
              style: TextStyle(fontFamily: "MainFont", color: Colors.white),
            ),
          ),
        )
      ],
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
