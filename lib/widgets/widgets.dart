import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/signin_screen.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/appInfo.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:uuid/uuid.dart';

import 'lang/appLocale.dart';

var uuid = Uuid();
int cartCount = 0;
List<AppInfoModel> appInfo = [];
AppBar appBar(int countCart,
    {Function goToCartScreen,
    String text = "رفوف",
    bool search = false,
    bool cart = false,
    BuildContext context}) {
  String appName = AppLocale.of(context).getTranslated('appName');
  return AppBar(
    backgroundColor: Theme.of(context).primaryColorLight,
    elevation: 0,
    title: Text(
      appName,
      style: TextStyle(
        fontFamily: "MainFont",
      ),
    ),
    centerTitle: true,
    actions: <Widget>[
      // FlatButton(
      //     onPressed: () {
      //       DBHelper.deleteAllItem("cart");
      //     },
      //     child: Icon(Icons.accessibility)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.shoppingBag,
                color: Theme.of(context).unselectedWidgetColor,
                size: 35,
              ),
              onPressed: goToCartScreen,
            ),
            countCart == 0
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
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                        ),
                        Text(
                          "$countCart",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
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
        Container(
          height: 50,
        ),
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
                        String categoryName = isEnglish
                            ? snapshot.data.documents[0].data['collection'][i]
                                ['en_name']
                            : snapshot.data.documents[0].data['collection'][i]
                                ['name'];
                        String choseCategory = snapshot
                            .data.documents[0].data['collection'][i]['name'];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            child: ListTile(
                              onTap: () {
                                goToCategoryPage(choseCategory, i);
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
          title: Text(word("settings", context)),
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
                          onPressed: () async {
                            changeLangauge();
                          },
                          child: Text(word("arabic", context)),
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
              applicationVersion: "0.0.16",
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
                        MaterialPageRoute(builder: (context) => SigninScreen()),
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

addCartToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

errorToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[200],
      textColor: Colors.black,
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
  final FaIcon icon;
  final MaterialColor color;
}
