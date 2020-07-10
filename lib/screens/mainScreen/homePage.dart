import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/drawerScreen.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/user/categoryScreen/categoroesWidget.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'package:shop_app/widgets/user/myOrderWidget.dart';
import 'package:shop_app/widgets/widgets.dart';

import '../../push_nofitications.dart';

class HomePage extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  const HomePage({Key key, this.onThemeChanged, this.changeLangauge})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  ScrollController controller;

  double showFloatingBtn = 0.0;
  _scrollListener() {
    setState(() {
      showFloatingBtn = controller.offset;
    });
  }

  Future<int> fetchToMyCart() async {
    List<ItemShow> cart = [];
    final dataList = await DBHelper.getData('cart');
    setState(() {
      cart = dataList
          .map(
            (item) => ItemShow(
              id: item['id'],
              itemName: item['name'],
              itemPrice: item['price'],
              image: item['image'],
              itemDes: item['des'],
              quantity: item['q'],
              buyPrice: item['buyPrice'],
              sizeChose: item['size'],
              productID: item['productID'],
            ),
          )
          .toList();
    });

    int count = 0;
    for (var i = 0; i < cart.length; i++) {
      setState(() {});
      count += int.parse(cart[i].quantity);
    }
    return count;
  }

  callCartCount() async {
    await fetchToMyCart().then((value) {
      setState(() {
        countCart = value;
      });
    });
  }

  FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    getAppInfoFireBase();
    controller.addListener(_scrollListener);
    callCartCount();

    //CLOUD MESSAGING
    _fcm.subscribeToTopic("News");
    //PushNotificationsManager().init();
    //  _fcm.requestNotificationPermissions(IosNotificationSettings());
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage:-----> $message");

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
            ),
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onMessage:-----> $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onMessage:-----> $message");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  int countCart = 0;
  @override
  Widget build(BuildContext context) {
    callCartCount();
    return Scaffold(
      appBar: appBar(countCart, darwerPressdAnimation, toogel,
          goToCartScreen: goToCartScreen, context: context),
      // drawer: drawer(
      //   context,
      //   widget.onThemeChanged,
      //   goToHome,
      //   goToCategoryPage,
      //   changeLangauge: widget.changeLangauge,
      // ),

      body: Stack(
        children: [
          DrawerScreen(
            onThemeChanged: widget.onThemeChanged,
            goToCategoryPage: goToCategoryPage,
            changeLangauge: widget.changeLangauge,
            darwerPressdAnimation: darwerPressdAnimation,
          ),
          allMainScreens(),
        ],
      ),
      bottomNavigationBar: bottomNavgation(bottomNavIndex, context),
    );
  }

  bool toogel = false;
  darwerPressdAnimation() {
    setState(() {
      if (toogel) {
        xOffest = 0;
        yOffest = 0;
        scaleFactor = 1;
        radius = 0;
        borderWidth = 0;
      } else {
        xOffest = isEnglish
            ? MediaQuery.of(context).size.width / 1.5
            : MediaQuery.of(context).size.width / -3;
        yOffest = 150;
        scaleFactor = 0.6;
        radius = 20;
        borderWidth = 5;
      }
      toogel = !toogel;
    });
  }

  double xOffest = 0.0;
  double yOffest = 0.0;
  double radius = 0;
  double scaleFactor = 1;
  double borderWidth = 0;

  Widget allMainScreens() {
    return GestureDetector(
      onTap: () {
        if (toogel) {
          darwerPressdAnimation();
        }
      },
      onHorizontalDragStart: (d) {
        darwerPressdAnimation();
      },
      child: AnimatedContainer(
        transform: Matrix4.translationValues(xOffest, yOffest, 0)
          ..scale(scaleFactor),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: borderWidth, color: Colors.grey),
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        duration: Duration(milliseconds: 250),
        child: navIndex == 0
            ? HomeWidget(
                goToCategoryPage: goToCategoryPage,
                darwerPressdAnimation: darwerPressdAnimation,
                toogel: toogel)
            : navIndex == 1
                ? CategoryWidget()
                : navIndex == 2
                    ? CartWidget()
                    : navIndex == 3 ? OrderWidget() : Container(),
      ),
    );
  }

  goToCategoryPage(String categoryName, int i) {
    setState(() {
      navIndex = 1;
      categoryNameSelected = categoryName;

      for (var j = 0; j < 20; j++) {
        if (j == i) {
          selected[j] = true;
        } else {
          selected[j] = false;
        }
      }
    });
  }

  goToCartScreen() {
    setState(() {
      navIndex = 2;
    });
  }

  getAppInfoFireBase() async {
    await FirestoreFunctions().getAppInfo().then((value) {
      setState(() {});
      appInfo = value;
    });
  }

  bottomNavIndex(int i) {
    if (toogel) {
      darwerPressdAnimation();
    }
    setState(() {
      navIndex = i;
    });
    if (i == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (i == 1) {
    } else if (i == 2) {}
  }

  goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
    navIndex = 0;
    setState(() {});
  }

  Widget bottomNavgation(Function bottomNavIndex, BuildContext context) {
    List<Destination> allDestinations = <Destination>[
      Destination(
          word('HOME', context), FaIcon(FontAwesomeIcons.home), Colors.teal),
      Destination(word('category', context), FaIcon(FontAwesomeIcons.delicious),
          Colors.cyan),
      Destination(word('cart', context),
          FaIcon(FontAwesomeIcons.shoppingBasket), Colors.orange),
      Destination(
          word('order', context), FaIcon(FontAwesomeIcons.receipt), Colors.blue)
    ];
    return BottomNavigationBar(
      currentIndex: navIndex,
      onTap: bottomNavIndex,
      type: BottomNavigationBarType.fixed,
      fixedColor: Color(0xFFFF834F),
      iconSize: 35,
      items: allDestinations.map((Destination destination) {
        return BottomNavigationBarItem(
          icon: destination.icon,
          backgroundColor: destination.color,
          title: Text(
            destination.title,
            style: TextStyle(fontFamily: "MainFont"),
          ),
        );
      }).toList(),
    );
  }
}

int navIndex = 0;
String word(String key, BuildContext context) {
  return AppLocale.of(context).getTranslated(key);
}
