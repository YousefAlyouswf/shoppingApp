import 'package:flutter/material.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'database/firestore.dart';
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
    await Future.delayed(Duration(seconds: 5), () {});
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
          networkImage.add(
            MeetNetworkImage(
              imageUrl: value[i].image,
              loadingBuilder: (context) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://flevix.com/wp-content/uploads/2019/07/Color-Loading-2.gif",
                        ),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, e) => Center(
                child: Text('Error appear!'),
              ),
            ),
          );
          itemShow.add(value[i]);
        }
        if (mounted) {
          setState(() {
            networkImage2 = networkImage;
          });
        }
      });
    } catch (e) {}
  }

  bool firstTime = false;
  Future<bool> areYouFristTimeOpenApp() async {
    firstTime = await HelperFunction.getFirstLangauge();
    if (mounted) {
      setState(() {
        if (firstTime == null) {
          firstTime = true;
        }
      });
    }

    return firstTime;
  }

  bool ispressed = false;

  int pickNum = 0;

  @override
  void initState() {
    super.initState();
    getAllimagesFromFireStore().whenComplete(() {
      areYouFristTimeOpenApp().then((v) {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
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
                                if (mounted) {
                                  setState(() {
                                    ispressed = true;
                                  });
                                }
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

                                if (mounted) {
                                  setState(() {
                                    ispressed = true;
                                  });
                                }
                              },
                              child: flagLanguage("English"),
                            ),
                          ],
                        ),
                      )
                :

                // FlareActor(
                //     'assets/logoTuvan.flr',
                //     fit: BoxFit.fill,
                //     animation: "Untitled",
                //   ),

                Center(
                    child: Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.grey),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "uvan",
                                style: TextStyle(
                                  fontFamily: 'modular',
                                  fontSize: 70,
                                ),
                              ),
                              Text(
                                "T",
                                style: TextStyle(
                                  fontFamily: 'modular',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.4,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "توفان للإزياء والموضة",
                            style:
                                TextStyle(fontSize: 20, fontFamily: "MainFont"),
                          )
                        ],
                      ),
                    ),
                  )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "إصدار رقم: 0.0.28",
              style: TextStyle(fontFamily: "MainFont", color: Colors.black),
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
