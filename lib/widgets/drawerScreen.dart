import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/manager/signin_screen.dart';
import 'package:shop_app/screens/employeeScreen/myAccount.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/widgets.dart';

import '../push_nofitications.dart';

class DrawerScreen extends StatefulWidget {
  final Function goToCategoryPage;
  final Function changeLangauge;
  final Function onThemeChanged;
  final Function darwerPressdAnimation;

  const DrawerScreen(
      {Key key,
      this.goToCategoryPage,
      this.changeLangauge,
      this.onThemeChanged,
      this.darwerPressdAnimation})
      : super(key: key);
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  TextStyle bottomsSettings = TextStyle(color: Colors.black26);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream:
                      Firestore.instance.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('');
                    } else {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: ListView.builder(
                          itemCount: snapshot
                              .data.documents[0].data['collection'].length,
                          itemBuilder: (context, i) {
                            String categoryName = isEnglish
                                ? snapshot.data.documents[0].data['collection']
                                    [i]['en_name']
                                : snapshot.data.documents[0].data['collection']
                                    [i]['name'];
                            String choseCategory = snapshot.data.documents[0]
                                .data['collection'][i]['name'];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: ListTile(
                                  onTap: () {
                                    widget.goToCategoryPage(choseCategory, i);
                                    widget.darwerPressdAnimation();
                                  },
                                  leading: Image.asset(
                                    'assets/images/logo.png',
                                    width: 35,
                                  ),
                                  title: Text(
                                    categoryName,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: "MainFont"),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
            ),
          ),
          Divider(
            thickness: 1,
          ),
          ListTile(
            title: Text(
              word("settings", context),
              style: bottomsSettings,
            ),
            leading: Icon(
              Icons.settings,
            ),
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                          topLeft: Radius.circular(40),
                        ),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  widget.darwerPressdAnimation();
                                  widget.changeLangauge();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      word("arabic", context),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyAccount()),
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "المندوب",
                                    style: TextStyle(fontSize: 20),
                                  )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          // ListTile(
          //   title: Text(
          //     word("dark", context),
          //     style: bottomsSettings,
          //   ),
          //   leading: Icon(
          //     Icons.lightbulb_outline,
          //   ),
          //   onTap: widget.onThemeChanged,
          // ),
          ListTile(
            title: Text(
              word("info", context),
              style: bottomsSettings,
            ),
            leading: Icon(
              Icons.help,
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "ألوان ولمسات",
                applicationVersion: "0.0.27",
                applicationLegalese: "Developed by Yousef Al Yousef",
                useRootNavigator: false,
                children: [Icon(Icons.developer_board)],
                applicationIcon: InkWell(
                  child: Icon(Icons.shopping_basket),
                  onDoubleTap: () {
                    HelperFunction.getManagerLogin().then((value) {
                      if (value == null) {
                        value = false;
                      }
                      if (value) {
                        PushNotificationsManager().init();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SigninScreen()),
                        );
                      }
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
