import 'package:flutter/material.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:rate_my_app/rate_my_app.dart';
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
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 1,
    remindDays: 0,
    remindLaunches: 1,
    // appStoreIdentifier: '',
    // googlePlayIdentifier: '',
  );

  Future<bool> mock() async {
    await Future.delayed(Duration(seconds: 2), () {});
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
    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showStarRateDialog(
          context,
          title: "أعجبك تطبيقنا؟",
          message: "يمكنك تقييمنا الآن",
          actionsBuilder: (context, stars) {
            return [
              // Return a list of actions (that will be shown at the bottom of the dialog).
              FlatButton(
                child: Text('OK'),
                onPressed: () async {
                  print('Thanks for the ' +
                      (stars == null ? '0' : stars.round().toString()) +
                      ' star(s) !');
                  // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
                  // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
                  await rateMyApp
                      .callEvent(RateMyAppEventType.rateButtonPressed);
                  Navigator.pop<RateMyAppDialogButton>(
                      context, RateMyAppDialogButton.rate);
                },
              ),
            ];
          },
          ignoreIOS:
              false, // Set to false if you want to show the native Apple app rating dialog on iOS.
          dialogStyle: DialogStyle(
            // Custom dialog styles.
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20),
          ),
          starRatingOptions:
              StarRatingOptions(), // Custom star bar rating options.
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
              .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
        );
      }
    });
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
