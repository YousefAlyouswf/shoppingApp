import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/homePage.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/appInfo.dart';

import 'package:shop_app/widgets/langauge.dart';
import 'package:uuid/uuid.dart';

import 'lang/appLocale.dart';

var uuid = Uuid();
int cartCount = 0;
List<AppInfoModel> appInfo = [];
AppBar appBar(
    {Function goToCartScreen,
    String text = "رفوف",
    bool search = false,
    bool cart = false,
    BuildContext context}) {
  String appName = AppLocale.of(context).getTranslated('appName');
  return AppBar(
    elevation: 0,
    iconTheme: new IconThemeData(
      color: Colors.black54,
    ),
    title: Text(
      appName,
      style: TextStyle(
          fontFamily: isEnglish ? 'EN' : "MainFont", color: Colors.black),
    ),
    backgroundColor: Colors.grey[200],
    centerTitle: true,
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_basket,
                color: Colors.black54,
                size: 35,
              ),
              onPressed: goToCartScreen,
            ),
            cartCount == 0
                ? Container()
                : Align(
                    alignment: Alignment(0, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF834F),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                        ),
                        Text(
                          "$cartCount",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      )
    ],
  );
}

bool isEnglish = false;
Drawer drawer(
  BuildContext context,
  Function onThemeChanged,
  Function goToHome,
  Function goToCategoryPage, {
  Function changeLangauge,
  Function fetchMyCart,
}) {
  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: Container(
            child: StreamBuilder(
                stream: Firestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text('');
                  } else {
                    return ListView.builder(
                      itemCount:
                          snapshot.data.documents[0].data['collection'].length,
                      itemBuilder: (context, i) {
                        String categoryName = snapshot
                            .data.documents[0].data['collection'][i]['name'];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.grey[200],
                            child: ListTile(
                              onTap: () {
                                goToCategoryPage(categoryName, i);
                                Navigator.pop(context);
                              },
                              title: Text(
                                categoryName,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text(isEnglish ? english[6] : arabic[6]),
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
                    child: Column(
                      children: [
                        FlatButton(
                          onPressed: () {
                            changeLangauge();
                            try {
                              fetchMyCart();
                            } catch (e) {
                              print("Error 1000");
                            }
                          },
                          child: Text(isEnglish ? english[10] : arabic[10]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
        ListTile(
          title: Text(word("dark", context)),
          leading: Icon(
            Icons.lightbulb_outline,
          ),
          onTap: onThemeChanged,
        ),
        ListTile(
          title: Text(word("info", context)),
          leading: Icon(
            Icons.help,
          ),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "RFOOF",
              applicationVersion: "0.0.11",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePageManager()),
                      );
                    }
                  });
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 30,
        )
      ],
    ),
  );
}

Widget continaer(String text, Color color) {
  return Padding(
    padding:
        const EdgeInsets.only(top: 100, bottom: 16.0, left: 16.0, right: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: FlatButton(
        onPressed: () {},
        child: Text(text),
      ),
    ),
  );
}

Widget managerBody() {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Scaffold(),
      ),
    ),
  );
}

errorToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

infoToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.yellow[100],
      textColor: Colors.black,
      fontSize: 16.0);
}

//Bottom Navigation
class Destination {
  const Destination(this.title, this.icon, this.color);
  final String title;
  final IconData icon;
  final MaterialColor color;
}

int navIndex = 0;
Widget bottomNavgation(Function bottomNavIndex, BuildContext context) {
  List<Destination> allDestinations = <Destination>[
    Destination(word('HOME', context), Icons.home, Colors.teal),
    Destination(word('category', context), Icons.category, Colors.cyan),
    Destination(word('cart', context), Icons.shopping_basket, Colors.orange),
    Destination(word('order', context), Icons.receipt, Colors.blue)
  ];
  return BottomNavigationBar(
    backgroundColor: Colors.grey[200],
    currentIndex: navIndex,
    onTap: bottomNavIndex,
    type: BottomNavigationBarType.fixed,
    fixedColor: Color(0xFFFF834F),
    iconSize: 35,
    items: allDestinations.map((Destination destination) {
      return BottomNavigationBarItem(
        icon: Icon(destination.icon),
        backgroundColor: destination.color,
        title: Text(
          destination.title,
          style: TextStyle(fontFamily: "MainFont"),
        ),
      );
    }).toList(),
  );
}
