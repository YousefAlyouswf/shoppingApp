import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/langauge.dart';
import 'package:shop_app/widgets/test_items.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/user/categoroesWidget.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'package:shop_app/widgets/user/myOrderWidget.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/screens/showItem.dart';

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

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    getAppInfoFireBase();
    controller.addListener(_scrollListener);
    callCartCount();
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
      appBar:
          appBar(countCart, goToCartScreen: goToCartScreen, context: context),
      drawer: drawer(
        context,
        widget.onThemeChanged,
        goToHome,
        goToCategoryPage,
        changeLangauge: widget.changeLangauge,
      ),
      body: navIndex == 0
          ? HomeWidget()
          : navIndex == 1
              ? CategoryWidget()
              : navIndex == 2
                  ? CartWidget()
                  : navIndex == 3 ? OrderWidget() : Container(),
      bottomNavigationBar: bottomNavgation(bottomNavIndex, context),
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

  ///----------------> Category
  ///

}
