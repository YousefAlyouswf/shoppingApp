import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/langauge.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/user/categoroes.dart';
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
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    getAppInfoFireBase();
    getAllimagesFromFireStore();
    controller.addListener(_scrollListener);
    fetchToMyCart();
  }

  double showFloatingBtn = 0.0;
  _scrollListener() {
    setState(() {
      showFloatingBtn = controller.offset;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

/////////////////////////----------------------START
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;

    return Scaffold(
      appBar: navIndex == 0
          ? appBar(goToCartScreen: goToCartScreen, context: context)
          : null,
      drawer: drawer(
        context,
        widget.onThemeChanged,
        goToHome,
        goToCategoryPage,
        changeLangauge: widget.changeLangauge,
      ),
      body: navIndex == 0
          ? SingleChildScrollView(
              child: Column(
                children: [
                  discountShow(context),
                  Text(
                    word('NEW_ARRIVAL', context),
                    style: TextStyle(
                        fontSize: 35,
                        fontFamily: isEnglish ? "summer" : "MainFont"),
                  ),
                  networkImage2 == null
                      ? Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : imageCarousel(imageShowSize, imageOnTap),
                ],
              ),
            )
          : navIndex == 1
              ? Container(
                  child: Column(
                    children: [
                      headerCatgory(switchBetweenCategory),
                      seprater(),
                      subCollection(
                        context,
                        setFirstElemntInSubCollection,
                        fetchToMyCart,
                      ),
                    ],
                  ),
                )
              : navIndex == 2
                  ? Container(
                      child: Column(
                        children: [
                          header(context),
                          invoiceTable(
                            context,
                            fetchToMyCart,
                            emptyCartGoToCategory,
                          ),
                          buttons(
                            context,
                            widget.onThemeChanged,
                            widget.changeLangauge,
                            applyDiscount,
                          ),
                        ],
                      ),
                    )
                  : navIndex == 3 ? orderScreen(context, userID) : Container(),
      bottomNavigationBar: bottomNavgation(bottomNavIndex, context),
    );
  }

/////////////////////////----------------------END

  //--------------> Sections Category

  setFirstElemntInSubCollection() async {
    await Firestore.instance
        .collection('categories')
        .getDocuments()
        .then((value) {
      value.documents.forEach((e) {
        setState(() {
          categoryNameSelected = e['collection'][0]['name'];
        });
      });
    });
  }

  ////------------- Main Sccreen
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

  ///----------->>> CART Start

  double sumPrice = 0;

  Future<void> fetchToMyCart() async {
    sumPrice = 0;
    sumBuyPrice = 0;
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
      cartCount = cart.length;
    });

    for (var i = 0; i < cart.length; i++) {
      eachPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
      eachBuyPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }

    for (var i = 0; i < cart.length; i++) {
      sumPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
    }
    for (var i = 0; i < cart.length; i++) {
      sumBuyPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }
    quantity = 0;
    for (var i = 0; i < cart.length; i++) {
      quantity += int.parse(cart[i].quantity);
    }

    if (isDeliver) {
      totalAfterTax = sumPrice * tax / 100 + sumPrice + delivery;
    } else {
      totalAfterTax = sumPrice * tax / 100 + sumPrice;
    }
    if (totalAfterTax == delivery) {
      totalAfterTax = 0.0;
    }
  }

  getTaxAndDeliveryPrice() async {
    await Firestore.instance.collection('app').getDocuments().then((value) {
      value.documents.forEach((element) {
        setState(() {
          tax = element['tax'];
          delivery = element['delivery'];
        });
      });
    });
    fetchToMyCart();
  }

  emptyCartGoToCategory() {
    navIndex = 1;
    setState(() {});
  }

  applyDiscount() async {
    bool isCorrect = false;
    print("Before--->>>>$totalAfterTax");
    await Firestore.instance.collection('discount').getDocuments().then((v) {
      v.documents.forEach((e) {
        if (e['code'] == discountController.text) {
          isCorrect = true;
          double x = double.parse(e['discount']);
          setState(() {
            totalAfterTax = (x * totalAfterTax / 100 - totalAfterTax) * -1;
          });
        }
      });
    });
    if (isCorrect) {
      infoToast("تم تفعيل الخصم");
    } else {
      errorToast("الكود غير صحيح");
    }
    print("After--->>>>$totalAfterTax");
    Navigator.pop(context);
  }

///////////----------------->>> CART End
  imageOnTap(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowItem(
          image: itemShow[i].image,
          name: itemShow[i].itemName,
          des: itemShow[i].itemDes,
          price: itemShow[i].itemPrice,
          fetchToMyCart: fetchToMyCart,
          imageID: itemShow[i].imageID,
          buyPrice: itemShow[i].buyPrice,
          size: itemShow[i].size,
          totalQuantity: itemShow[i].totalQuantity,
        ),
      ),
    );
    setState(() {});
    cartCount = cart.length;
  }

  List<ItemShow> itemShow = new List();
  getAllimagesFromFireStore() async {
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

  getAppInfoFireBase() async {
    await FirestoreFunctions().getAppInfo().then((value) {
      setState(() {});
      appInfo = value;
    });
  }

  //----------------->>> My Order Start
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  String userID;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      userID = androidInfo.androidId;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
      userID = iosDeviceInfo.identifierForVendor;
    }
  }
  //------------------>>> MY ORDER END

  bottomNavIndex(int i) {
    setState(() {
      navIndex = i;
    });
    if (i == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (i == 1) {
    } else if (i == 2) {
      getTaxAndDeliveryPrice();
    } else if (i == 3) {
      deviceID();
    }
  }

  goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
    navIndex = 0;
    setState(() {});
  }

  ///----------------> Category
  ///

  switchBetweenCategory(String name, int i) {
    setState(() {
      categoryNameSelected = name;
      for (var j = 0; j < 20; j++) {
        if (j == i) {
          selected[j] = true;
        } else {
          selected[j] = false;
        }
      }
    });
  }
}
